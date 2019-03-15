//
//  BigDecimal.swift
//  ViteBusiness
//
//  Created by Stone on 2019/3/15.
//

import BigInt

public struct BigDecimal {

    private let number: BigInt
    private let digits: Int
    private let rawString: String
    
    // +0
    // +0.1
    // -0.23
    // -1
    // +123

    // 目前输入不支持科学技术法
    public init?(_ string: String = "0") {

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




    private init?(number: BigInt, digits: Int) {
        guard digits >= 0 else { return nil }

        if number == 0 {
            self.number = number
            self.digits = 0
        } else if digits > 0 && number.description.hasSuffix("0") {
            let striped = String(("#" + number.description).trimmingCharacters(in: CharacterSet(charactersIn: "0")).dropFirst())
            let newDigits = digits - (number.description.count - striped.count)
            guard newDigits >= 0 else { return nil }
            guard let newNumber = BigInt(striped) else { return nil }
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

        guard let newBigDecimal = BigDecimal(number: number, digits: digits) else { fatalError() }
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
