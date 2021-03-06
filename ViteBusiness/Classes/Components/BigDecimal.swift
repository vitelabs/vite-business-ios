//
//  BigDecimal.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/15.
//

import BigInt

public struct BigDecimal: Equatable, Comparable {

    public let number: BigInt
    public let digits: Int
    private let rawString: String

    public static func == (lhs: BigDecimal, rhs: BigDecimal) -> Bool {
        lhs.number == rhs.number && lhs.digits == rhs.digits
    }

    public static func < (lhs: BigDecimal, rhs: BigDecimal) -> Bool {
        if lhs.digits > rhs.digits {
            return lhs.number < rhs.number * BigInt(10).power(lhs.digits - rhs.digits)
        } else if lhs.digits < rhs.digits {
            return lhs.number * BigInt(10).power(rhs.digits - lhs.digits) < rhs.number
        } else {
            return lhs.number < rhs.number
        }
    }
    
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

        if number == 0 {
            self.number = BigInt(0)
            self.digits = 0
        } else if digits < 0 {
            self.number = number * BigInt(10).power(-digits)
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

public extension BigDecimal {
    func ceil() -> BigInt {
        if self.digits == 0 {
            return self.number
        } else {
            let (q, r) = self.number.quotientAndRemainder(dividingBy: BigInt(10).power(digits))
            if r == 0 {
                return q
            } else {
                return q + 1
            }
        }
    }

    func floor() -> BigInt {
        if self.digits == 0 {
            return self.number
        } else {
            let (q, _) = self.number.quotientAndRemainder(dividingBy: BigInt(10).power(digits))
            return q
        }
    }

    func round() -> BigInt {
        let bigDecimal = self + BigDecimal("0.5")!
        return bigDecimal.floor()
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

    public enum Options {
        case groupSeparator
    }

    public enum Style {
        case decimalRound(Int)
        case decimalTruncation(Int)
    }

    public enum Padding {
        case none
        case padding
    }

    // -1000.0000, 1000, 1
    static private func addGroupSeparator(_ string: String) -> String {

        let absolute: String
        let symbol: String
        if string.hasPrefix("-") {
            symbol = "-"
            absolute = String(string.dropFirst())
        } else {
            symbol = ""
            absolute = string
        }

        let array = absolute.components(separatedBy: ".")
        let integer = array[0]

        var ret = ""
        for (index, c) in integer.reversed().enumerated() {
            if index > 0 && index % 3 == 0 {
                ret = ret + ","
            }
            ret = ret + String(c)
        }

        if array.count == 1 {
            return symbol + String(ret.reversed())
        } else if array.count == 2 {
            return symbol + String(ret.reversed()) + "." + array[1]
        } else {
            fatalError()
        }
    }

    public static func format(bigDecimal: BigDecimal, style: Style, padding: Padding, options: [Options]) -> String {

        let decimal: Int
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

            if ret.digits > decimal {
                ret = BigDecimal(String(ret.description.dropLast(ret.digits - decimal)))!
            }
        } else {
            ret = bigDecimal
        }

        let text: String
        switch padding {
        case .none:
            text = ret.description
        case .padding:
            if ret.digits < decimal {
                if ret.digits == 0 {
                    text = ret.description + "." + "".padding(toLength: decimal - ret.digits, withPad: "0", startingAt: 0)
                } else {
                    text = ret.description + "".padding(toLength: decimal - ret.digits, withPad: "0", startingAt: 0)
                }
            } else {
                text = ret.description
            }
        }

        if options.contains(.groupSeparator) {
            return addGroupSeparator(text)
        } else {
            return text
        }
    }
}
