//
//  SubscriptionModel.swift
//  aCh01
//
//  Created by user on 2022/3/4.
//

import Foundation

enum PayWay: String, CaseIterable {
    case Fixed  = "固定"
    case flexible = "浮動"
}

class SubscriptionModel : ObservableObject {
    
    @Published var selectSubItem : Subscription?

    @Published var sqlModel : SQLPorvider

    struct AvgSumOfMonth : Identifiable , Hashable {
        let id : String
        let avgAmount : Int
        let sumAmount : Int
        
        let avgAmountString : String
        let sumAmountString : String
        
        init(_ avgAmount:Int,_ avgAmountString:String,_ sumAmount:Int,_ sumAmountString:String) {
           id = UUID().uuidString
            self.avgAmount = avgAmount
            self.sumAmount = sumAmount
            self.avgAmountString = avgAmountString
            self.sumAmountString = sumAmountString
        }
    }

    
    @Published var totalAvgOfMonthAmount : Int
    @Published var totalAmount : Int
    @Published var subscriptionItem : Subscription
    @Published var errorMessageFlg : Bool
    var errorMessage : String

    var ViewModifyMode = false
    
    @Published var subscriptions: [Subscription]

    @Published var subscriptionRoot : [Subscription]
    @Published var subscriptionNames : [PickerName]
    @Published var cycleNames : [PickerName]
    
    @Published var dic = [String:[Subscription]]()
    
    func loadSubscriptionsByCycleGroup() {
       
        subscriptionRoot.removeAll()
        
        let names = sqlModel.querySubscriptionGroupByCycleName()
        for name in names {
            var sub = Subscription()
            sub.name = name
            sub.cycleName = name
            dic[name] = sqlModel.querySubscriptionByCycleName(name)
            if dic[name]!.count > 0 {
                
                var amt1 = 0
                var amt2 = 0
                for item in dic[name]! {
                    amt1 += item.avgOfMonthAmountInt
                    amt2 += item.amountInt
                }
                sub.avgOfMonthAmount = String(amt1)
                sub.amount = String(amt2)
                subscriptionRoot.append(sub)
            }
        }
        
    }
    

    init() {
        sqlModel = SQLPorvider.shared
        subscriptions = []
        subscriptionRoot = []
        subscriptionItem = Subscription()
        subscriptionNames = []
        cycleNames = []
        selectSubItem = Subscription()
        errorMessageFlg = false
        errorMessage = ""
        totalAvgOfMonthAmount = 0
        totalAmount = 0
        importMessage = ""
        subscriptions = sqlModel.querySubscription()
        reCalSubTotal()
        loadSubscriptionsByCycleGroup()
    }

    
    
    func loadCycleNames() {
        cycleNames = sqlModel.queryPickerNames(table: PickerNameTable.CycleName)
    }
    
    func reloadAllData() {
        subscriptions = sqlModel.querySubscription()
        loadSubscriptionsByCycleGroup()
        loadCycleNames()
    }
    
    func subscriptionViewAddSubItem() {

        if verifyEnterError() == true {
            return
        }
        
        sqlModel.insertSubscription(item: self.subscriptionItem)
        
        subscriptions = sqlModel.querySubscription()
        loadSubscriptionsByCycleGroup()
       
        sqlModel.insertPickerNameByName(table: PickerNameTable.CycleName, name: self.subscriptionItem.cycleName)
        
        self.subscriptionItem = Subscription()
        reCalSubTotal()
    }
    
    func reCalSubTotal() {
        totalAvgOfMonthAmount = 0
        totalAmount = 0
        for item in self.subscriptions {
            totalAvgOfMonthAmount += item.avgOfMonthAmountInt
            totalAmount += item.amountInt
        }
        
    }
    
    
    func DeleteItem(item: Subscription) {
        sqlModel.deleteSubscriptionByID(id: item.id)
       
        
        if let indexOfA = subscriptions.firstIndex(of: item) {
            subscriptions.remove(at: indexOfA)
        }
        loadSubscriptionsByCycleGroup()
        reCalSubTotal()
    }
    
    func UpdateItem(item: Subscription) {
        self.subscriptionItem = item
        ViewModifyMode = true
    }
    
    func updateSubName() {
        self.subscriptionItem.name = text_tmp
        text_tmp = ""
    }
    func updateCycleName() {
        self.subscriptionItem.cycleName = cycle_tmp
        cycle_tmp = ""
    }
    func updateAvgOfMonth(){
        self.subscriptionItem.avgOfMonthAmount = avgOfMonthAmount_tmp
        avgOfMonthAmount_tmp = ""
    }
    
    var text_tmp = ""
    func updateSubName(text: String) {
        text_tmp = text
       
    }
    var cycle_tmp = ""
    func updateCycleName(text: String) {
        cycle_tmp = text
    }
    
    var avgOfMonthAmount_tmp = ""
    func updateAvgOfMonth(text: String) {
        avgOfMonthAmount_tmp = text
    }
    
    
    var avgSumOfMonth : [AvgSumOfMonth] = []
    
