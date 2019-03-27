//
//  WKWebViewConfig.swift
//  ViteBusiness
//
//  Created by Water on 2018/12/10.
//
import ObjectMapper

public enum ResponseCode {
    case success
    case unknown
    case invalidParameter
    case network
    case notLogin
    case addressDoesNotMatch
    case noAccess
    case other(code: Int)

    var value: Int {
        switch self {
        case .success:
            return 0
        case .unknown:
            return 1
        case .invalidParameter:
            return 2
        case .network:
            return 3
        case .notLogin:
            return 4
        case .addressDoesNotMatch:
            return 5
        case .noAccess:
            return 6
        case .other(let code):
            return code
        }
    }
}

public struct Response : Mappable {
    public init?(map: Map) {

    }

    public mutating func mapping(map: Map) {
        code <- (map["code"])
        msg <- (map["msg"])
        data <- (map["data"])
    }

    public var code : Int = ResponseCode.unknown.value
    public var msg : String? = nil
    public var data : (Any)? = nil

    public init(code: ResponseCode, msg: String?, data: Any?) {
        self.code = code.value
        self.msg = msg
        self.data = data
    }
}

 public class WKWebViewConfig {
    public typealias  NativeCallback = (_ response: Response,_ callbackID:String) -> Void
    public typealias  WebViewConfigClosure = (_ data: [String: String]?) -> Response?
    public typealias  AsyncWebViewConfigClosure = (_ data: [String: String]?,_ callbackId: String, _ callback: @escaping NativeCallback) -> Void

    public static let instance = WKWebViewConfig()

    //nav back image
    public var backImg: UIImage?
    //nav share image
    public var shareImg: UIImage?
    //nav close string
    public var closeStr: String?

    //fetch app info
    public var fetchAppInfo: WebViewConfigClosure?
    //share action with data
    public var share: WebViewConfigClosure?
    //h5 fetch current language
    public var fetchLanguage: WebViewConfigClosure?

    
    //h5 fetch vite address
    public var fetchViteAddress: AsyncWebViewConfigClosure?
    //h5 invoke uri
    public var invokeUri: AsyncWebViewConfigClosure?
    public var isInvokingUri: Bool = false

    private init() {
        fetchAppInfo = { (_ data: [String: String]?) -> Response? in
            print(data)
            return nil
        }
        share = { (_ data: [String: String]?) -> Response? in
            print(data)
            return nil
        }
        fetchLanguage = { (_ data: [String: String]?) -> Response? in
            print(data)
            return nil
        }

        fetchViteAddress = { (_ data: [String: String]?,_ callbackId: String,_ callback:NativeCallback)  in
            print(data)
        }
        invokeUri = { (_ data: [String: String]?,_ callbackId: String,_ callback:NativeCallback)  in
            print(data)
        }
    }

}
