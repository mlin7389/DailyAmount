//
//  exDate.swift
//  SwiftDemo01
//
//  Created by Marty Lin on 2020/2/17.
//  Copyright © 2020 swift. All rights reserved.
//
import Foundation

extension Date {

    //MARK: -  Static Func
    //MARK: -
    
    static func withoutTime() -> Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let date = Calendar.current.date(from: components)
        return date!
    }
    
    static func dateFrom(year: Int, month: Int, day: Int) -> Date? {
        let calendar = Calendar(identifier: .gregorian)
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = day
        return calendar.date(from: dateComponents) ?? nil
    }
    
    static func date_StringDateToDate(stringDate:String, formatString:String) -> Date? {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatString
        
        if let date = dateFormatterGet.date(from: stringDate) {
            return date
        } else {
            Trace.mPrint("日期字串轉換失敗 \(stringDate) -> \(formatString)", .Error)
            return nil
        }
        
    }
    
    static func date_DateToStringDate(inputDate:Date, formatString:String) -> String? {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = formatString
        
        let df:String? = dateFormatterGet.string(from: inputDate)
        if let date = df {
            return date
        } else {
            Trace.mPrint("日期轉換字串失敗 \(inputDate) -> \(formatString)", .Error)
            return nil
        }
    }
    
    
    //MARK: -  Public Func
    //MARK: -
    
    func startOfWeek() -> Date {
        let gregorian = Calendar(identifier: .iso8601)  // iso8601 週的起始是星期一    gregorian 週的起始是星期日
        let monday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return monday!
    }
    
    func endOfWeek() -> Date {
        let gregorian = Calendar(identifier: .iso8601) // iso8601 週的起始是星期一    gregorian 週的起始是星期日
        let sunday = gregorian.date(from: gregorian.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))
        return gregorian.date(byAdding: .day, value: 6, to: sunday!)!
    }
    
    func numberOfDaysInCurrentMonth() -> Int {
        let cal = Calendar(identifier: .gregorian)
        let monthRange = cal.range(of: .day, in: .month, for: self)!
        let daysInMonth = monthRange.count
        return daysInMonth
    }
    
    
    
    func date_ToYearMonthDay(isROC_Year:Bool) -> (Int,Int,Int) {
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        
        var year2 = year
        if (isROC_Year == true) {
            year2 = year2 - 1911
        }
        
        return (year2,month,day)
    }
    
    func WeekNameOfChinese() -> String {
        
        let weekDay =  Calendar.current.component(.weekday, from: self)
        
        switch weekDay {
        case 2:
            return "星期一"
        case 3:
            return "星期二"
        case 4:
            return "星期三"
        case 5:
            return "星期四"
        case 6:
            return "星期五"
        case 7:
            return "星期六"
        case 1:
            return "星期日"
        default:
            return ""
        }
    }
    
    func MonthNameOfChinese() -> String {
        
        let month =  Calendar.current.component(.month, from: self)
        
        switch month {
        case 1:
            return "一月"
        case 2:
            return "二月"
        case 3:
            return "三月"
        case 4:
            return "四月"
        case 5:
            return "五月"
        case 6:
            return "六月"
        case 7:
            return "七月"
        case 8:
            return "八月"
        case 9:
            return "九月"
        case 10:
            return "十月"
        case 11:
            return "十一月"
        case 12:
            return "十二月"
        default:
            return ""
        }
    }

}
