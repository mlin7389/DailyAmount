//
//  Date.swift
//  aCh01
//
//  Created by user on 2022/3/2.
//

import Foundation

extension Date {
    
    
    

    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        let components0 = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let dateC = Calendar.current.date(from: components0)!
        
        let components1 = Calendar.current.dateComponents([.year, .month, .day], from: date1)
        let dateA = Calendar.current.date(from: components1)!
        
        let components2 = Calendar.current.dateComponents([.year, .month, .day], from: date2)
        let dateB = Calendar.current.date(from: components2)!
        
        return (min(dateA, dateB) ... max(dateA, dateB)).contains(dateC)
    }
    
    func isSameDate(_ date1: Date) -> Bool {
        
        let components1 = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let dateA = Calendar.current.date(from: components1)!
        
        let components2 = Calendar.current.dateComponents([.year, .month, .day], from: date1)
        let dateB = Calendar.current.date(from: components2)!
        
        return Calendar.current.isDate(dateA, inSameDayAs: dateB)
    }
    
    func isNotSameDate(_ date1: Date) -> Bool {
        return !isSameDate(date1)
    }
    
    func DateStringType1() -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyyMMdd"
        return dateFormatterGet.string(from: self)
    }
    
    func DateStringType2() -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy/MM/dd"
        return dateFormatterGet.string(from: self)
    }
    
    func DateStringType3() -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy/MM/dd (EEEE)"
        return dateFormatterGet.string(from: self)
    }
    
    static func DateStringType2ToDate(dateString:String) -> Date {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy/MM/dd"
        return dateFormatterGet.date(from: dateString) ?? Date()
    }
    
    func InsertDateTimeForDB() -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy/MM/dd HH:mm:ss SSSS"
        return dateFormatterGet.string(from: self)
    }
    
}
