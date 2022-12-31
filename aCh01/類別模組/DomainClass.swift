//
//  DomainClass.swift
//  aCh01
//
//  Created by user on 2022/3/5.
//

import Foundation

struct PickerName: Identifiable, Hashable {
    var id : String = UUID().uuidString
    var name : String = ""
    var count : Int = 1
    var order : Int = 0
    
    init(name:String) {
        self.name = name
    }
    
    init() {
 
    }
    
    var extraAmount : Int = 0
    var extraAmountString : String {
        get {
            return extraAmount == 0 ? "" : String(extraAmount)
        }
    }
}

struct SearchDate {
    let startDate:Date
    let endDate:Date
    let displayString:String
    init(d1:Date,d2:Date) {
        startDate = d1
        endDate = d2
        
        let fm = DateFormatter()
        fm.dateFormat = "yyyy/MM/dd"
        let s = fm.string(from: startDate)
        let e = fm.string(from: endDate)
        displayString = "\(s)～\(e)"
    }
}

class MGGSearchDate {

    static func CalculateDate(_ spDate:Date) -> [QuickPickerDate:SearchDate]{
 
        var components = DateComponents()
        var searchDateDic : [QuickPickerDate:SearchDate] = [:]

        //本日
        let s1 = SearchDate(d1:spDate,d2:spDate)
        searchDateDic.updateValue(s1, forKey: .Today)
        
        //昨日
        var dateComponent = DateComponents()
        dateComponent.day = -1
        let last_Date_1 = Calendar.current.date(byAdding: dateComponent, to: spDate)!
        let s8 = SearchDate(d1:last_Date_1,d2:last_Date_1)
        searchDateDic.updateValue(s8, forKey: .LastDay)
   
        //本週  星期一日期及星期日日期
        let startDateOfWeek = spDate.startOfWeek()
        let endDateOfWeek   = spDate.endOfWeek()
        let s2 = SearchDate(d1:startDateOfWeek , d2:endDateOfWeek)
        searchDateDic.updateValue(s2, forKey: .Week)

        //上週 星期一日期及星期日日期
        components.month = 0
        components.day = -2
        let lastWeekOfDate = Calendar.current.date(byAdding: components, to: startDateOfWeek)!
        let startDateOfLastWeek = lastWeekOfDate.startOfWeek()
        let endDateOfLastWeek = lastWeekOfDate.endOfWeek()
        let s3 = SearchDate(d1:startDateOfLastWeek , d2:endDateOfLastWeek)
        searchDateDic.updateValue(s3, forKey: .LastWeek)
        
        //計算近六個月的月初及月底
        var firstDateOfMonths: [Date] = []
        var lastDateOfMonths: [Date] = []
        
        let comp: DateComponents = Calendar.current.dateComponents([.year, .month], from: spDate)
        let startOfMonth = Calendar.current.date(from: comp)!
        firstDateOfMonths.append(startOfMonth)
        
        for index in 1...6 {
            components.month = index * -1
            components.day = 0
            let preMonthDate = Calendar.current.date(byAdding: components, to: startOfMonth)
            firstDateOfMonths.append(preMonthDate!)
        }
        
        components.month = 1
        components.day = -1
        
        firstDateOfMonths.forEach { dt in
            let preMonthDate = Calendar.current.date(byAdding: components, to: dt)
            lastDateOfMonths.append(preMonthDate!)
        }
        
        let s4 = SearchDate(d1:firstDateOfMonths[0] , d2:lastDateOfMonths[0])
        searchDateDic.updateValue(s4, forKey: .Month)
        
        let s5 = SearchDate(d1:firstDateOfMonths[1] , d2:lastDateOfMonths[1])
        searchDateDic.updateValue(s5, forKey: .LasMonth)
        
        
        //本年
        var comp2: DateComponents = Calendar.current.dateComponents([.year], from: spDate)
        let startOfYear = Calendar.current.date(from: comp2)!
        let EndOfLastYear = Calendar.current.date(byAdding: dateComponent, to: startOfYear)!
        
        comp2.year! += 1
        let startOfNextYear = Calendar.current.date(from: comp2)!
        let EndOfYear = Calendar.current.date(byAdding: dateComponent, to: startOfNextYear)!
       
        let s6 = SearchDate(d1:startOfYear , d2:EndOfYear)
        searchDateDic.updateValue(s6, forKey: .year)
        
        //去年
        comp2.year! -= 2
        let startOfLastYear = Calendar.current.date(from: comp2)!
        
        let s7 = SearchDate(d1:startOfLastYear , d2:EndOfLastYear)
        searchDateDic.updateValue(s7, forKey: .LastYear)
        
        return searchDateDic
    }

}

