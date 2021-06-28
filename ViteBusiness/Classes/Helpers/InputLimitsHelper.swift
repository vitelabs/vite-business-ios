//
//  InputLimitsHelper.swift
//  Vite
//
//  Created by Stone on 2018/9/27.
//  Copyright © 2018年 vite labs. All rights reserved.
//

import Foundation

struct InputLimitsHelper {

    static func allowText(_ text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String, maxCount: Int) -> Bool {
        if string.isEmpty {
            return true
        } else {
            let str = (text as NSString).substring(with: range)
            return text.utf8.count + string.utf8.count - str.utf8.count <= maxCount
        }
    }
    
    static func canDecimalPointWithDigitalText(_ text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String, decimals: Int) -> Bool {
        var t = (text as NSString).replacingCharacters(in: range, with: string)
        
        t = t.replacingOccurrences(of: ",", with: ".")
        
        let array = t.split(separator: ".", omittingEmptySubsequences: false)
        
        if array.count == 0 {
            return true
        } else if array.count == 1 {
            if array[0].isEmpty {
                return true
            }
            
            if let _ = Int(array[0]) {
                return true
            } else {
                return false
            }
            
        } else if array.count == 2 {
            guard let _ = Int(array[0]) else {
                return false
            }
            
            if array[1].isEmpty {
                return true
            }
            
            guard let _ = Int(array[1]) else {
                return false
            }
            
            if array[1].count <= decimals {
                return true
            } else {
                return false
            }
            
        } else {
            return false
        }
    }

    static func allowDecimalPointWithDigitalText(_ text: String, shouldChangeCharactersIn range: NSRange, replacementString string: String, decimals: Int) -> (Bool, String) {

        if string.count > 1 {
            (text as NSString).replacingCharacters(in: range, with: "")
            return (false, text)
        }

        let replacedText = text.replacingOccurrences(of: ",", with: ".")
        let string = string.replacingOccurrences(of: ",", with: ".")

        var isHaveDian = (replacedText as NSString).range(of: ".").location != NSNotFound

        if let single = string.first {
            let numbers = Character("0")...Character("9")
            if numbers.contains(single) || single == "." {

                if decimals == 0 {
                    if single == "." {
                        return (false, text)
                    }

                    if replacedText.isEmpty && single == "0" {
                        return (false, text)
                    }
                }

                if replacedText.isEmpty {
                    if single == "." {
                        return (false, text)
                    }
                } else if replacedText.count == 1 {
                    if replacedText == "0" && single != "." {
                        return (false, text)
                    }
                }

                if single == "." {

                    if isHaveDian {
                        return (false, text)
                    } else {
                        isHaveDian = true
                        return (true, text)
                    }

                } else {

                    if isHaveDian {
                        let ran = (replacedText as NSString).range(of: ".")
                        let tt = range.location - ran.location
                        if tt <= decimals {
                            return (true, text)
                        } else {
                            return (false, text)
                        }
                    } else {
                        return (true, text)
                    }
                }

            } else {
                return (false, text)
            }
        } else {
            return (true, text)
        }
    }
}
