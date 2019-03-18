//
//  BigDecimal.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/15.
//

import BigInt

public struct BigDecimal {

    public let number: BigInt
    public let digits: Int
    private let rawString: String
    
    // +0
    // +0.1
    // -0.23
    // -1
    // +123

    // 目前输入不支持科学技术法
    public init?(_ string: String) {

        let separators = CharacterSet(charactersIn: ".,")
        let components = string.components(separatedBy: separators)
        guard components.count == 1 || components.count == 2 else { return nil }

        var symbol = ""
        var beforeDecPoint = ""
        var afterDecPoint = ""

        if components[0].hasPrefix("+") {
            beforeDecPoint = String(components[0].dropFirst())
        } else if components[0].hasPrefix("-") {
            symbol = "-"
            beforeDecPoint = String(components[0].dropFirst())
        } else {
            beforeDecPoint = components[0]
        }

        if components.count == 2 {
            afterDecPoint = components[1]
        }

        guard beforeDecPoint.trimmingCharacters(in: .decimalDigits).isEmpty else { return nil }
        guard afterDecPoint.trimmingCharacters(in: .decimalDigits).isEmpty else { return nil }

        beforeDecPoint = String((beforeDecPoint + "#").trimmingCharacters(in: CharacterSet(charactersIn: "0")).dropLast())
        afterDecPoint = String(("#" + afterDecPoint).trimmingCharacters(in: CharacterSet(charactersIn: "0")).dropFirst())

        var text = beforeDecPoint + afterDecPoint
        if text.isEmpty {
            text = "0"
        } else {
            text = symbol + text
        }

        guard let n = BigInt(text) else { return nil }

        number = n
        digits = afterDecPoint.count

        rawString = string
    }

    public init(_ bigInt: BigInt = BigInt(0)) {
        self.number = bigInt
        self.digits = 0
        self.rawString = "bigInt: \(number)"
    }


    public static func + (left: BigDecimal, right: BigDecimal) -> BigDecimal {
        return operation(left: left, right: right, op: .add)
    }

    public static func - (left: BigDecimal, right: BigDecimal) -> BigDecimal {
        return operation(left: left, right: right, op: .subtract)
    }

    public static func * (left: BigDecimal, right: BigDecimal) -> BigDecimal {
        return operation(left: left, right: right, op: .multiply)
    }

    public static func / (left: BigDecimal, right: BigDecimal) -> BigDecimal {
        return operation(left: left, right: right, op: .divide)
    }

    public init(number: BigInt, digits: Int) {
        guard digits >= 0 else { fatalError() }

        if number == 0 {
            self.number = number
            self.digits = 0
        } else if digits > 0 && number.description.hasSuffix("0") {
            var striped = String(("#" + number.description).trimmingCharacters(in: CharacterSet(charactersIn: "0")).dropFirst())
            var newDigits = digits - (number.description.count - striped.count)
            if newDigits < 0 {
                striped = striped + "".padding(toLength: -newDigits, withPad: "0", startingAt: 0)
                newDigits = 0
            }
            guard let newNumber = BigInt(striped) else { fatalError() }
            self.number = newNumber
            self.digits = newDigits
        } else {
            self.number = number
            self.digits = digits
        }

        self.rawString = "number: \(number) digits: \(digits)"
    }

    private enum Operator {
        case add
        case subtract
        case multiply
        case divide
    }

    private static let dividePrecision = 20

    private static func operation(left: BigDecimal, right: BigDecimal, op: Operator) -> BigDecimal {

        var leftNumber: BigInt!
        var rightNumber: BigInt!
        var number: BigInt!
        var digits: Int!

        switch op {
        case .add, .subtract:
            if left.digits > right.digits {
                leftNumber = left.number
                rightNumber = right.number * BigInt(10).power(left.digits - right.digits)
                digits = left.digits
            } else if left.digits < right.digits {
                leftNumber = left.number * BigInt(10).power(right.digits - left.digits)
                rightNumber = right.number
                digits = right.digits
            } else {
                leftNumber = left.number
                rightNumber = right.number
                digits = left.digits
            }
        case .multiply, .divide:
            leftNumber = left.number
            rightNumber = right.number
        }

        switch op {
        case .add:
            number = leftNumber + rightNumber
        case .subtract:
            number = leftNumber - rightNumber
        case .multiply:
            digits = left.digits + right.digits
            number = leftNumber * rightNumber
        case .divide:
            digits = left.digits - right.digits
            if digits < 0 {
                leftNumber = leftNumber * BigInt(10).power(-digits)
                digits = 0
            }

            leftNumber = leftNumber * BigInt(10).power(BigDecimal.dividePrecision)
            number = leftNumber / rightNumber
            digits = digits + BigDecimal.dividePrecision
        }

        let newBigDecimal = BigDecimal(number: number, digits: digits)
        return newBigDecimal
    }

}

extension BigDecimal: CustomStringConvertible {

    public var description: String {

        if digits == 0 {
            return number.description
        }

        var symbol = ""
        var text = number.description

        if text.hasPrefix("-") {
            symbol = "-"
            text = String(text.dropFirst())
        }

        if text.count <= digits {
            let padding = "".padding(toLength: digits + 1 - text.count, withPad: "0", startingAt: 0)
            text = padding + text
        }

        let index = text.index(text.endIndex, offsetBy: -digits)
        text.insert(Character("."), at: index)

        return symbol + text
    }
}

public struct BigDecimalFormatter {

    public enum Style {
        case decimalRound(Int)
        case decimalTruncation(Int)
    }

    public enum Padding {
        case none
        case padding
    }

    static func format(bigDecimal: BigDecimal, style: Style, padding: Padding) -> String {

        var decimal: Int!
        switch style {
        case .decimalRound(let d):
            decimal = d
        case .decimalTruncation(let d):
            decimal = d
        }

        var ret: BigDecimal!
        if bigDecimal.digits > decimal {
            switch style {
            case .decimalRound:
                ret = bigDecimal + BigDecimal(number: BigInt(5), digits: decimal + 1)
            case .decimalTruncation:
                ret = bigDecimal
            }

            ret = BigDecimal(String(ret.description.dropLast(ret.digits - decimal)))!
        } else {
            ret = bigDecimal
        }

        switch padding {
        case .none:
            return ret.description
        case .padding:
            if ret.digits < decimal {
                if ret.digits == 0 {
                    return ret.description + "." + "".padding(toLength: decimal - ret.digits, withPad: "0", startingAt: 0)
                } else {
                    return ret.description + "".padding(toLength: decimal - ret.digits, withPad: "0", startingAt: 0)
                }
            } else {
                return ret.description
            }
        }
    }
}
