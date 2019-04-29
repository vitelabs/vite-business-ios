//
//  BatchFactory+Array.swift
//  ViteBusiness
//
//  Created by Stone on 2019/4/16.
//

import JSONRPCKit
import enum Result.Result

private var ke_semaphore: UInt8 = 0

public extension BatchFactory {

    private var e_semaphore: DispatchSemaphore {
        if let semaphore = objc_getAssociatedObject(self, &ke_semaphore) as? DispatchSemaphore {
            return semaphore
        } else {
            let semaphore = DispatchSemaphore(value: 1)
            objc_setAssociatedObject(self, &ke_semaphore, semaphore, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return semaphore
        }
    }

    public func create<Request: JSONRPCKit.Request>(_ requests: [Request]) -> BatchArray<Request> {
        _ = e_semaphore.wait(timeout: DispatchTime.distantFuture)
        let batchElements = requests.map { BatchElement(request: $0, version: version, id: idGenerator.next())}
        e_semaphore.signal()

        return BatchArray(batchElements: batchElements)
    }
}

public struct BatchArray<Request: JSONRPCKit.Request>: Batch {
    public typealias Responses = [Request.Response]
    public typealias Results = [Result<Request.Response, JSONRPCError>]

    public let batchElements: [BatchElement<Request>]

    public var requestObject: Any {
        return batchElements.map { $0.body }
    }

    public func responses(from object: Any) throws -> Responses {
        guard let batchObjects = object as? [Any] else {
            throw JSONRPCError.nonArrayResponse(object)
        }

        return try batchElements.map { try $0.e_response(from: batchObjects) }
    }

    public func results(from object: Any) -> Results {
        guard let batchObjects = object as? [Any] else {
            return batchElements.map { _ in .failure(.nonArrayResponse(object)) }
        }

        return batchElements.map { $0.e_result(from: batchObjects) }
    }

    public static func responses(from results: Results) throws -> Responses {
        return try results.map { try $0.dematerialize()}
    }
}

fileprivate extension BatchElement {
    // Copy from https://github.com/bricklife/JSONRPCKit/blob/3.0.0/Sources/JSONRPCKit/BatchElement.swift
    internal func e_response(from object: Any) throws -> Request.Response {
        switch e_result(from: object) {
        case .success(let response):
            return response

        case .failure(let error):
            throw error
        }
    }

    /// - Throws: JSONRPCError
    internal func e_response(from objects: [Any]) throws -> Request.Response {
        switch e_result(from: objects) {
        case .success(let response):
            return response

        case .failure(let error):
            throw error
        }
    }

    internal func e_result(from object: Any) -> Result<Request.Response, JSONRPCError> {
        guard let dictionary = object as? [String: Any] else {
            return .failure(.unexpectedTypeObject(object))
        }

        let receivedVersion = dictionary["jsonrpc"] as? String
        guard version == receivedVersion else {
            return .failure(.unsupportedVersion(receivedVersion))
        }

        guard id == dictionary["id"].flatMap(Id.init) else {
            return .failure(.responseNotFound(requestId: id, object: dictionary))
        }

        let resultObject = dictionary["result"]
        let errorObject = dictionary["error"]

        switch (resultObject, errorObject) {
        case (nil, let errorObject?):
            return .failure(JSONRPCError(errorObject: errorObject))

        case (let resultObject?, nil):
            do {
                return .success(try request.response(from: resultObject))
            } catch {
                return .failure(.resultObjectParseError(error))
            }

        default:
            return .failure(.missingBothResultAndError(dictionary))
        }
    }

    internal func e_result(from objects: [Any]) -> Result<Request.Response, JSONRPCError> {
        let matchedObject = objects
            .flatMap { $0 as? [String: Any] }
            .filter { $0["id"].flatMap(Id.init) == id }
            .first

        guard let object = matchedObject else {
            return .failure(.responseNotFound(requestId: id, object: objects))
        }

        return e_result(from: object)
    }
}