struct AmountHistory {
    var amount : Int = 0
    var count : Int = 0
    init(_ a:Int,_ c:Int) {
       amount = a
        count = c
    }
}


struct ExpenseItem: Identifiable, Hashable {
    var id : String = UUID().uuidString
    var itemName : String = ""
    var totalAmount : String = ""
    var isLastItem : Bool = false
    var isLastItem2 : Bool = false
    var subExpenseItems : [ExpenseItem] = []
    var extraName : String = ""
    var importIsCorrect:Bool = true
    
    var purhaseDate : Date = Date.now

    var purhaseDateString : String {
        get {
            let fm = DateFormatter()
            fm.dateFormat = "yyyy年MM月dd日 (EEEE)"
            fm.locale = Locale(identifier: "zh_TW")

            return fm.string(from: self.purhaseDate)
        }
    }
    
    var purhaseDateForDB: String {
        get {
            return ExpenseItem.purhaseDateForDBFormat(self.purhaseDate)
        }
    }
    
    static func purhaseDateForDBFormat(_ date:Date) -> String {
        let fm = DateFormatter()
        fm.dateFormat = "yyyy/MM/dd"
        return fm.string(from: date)
    }
    
    mutating func setPurhaseDateFromDB(dString:String) {
        let fm = DateFormatter()
        fm.dateFormat = "yyyy/MM/dd"
        self.purhaseDate = fm.date(from: dString) ?? Date.now
    }
    
    static func setPurhaseDateFromDB2(dString:String) -> Date {
        let fm = DateFormatter()
        fm.dateFormat = "yyyy/MM/dd"
        return fm.date(from: dString) ?? Date.now
    }
    
    
    var totalAmountInt : Int {
        get {
            return Int(totalAmount) ?? 0
        }
    }
    

}


struct Subscription : Identifiable, Hashable  {
    var id : String = UUID().uuidString
    var name : String = ""
    var amount : String = ""
    var avgOfMonthAmount : String = ""
    var typeOfAmount : String = "固定"
    var cycleNote : String = ""
    var cycleName : String = ""
    var seqOrder : Int = 0

    var amountInt : Int {
        get {
            return Int(amount) ?? 0
        }
    }
    var avgOfMonthAmountInt : Int {
        get {
            return Int(avgOfMonthAmount) ?? 0
        }
    }
    
    var typeOfAmount_display : String {
        get {
            if typeOfAmount == "固定" {
                return "固定"
            }
            else {
                return "預計"
            }
        }
    }
    
    var PayType : PayWay {
        get {
            if typeOfAmount == "固定" {
                return .Fixed
            }
            else {
                return .flexible
            }
        }
        
        set {
            if newValue == .Fixed {
                typeOfAmount = "固定"
            }
            else {
                typeOfAmount = "浮動"
            }
        }
    }

}

struct PickGroupExpenseItem : Hashable {
    var id = UUID().uuidString
    var name = ""
    var amount = 0
    init(name: String = "", amount: Int = 0) {
        self.name = name
        self.amount = amount
    }
}


enum PrintLevel {
    case ExecuteFlow
    case FilePath
    case Error
}

struct Trace {
    static func mPrint(_ text:Any,_ level:PrintLevel) {
#if DEBUG
        switch level {
        case .FilePath :
            print(text)
        case .Error :
            print(text)
        case .ExecuteFlow :
            break //  print(text)
        }
  
#endif
    }
}

