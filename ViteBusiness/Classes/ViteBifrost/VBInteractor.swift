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

public typealias SessionRequestClosure = (VBInteractor, _ id: Int64, _ peer: VBPeerMeta) -> Void
public typealias DisconnectByPeerClosure = (VBInteractor) -> Void
public typealias DisconnectClosure = (VBInteractor, Error?) -> Void
public typealias ViteSendTxClosure = (VBInteractor, _ id: Int64, _ viteSendTx: VBViteSendTx) -> Void
public typealias ViteSignMessageClosure = (VBInteractor, _ id: Int64, _ viteSendTx: VBViteSignMessage) -> Void

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

    // incoming event handlers
    public var onSessionRequest: SessionRequestClosure?
    public var onDisconnect: DisconnectClosure?
    public var onDisconnectByPeer: DisconnectByPeerClosure?
    public var onViteSendTx: ViteSendTxClosure?
    public var onViteSignMessage: ViteSignMessageClosure?

    // outgoing promise resolvers
    var connectResolver: Resolver<Bool>?

    private let socket: WebSocket
    private var handshakeId: Int64 = -1
    private var pingTimer: Timer?

    private var peerId: String?
    private var peerMeta: VBPeerMeta?
    private var offsetMap: [String: UInt64] = [:]

    public init(session: VBSession, meta: VBClientMeta) {
        self.session = session
        self.clientId = UUID().description.lowercased()
        self.clientMeta = meta
        var request = URLRequest(url: session.bridge)
        request.timeoutInterval = 10
        self.socket = WebSocket.init(request: request)

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
        socket.disconnect()
        connectResolver = nil
        handshakeId = -1
    }

    public func approveSession(accounts: [String], chainId: Int) -> Promise<Void> {
        guard handshakeId > 0 else {
            return Promise(error: VBError.invalidSession)
        }

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

    enum SessionError: Error {
        case pingTimeout
    }

    public func sendPing(timeout: TimeInterval) -> Promise<Void> {
        return Promise { seal in
            after(seconds: timeout).done {_ in
                seal.reject(SessionError.pingTimeout)
            }

            self.send(event: VBEvent.sessionPeerPing, params: [VBSessionPingParam()]) { _ in
                seal.fulfill(Void())
            }
        }
    }

    public func approveViteTx(id: Int64, accountBlock: AccountBlock) -> Promise<Void> {
        guard let jsonString = VBJSONRPCResponse(id: id, result: accountBlock).toJSONString(),
            let data = jsonString.data(using: .utf8) else {
            fatalError()
        }
        plog(level: .info, log: "[bridge-s] viteSendTx result: \(jsonString)", tag: .bifrost)
        return encryptAndSend(data: data)
    }

    public func approveViteSignMessage(id: Int64, response: VBViteSignMessageResponse) -> Promise<Void> {
        guard let jsonString = VBJSONRPCResponse(id: id, result: response).toJSONString(),
            let data = jsonString.data(using: .utf8) else {
            fatalError()
        }
        plog(level: .info, log: "[bridge-s] viteSignMessage result: \(jsonString)", tag: .bifrost)
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

    private func send<T: Codable>(event: VBEvent, params: T, complete: EventCallBack? = nil) {
        let id = generateId()
        let request = JSONRPCRequest(id: id, method: event.rawValue, params: params)
        encryptAndSend(data: request.encoded).cauterize()

        if let c = complete {
            callbackPair[id] = c
        }
    }

    typealias EventCallBack = (Data) -> Void

    var callbackPair = [Int64: EventCallBack]()
}

extension VBInteractor {

    enum ErrorCode: Int {
        case sessionReject = 11010
        case requestReject = 11011
        case cancelReject = 11012
    }

    private func subscribe(topic: String) {
        let message = VBSocketMessage(bridgeVersion: BifrostManager.bridgeVersion, topic: topic, offset: self.offsetMap[topic], type: .sub, payload: "")
        let data = try! JSONEncoder().encode(message)
        socket.write(data: data)
        print("==> subscribe: \(String(data: data, encoding: .utf8)!)")
    }

    private func encryptAndSend(data: Data) -> Promise<Void> {
        print("==> encrypt: \(String(data: data, encoding: .utf8)!) ")
        let encoder = JSONEncoder()
        guard let payload = try? VBEncryptor.encrypt(data: data, with: session.key) else {
            return Promise(error: VBError.unknown)
        }
        let payloadString = encoder.encodeAsUTF8(payload)
        let message = VBSocketMessage(bridgeVersion: BifrostManager.bridgeVersion, topic: peerId ?? session.topic, offset: nil, type: .pub, payload: payloadString)
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
                let request: JSONRPCRequest<[VBSessionRequestParam]> = try event.decode(decrypted)
                guard let params = request.params.first else {
                    throw VBError.badJSONRPCRequest
                }
                plog(level: .info, log: "[bridge-r] session request event: \(params)", tag: .bifrost)
                handshakeId = request.id
                peerId = params.peerId
                peerMeta = params.peerMeta
                onSessionRequest?(self, request.id, params.peerMeta)
            // topic == clientId
            case .sessionUpdate:
                let request: JSONRPCRequest<[VBSessionUpdateParam]> = try event.decode(decrypted)
                guard let param = request.params.first else {
                    throw VBError.badJSONRPCRequest
                }
                plog(level: .info, log: "[bridge-r] session update event: \(param)", tag: .bifrost)
                if param.approved == false {
                    onDisconnectByPeer?(self)
                }
            case .sessionPeerPing:
                // do nothing App send event
                break
            case .viteSendTx:
                guard let jsonString = String(data: decrypted, encoding: .utf8),
                    let request = VBJSONRPCRequest<VBViteSendTx>(JSONString: jsonString),
                    let viteSendTx = request.params.first else {
                        throw VBError.badJSONRPCRequest
                }
                plog(level: .info, log: "[bridge-r] viteSendTx event: \(jsonString)", tag: .bifrost)
                onViteSendTx?(self, request.id, viteSendTx)
            case .viteSignMessage:
                guard let jsonString = String(data: decrypted, encoding: .utf8),
                    let request = VBJSONRPCRequest<VBViteSignMessage>(JSONString: jsonString),
                    let obj = request.params.first else {
                        throw VBError.badJSONRPCRequest
                }
                plog(level: .info, log: "[bridge-r] viteSignMessage event: \(jsonString)", tag: .bifrost)
                onViteSignMessage?(self, request.id, obj)
            }
        } catch let error {
            plog(level: .severe, log: error.localizedDescription, tag: .bifrost)
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

        plog(level: .info, log: "[bridge-s] subscribe topic: \(self.session.topic) clientId: \(self.clientId)", tag: .bifrost)

        subscribe(topic: session.topic)
        subscribe(topic: clientId)
        connectResolver?.fulfill(true)
        connectResolver = nil
    }

    private func onDisconnect(error: Error?) {
        print("<== websocketDidDisconnect, error: \(error.debugDescription)")
        pingTimer?.invalidate()
        if let error = error {
            connectResolver?.reject(error)
        } else {
            connectResolver?.fulfill(false)
        }
        connectResolver = nil
        onDisconnect?(self, error)
    }

    private func onReceiveMessage(text: String) {
        print("<== receive: \(text)")
        guard let (offset, topic, payload) = VBEncryptionPayload.extract(text) else { return }
        do {
            let decrypted = try VBEncryptor.decrypt(payload: payload, with: session.key)
            guard let json = try JSONSerialization.jsonObject(with: decrypted, options: [])
                as? [String: Any] else {
                    throw VBError.badServerResponse
            }
            self.offsetMap[topic] = offset
            print("<== decrypted: \(String(data: decrypted, encoding: .utf8)!)")
            if let method = json["method"] as? String,
                let event = VBEvent(rawValue: method) {
                handleEvent(event, topic: topic, decrypted: decrypted)
            } else {
                if let id = json["id"] as? Int64,
                    let callback = callbackPair[id] {
                    callback(decrypted)
                    callbackPair[id] = nil
                }
            }
        } catch let error {
            print(error)
        }
    }
}
