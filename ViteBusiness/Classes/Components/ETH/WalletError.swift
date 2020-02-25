
public protocol ViteEthError: Error {

}

public extension ViteEthError where Self: RawRepresentable, Self.RawValue == String {

}

public enum WalletError: String , Error {
    public var id : Int  {
        switch self {
        case .accountDoesNotExist:
            return 110
        case .notEnoughBalance:
            return -35001
        default:
            return 120
        }
    }

    case accountDoesNotExist = "accountDoesNotExist"
    case invalidPath = "invalidPath"
    case invalidKey = "invalidKey"
    case invalidMnemonics = "invalidMnemonics"
    case invalidAddress = "invalidAddress"
    case malformedKeystore = "malformedKeystore"
    case networkFailure = "networkFailure"
    case conversionFailure = "conversionFailure"
    case notEnoughBalance = "notEnoughBalance"
    case contractFailure = "contractFailure"
    case unexpectedResult = "unexpectedResult"    
}

extension WalletError: CustomStringConvertible, CustomDebugStringConvertible {

    public func toString() -> String {
        return "eth" + rawValue
    }

    public var description: String {
        return toString()
    }

    public var localizedDescription: String {
        return rawValue
    }

    public var debugDescription: String {
        return toString()
    }
}
