//
//  VBInteractor.swift
//  ViteBusiness
//
//  Created by Stone on 2019/7/10.
//


import Foundation
import Starscream
import PromiseKit
import ViteWallet

public typealias SessionRequestClosure = (_ id: Int64, _ peer: VBPeerMeta) -> Void
public typealias SessionPingTimeoutClosure = () -> Void
public typealias DisconnectClosure = (Error?) -> Void
public typealias ViteSendTxClosure = (_ id: Int64, _ viteSendTx: VBViteSendTx) -> Void

func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    items.forEach {
        Swift.print($0, separator: separator, terminator: terminator)
    }
    #endif
}

public class VBInteractor {
    public let session: VBSession
    public var connected: Bool {
        return socket.isConnected
    }

    public let clientId: String
    public let clientMeta: VBClientMeta

    public private(set) var hasReceivedSessionRequest = false

    // incoming event handlers
    public var onSessionRequest: SessionRequestClosure?
    public var onDisconnect: DisconnectClosure?
    public var onSessionPintTimeout: SessionPingTimeoutClosure?

    public var onViteSendTx: ViteSendTxClosure?

    // outgoing promise resolvers
    var connectResolver: Resolver<Bool>?

    private let socket: WebSocket
    private var handshakeId: Int64 = -1
    private var pingTimer: Timer?

    private var peerId: String?
    private var peerMeta: VBPeerMeta?

    private var sessionPingTimer: Timer?
    private var lastSessionPingTimestamp: TimeInterval?

    public init(session: VBSession, meta: VBClientMeta) {
        self.session = session
        self.clientId = (UIDevice.current.identifierForVendor ?? UUID()).description.lowercased()
        self.clientMeta = meta
        self.socket = WebSocket.init(url: session.bridge)

        socket.onConnect = { [weak self] in self?.onConnect() }
        socket.onDisconnect = { [weak self] error in self?.onDisconnect(error: error) }
        socket.onText = { [weak self] text in self?.onReceiveMessage(text: text) }
        socket.onPong = { _ in print("<== pong") }
        socket.onData = { data in print("<== websocketDidReceiveData: \(data.toHexString())") }
    }

    deinit {
        disconnect()
    }

    public func connect() -> Promise<Bool> {
        if socket.isConnected {
            return Promise.value(true)
        }
        socket.connect()
        return Promise<Bool> { [weak self] seal in
            self?.connectResolver = seal
        }
    }

    public func disconnect() {
        pingTimer?.invalidate()
        sessionPingTimer?.invalidate()
        socket.disconnect()
        connectResolver = nil
        handshakeId = -1
    }

    public func approveSession(accounts: [String], chainId: Int) -> Promise<Void> {
        guard handshakeId > 0 else {
            return Promise(error: VBError.invalidSession)
        }
        updateLastSessionPingTimestamp()
        let result = VBApproveSessionResponse(
            approved: true,
            chainId: chainId,
            accounts: accounts,
            peerId: clientId,
            peerMeta: clientMeta
        )
        let response = JSONRPCResponse(id: handshakeId, result: result)
        return encryptAndSend(data: response.encoded)
    }

    public func rejectSession(_ message: String = "Session Rejected") -> Promise<Void> {
        guard handshakeId > 0 else {
            return Promise(error: VBError.invalidSession)
        }
        let response = JSONRPCErrorResponse(id: handshakeId, error: JSONRPCError(code: ErrorCode.sessionReject.rawValue, message: message))
        return encryptAndSend(data: response.encoded)
    }

    public func killSession() -> Promise<Void> {
        let result = VBSessionUpdateParam(approved: false, chainId: nil, accounts: nil)
        let response = JSONRPCRequest(id: generateId(), method: VBEvent.sessionUpdate.rawValue, params: [result])
        return encryptAndSend(data: response.encoded)
            .map { [weak self] in
                self?.disconnect()
        }
    }

    public func approveViteTx(id: Int64, accountBlock: AccountBlock) -> Promise<Void> {
        guard let data = VBJSONRPCResponse(id: id, result: accountBlock).toJSONString()?.data(using: .utf8) else {
            fatalError()
        }
        return encryptAndSend(data: data)
    }

    public func approveRequest(id: Int64, result: String) -> Promise<Void> {
        let response = JSONRPCResponse(id: id, result: result)
        return encryptAndSend(data: response.encoded)
    }

    public func rejectRequest(id: Int64, message: String) -> Promise<Void> {
        let response = JSONRPCErrorResponse(id: id, error: JSONRPCError(code: ErrorCode.requestReject.rawValue, message: message))
        return encryptAndSend(data: response.encoded)
    }

    public func cancelRequest(id: Int64) -> Promise<Void> {
        let response = JSONRPCErrorResponse(id: id, error: JSONRPCError(code: ErrorCode.cancelReject.rawValue, message: "User Canceled"))
        return encryptAndSend(data: response.encoded)
    }
}

extension VBInteractor {