    func listAvgOfMonth() {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal          // Set defaults to the formatter that are common for showing decimal numbers
        numberFormatter.usesGroupingSeparator = true    // Enabled separator
        numberFormatter.groupingSeparator = ","         // Set the separator to "," (e.g. 1000000 = 1,000,000)
        numberFormatter.groupingSize = 3                // Set the digits between each separator
        
        avgSumOfMonth = []
        for i in 1...36 {
            let am : Int = self.subscriptionItem.amountInt
            let avg : Int = am / i
            let sum : Int = am * i
            let amS : String = numberFormatter.string(for: am)!
            let avgS : String = numberFormatter.string(for: avg)!
            let sumS : String = numberFormatter.string(for: sum)!
            
            let av = AvgSumOfMonth(avg,"\(amS) ÷ \(i) = \(avgS)",sum,"\(amS) x \(i) = \(sumS)")
            avgSumOfMonth.append(av)
        }
    
    }

    
    func deleteCycleName(_ pickerName:PickerName) {
        sqlModel.deletePickerNameByName(table: PickerNameTable.CycleName, name: pickerName.name)
    }
    

    
    func move(from source: IndexSet, to destination: Int)  {
        self.subscriptions.move(fromOffsets: source, toOffset: destination)
  
        let max = subscriptions.count - 1
        var order = max
        for index in 0...max {
            sqlModel.updateSubscriptionSeqOrder(subscriptions[index].id,order)
            order -= 1
        }
       
    }
    
    func verifyEnterError() -> Bool {
        
        self.errorMessageFlg = false
        
        if self.subscriptionItem.amount == "" {
            self.errorMessage = "金額不可空白"
            self.errorMessageFlg = true
            return true
        }
        
        if self.subscriptionItem.amount.isNumber == false {
            self.errorMessage = "金額非數字"
            self.errorMessageFlg = true
            return true
        }
        
        if self.subscriptionItem.avgOfMonthAmount == "" {
            self.errorMessage = "每月支出金額不可空白"
            self.errorMessageFlg = true
            return true
        }
        
        if self.subscriptionItem.avgOfMonthAmount.isNumber == false {
            self.errorMessage = "每月支出金額非數字"
            self.errorMessageFlg = true
            return true
        }
        
        return false
    }
    
    // 陣列轉為csv
    func sourceSubscriptionsToCSV() -> String {

        var csvString : String = "項目名稱,固定或浮動,支付金額,月支出金額,週期,備註\n"

        let tmpSubscriptions = sqlModel.querySubscription()
        
        for item in tmpSubscriptions {

            let nameWithoutComma = item.name.replacingOccurrences(of: ",", with: "")
            
            let CycleNameWithoutComma = item.cycleName.replacingOccurrences(of: ",", with: "")
            let CycleNoteWithoutComma = item.cycleNote.replacingOccurrences(of: ",", with: "")

            csvString = csvString.appending("\(nameWithoutComma),\(item.typeOfAmount),\(item.amount),\(item.avgOfMonthAmount),\(CycleNameWithoutComma),\(CycleNoteWithoutComma)\n")
        }

       return csvString
    }
    
    @Published var importFormatCheck = true
    var importMessage : String {
        didSet {
            if importMessage != "" {
                importMessageToSubscriptions()
            }
        }
    }
    var importSubscriptions = [Subscription]()
    
    func importMessageToSubscriptions() {
        importFormatCheck = true
        importSubscriptions = [Subscription]()
        var rows = importMessage.components(separatedBy: "\n")
        rows.remove(at: 0)
        var seqOrder = 0
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count == 6 {
                var item = Subscription()
                item.name = columns[0]
                item.typeOfAmount = columns[1]
                
                if item.typeOfAmount != "固定" && item.typeOfAmount != "浮動"  {
                    item.typeOfAmount = "浮動"
                }
                
                item.amount = columns[2]
                item.avgOfMonthAmount = columns[3]
                item.cycleName = columns[4]
                item.cycleNote = columns[5]
                item.seqOrder = seqOrder
                seqOrder += 1
                importSubscriptions.append(item)
            }
          
        }

        if importSubscriptions.count == 0 {
            importFormatCheck = false
        }
        
    }
    
    func importActionAppend(_ onImporting:(Int) -> ()) {
        
        if importSubscriptions.count == 0 {
            return
        }

        importAction(onImporting)
    }
    
    func importActionReplace(_ onImporting:(Int) -> ()) {
        
        if importSubscriptions.count == 0 {
            return
        }
        
        sqlModel.deleteSubscriptions()
        sqlModel.deletePickerName(table: PickerNameTable.CycleName)
        
        importAction(onImporting)
    }
    
    func importAction(_ onImporting:(Int) -> ()) {
        
        //因為insert排序的號碼會越來越大，所以先進去的要最小
        let maxCnt = importSubscriptions.count - 1
        var cnt = 1
        for index in (0...maxCnt).reversed() {
            let item = importSubscriptions[index]
            sqlModel.insertSubscription(item: item)
            sqlModel.insertPickerNameByName(table: PickerNameTable.CycleName, name: item.cycleName)
            cnt += 1
        }
        
        importSubscriptions.removeAll()
        
    }
    
    func importActionAfter() {
        subscriptions = sqlModel.querySubscription()
        reCalSubTotal()
        loadSubscriptionsByCycleGroup()
    }
    

}
