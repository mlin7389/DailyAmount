//
//  File.swift
//  aCh01
//
//  Created by user on 2022/3/19.
//

import Foundation

extension Int {
    
    func isBetween(_ number1:Int,_ number2:Int) -> Bool {
       
        var min = 0
        var max = 0
        
        if number1 > number2 {
            min = number2
            max = number1
        }
        else {
            min = number1
            max = number2
        }
        
        return (self >= min && self <= max)
    }
}