    enum ErrorCode: Int {
        case sessionReject = 11010
        case requestReject = 11011
        case cancelReject = 11012
    }

    private func subscribe(topic: String) {
        let message = VBSocketMessage(topic: topic, type: .sub, payload: "")
        let data = try! JSONEncoder().encode(message)
        socket.write(data: data)
        print("==> subscribe: \(String(data: data, encoding: .utf8)!)")
    }

    private func encryptAndSend(data: Data) -> Promise<Void> {
        print("==> encrypt: \(String(data: data, encoding: .utf8)!) ")
        let encoder = JSONEncoder()
        let payload = try! VBEncryptor.encrypt(data: data, with: session.key)
        let payloadString = encoder.encodeAsUTF8(payload)
        let message = VBSocketMessage(topic: peerId ?? session.topic, type: .pub, payload: payloadString)
        let data = message.encoded
        return Promise { seal in
            socket.write(data: data) {
                print("==> sent \(String(data: data, encoding: .utf8)!) ")
                seal.fulfill(())
            }
        }
    }

    private func handleEvent(_ event: VBEvent, topic: String, decrypted: Data) {
        do {
            switch event {
            // topic == session.topic
            case .sessionRequest:
                plog(level: .info, log: "session request event", tag: .bifrost)
                hasReceivedSessionRequest = true
                let request: JSONRPCRequest<[VBSessionRequestParam]> = try event.decode(decrypted)
                guard let params = request.params.first else {
                    throw VBError.badJSONRPCRequest
                }
                handshakeId = request.id
                peerId = params.peerId
                peerMeta = params.peerMeta
                onSessionRequest?(request.id, params.peerMeta)
            // topic == clientId
            case .sessionPeerPing:
                plog(level: .info, log: "session peer ping event", tag: .bifrost)
                updateLastSessionPingTimestamp()
                let request: JSONRPCRequest<[VBSessionPingParam]> = try event.decode(decrypted)
                let response = JSONRPCResponse(id: request.id, result: VBSessionPingResponse())
                encryptAndSend(data: response.encoded).cauterize()
            case .sessionUpdate:
                plog(level: .info, log: "session update event", tag: .bifrost)
                let request: JSONRPCRequest<[VBSessionUpdateParam]> = try event.decode(decrypted)
                guard let param = request.params.first else {
                    throw VBError.badJSONRPCRequest
                }
                if param.approved == false {
                    disconnect()
                }
            case .viteSendTx:
                plog(level: .info, log: "vite send tx event", tag: .bifrost)
                guard let jsonString = String(data: decrypted, encoding: .utf8),
                    let request = VBJSONRPCRequest<VBViteSendTx>(JSONString: jsonString),
                    let viteSendTx = request.params.first else {
                        throw VBError.badJSONRPCRequest
                }
                onViteSendTx?(request.id, viteSendTx)
            default:
                break
            }
        } catch let error {
            print("==> handleEvent error: \(error.localizedDescription)")
        }
    }
}
extension VBInteractor {

    private func onConnect() {
        print("<== websocketDidConnect")
        pingTimer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true, block: { [weak socket] _ in
            print("==> ping")
            socket?.write(ping: Data())
        })

        sessionPingTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: { [weak self] _ in
            self?.checkSessionTimeout()
        })

        subscribe(topic: session.topic)
        subscribe(topic: clientId)
        connectResolver?.fulfill(true)
        connectResolver = nil
    }

    private func onDisconnect(error: Error?) {
        print("<== websocketDidDisconnect, error: \(error.debugDescription)")
        pingTimer?.invalidate()
        sessionPingTimer?.invalidate()
        if let error = error {
            connectResolver?.reject(error)
        } else {
            connectResolver?.fulfill(false)
        }
        connectResolver = nil
        onDisconnect?(error)
    }

    private func onReceiveMessage(text: String) {
        print("<== receive: \(text)")
        guard let (topic, payload) = VBEncryptionPayload.extract(text) else { return }
        do {
            let decrypted = try VBEncryptor.decrypt(payload: payload, with: session.key)
            guard let json = try JSONSerialization.jsonObject(with: decrypted, options: [])
                as? [String: Any] else {
                    throw VBError.badServerResponse
            }
            print("<== decrypted: \(String(data: decrypted, encoding: .utf8)!)")
            if let method = json["method"] as? String,
                let event = VBEvent(rawValue: method) {
                handleEvent(event, topic: topic, decrypted: decrypted)
            }
        } catch let error {
            print(error)
        }
    }
}

extension VBInteractor {

    private static let pingTimeout:TimeInterval = 6

    private func updateLastSessionPingTimestamp() {
        lastSessionPingTimestamp = Date().timeIntervalSince1970
    }

    private func checkSessionTimeout() {
        if let lastSessionPingTimestamp = self.lastSessionPingTimestamp,
            Date().timeIntervalSince1970 - lastSessionPingTimestamp > type(of: self).pingTimeout {
            self.onSessionPintTimeout?()
        }
    }
}
