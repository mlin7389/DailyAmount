//
//  DetailViewModel.swift
//  aCh01
//
//  Created by user on 2022/9/25.
//

import Foundation

extension ExpenseModel {
 
    
    
    func detail_Order_DESCString() -> String {
        if sort_Field_Amount == true {
            return sort_Order_DESC == true ? "依金額【大到小】排序" : " 依金額【小到大】排序"
        }
        else {
            
            if self.detailViewGroupType == .GroupByName {
                return sort_Order_DESC == true ? "依【名稱】排序" : "依【名稱】排序"
            }
            else {
                return sort_Order_DESC == true ? "依日期【近到遠】排序" : "依日期【遠到近】排序"
            }
        }
    }
 
    func detail_Conditions_String1() -> String {
       
        let s3 = detailViewSelectDate1.DateStringType3()
        let s4 = detailViewSelectDate2.DateStringType3()

        return "\(s3) ~ \(s4)"
    }
    
    func detail_Conditions_String2() -> String {
  
        let s1 = detailViewGroupType.rawValue
        let s2 = detail_Order_DESCString()

        return "【\(s1)】\(s2)"
    }
    
    
    func detailViewItemsSortByName() {
        sort_Field_Amount = false
        
        sort_DetailViewItems()
    }
    
    func detailViewItemsSortByAmount() {
        sort_Field_Amount = true
        
        sort_DetailViewItems()
    }
    
    internal func sort_DetailViewItems() {
        
        if sort_Field_Amount == true {
            sort_FieldOfAmount()
        }
        else {
            sort_FieldOfName()
        }

    }
    
    private func sort_FieldOfAmount() {
        
        if sort_Order_DESC == true {  //大到小
            detailViewExpenseItems.sort {
                $0.totalAmountInt > $1.totalAmountInt
            }
        }
        else {
            detailViewExpenseItems.sort {
                $0.totalAmountInt < $1.totalAmountInt
            }
        }

    }
    
    private func sort_FieldOfName() {
        switch self.detailViewGroupType {
        case .List:
            sort_purhaseDateString()
        case .GroupByDate:
            sort_purhaseDateString()
        case .GroupByName:
            sort_itemName()
        }
    }
    
    private func sort_itemName() {

        if sort_Order_DESC == true {  //大到小
            detailViewExpenseItems.sort {
                $0.itemName > $1.itemName
            }
        }
        else {
            detailViewExpenseItems.sort {
                $0.itemName < $1.itemName
            }
        }
    }
    
    private func sort_purhaseDateString() {

        if sort_Order_DESC == true {
            detailViewExpenseItems.sort {  //大到小
                $0.purhaseDate > $1.purhaseDate
            }
        }
        else {
            detailViewExpenseItems.sort {
                $0.purhaseDate < $1.purhaseDate
            }
        }

    }
    
    ///重算輸入畫面合計金額
    func loadExpenseNames2(text:String = "")  {
        expenseNames2 = sqlModel.queryExpenseItemNames2(text)
    }

    
    func findFirstAndLastDate12() {
        mustReload = false
        detailViewSelectDate1 = sqlModel.queryExpenseItemSingleDate(.FirstDate)
        mustReload = true
        detailViewSelectDate2 = sqlModel.queryExpenseItemSingleDate(.LastDate)
    }
    
    func findFirstAndLastDate34() {
        mustReload = false
        groupViewSelectDate1 = sqlModel.queryExpenseItemSingleDate(.FirstDate)
        mustReload = true
        groupViewSelectDate2 = sqlModel.queryExpenseItemSingleDate(.LastDate)
    }
    
 

    func reloadDeatilViewExpenseItems() {
        detailViewExpenseItems = []
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.srchItemName == "" {
                if self.srchMinAmount.isNumber && self.srchMaxAmount.isNumber  {
                    self.detailViewExpenseItems =  self.sqlModel.queryExpenseItemByBetweenDateAmount(startDate:  self.detailViewSelectDate1,
                                                                                               endDate:  self.detailViewSelectDate2,
                                                                                          minAmount: Int(self.srchMinAmount)!,
                                                                                          maxAmount: Int(self.srchMaxAmount)!,
                                                                                          displayType: self.detailViewGroupType)
                }
                else {
                    self.detailViewExpenseItems =  self.sqlModel.queryExpenseItemByBetweenDate( self.detailViewSelectDate1,  self.detailViewSelectDate2,self.detailViewGroupType)
                }
            }
            else {
                if self.srchMinAmount.isNumber && self.srchMaxAmount.isNumber  {
                    self.detailViewExpenseItems =  self.sqlModel.queryExpenseItemByBetweenDateNameAmount(startDate:  self.detailViewSelectDate1,
                                                                                                   endDate:  self.detailViewSelectDate2,
                                                                                             itemName: self.srchItemName,
                                                                                             minAmount: Int(self.srchMinAmount)!,
                                                                                             maxAmount: Int(self.srchMaxAmount)!,
                                                                                             displayType: self.detailViewGroupType)
                }
                else {
                    self.detailViewExpenseItems = self.sqlModel.queryExpenseItemByBetweenDateName(startDate:  self.detailViewSelectDate1,
                                                                                        endDate:  self.detailViewSelectDate2,
                                                                                        itemName: self.srchItemName,
                                                                                        displayType: self.detailViewGroupType)
                }
            }
            
            self.sort_DetailViewItems()
        }
        
    }
    
    func detailViewPurhaseDateString(item: ExpenseItem,displayType:ExpenseDetailGroupType) -> String {
        switch displayType {
        case .List:
            return item.purhaseDateString
        case .GroupByDate:
            return "..."
        case .GroupByName:
            return "..."
        }
    }
    
    func detailViewItemName(item: ExpenseItem,displayType:ExpenseDetailGroupType) -> String {
        
        switch displayType {
        case .List:
            return item.itemName
        case .GroupByDate:
            return item.purhaseDateString
        case .GroupByName:
            return item.itemName
        }
    }
    
    //重算明細合計金額
    func reCalDetailViewSubTotal() {
        
        detailViewSubtotal = 0
        
        for item in self.detailViewExpenseItems {
            let am = Int(item.totalAmount) ?? 0
            detailViewSubtotal += am
        }
        if self.detailViewExpenseItems.count >= 1 {
            detailViewAvg = detailViewSubtotal / self.detailViewExpenseItems.count
        }
        else {
            detailViewAvg = 0
        }
        
    }
    
    func raloadDetailItems(_ item:ExpenseItem) {
        Trace.mPrint("raloadDetailItems", .ExecuteFlow)
        switch detailViewGroupType {
        case .List:
            dsViewExpenseItems = subDetail1(it:item)
        case .GroupByDate:
            subDetail2(it:item)
        case .GroupByName:
            subDetail3(it:item)
        }
    }
    
    func subDetail1(it:ExpenseItem) -> [ExpenseItem] {
        Trace.mPrint("ini subDetail1", .ExecuteFlow)
        var items : [ExpenseItem] = []
        items.append(it)
        return items
    }
    
    func subDetail2(it:ExpenseItem)  {
        Trace.mPrint("ini subDetail2", .ExecuteFlow)
        dsViewExpenseItems = []
        
        if self.srchItemName == "" {
            if self.srchMinAmount.isNumber && self.srchMaxAmount.isNumber  {
                dsViewExpenseItems = sqlModel.queryExpenseItemByBetweenDateAmount(startDate: it.purhaseDate,
                                                                                      endDate: it.purhaseDate,
                                                                                      minAmount: Int(self.srchMinAmount)!,
                                                                                      maxAmount: Int(self.srchMaxAmount)!,
                                                                                      displayType: .List)
            }
            else {
                dsViewExpenseItems = sqlModel.queryExpenseItemByBetweenDate(it.purhaseDate, it.purhaseDate,.List)
            }
        }
        else {
            if self.srchMinAmount.isNumber && self.srchMaxAmount.isNumber  {
                dsViewExpenseItems = sqlModel.queryExpenseItemByBetweenDateNameAmount(startDate: it.purhaseDate,
                                                                                         endDate: it.purhaseDate,
                                                                                         itemName: self.srchItemName,
                                                                                         minAmount: Int(self.srchMinAmount)!,
                                                                                         maxAmount: Int(self.srchMaxAmount)!,
                                                                                         displayType: .List)
            }
            else {
                dsViewExpenseItems = sqlModel.queryExpenseItemByBetweenDateName(startDate: it.purhaseDate,
                                                                                    endDate: it.purhaseDate,
                                                                                    itemName: self.srchItemName,
                                                                                    displayType: .List)
            }
        }
       
        detailSubViewSubtotal = 0
   
        for item in dsViewExpenseItems {
            let am = Int(item.totalAmount) ?? 0
            detailSubViewSubtotal += am
        }

     
    }
    
    func subDetail3(it:ExpenseItem) {
        Trace.mPrint("ini subDetail3", .ExecuteFlow)
        
        dsViewExpenseItems = []
        
        if self.srchMinAmount.isNumber && self.srchMaxAmount.isNumber  {
            dsViewExpenseItems = sqlModel.queryExpenseItemByBetweenDateNameAmount(startDate: detailViewSelectDate1,
                                                                                     endDate: detailViewSelectDate2,
                                                                                     itemName: it.itemName,
                                                                                     minAmount: Int(self.srchMinAmount)!,
                                                                                     maxAmount: Int(self.srchMaxAmount)!,
                                                                                  displayType: .List)
        }
        else {
            dsViewExpenseItems = sqlModel.queryExpenseItemByBetweenDateName(startDate: detailViewSelectDate1,
                                                                                endDate: detailViewSelectDate2,
                                                                                itemName: it.itemName,
                                                                                displayType: .List)
        }
        
        detailSubViewSubtotal = 0
   
        for item in dsViewExpenseItems {
            let am = Int(item.totalAmount) ?? 0
            detailSubViewSubtotal += am
        }
    }
    
    
    func queryExpenseItemByName(_ name:String)  {
        subscriptionViewExpenseItems = sqlModel.queryExpenseItemByName(name,.FullSearch)
        
        subExpensetItemSubtotal = 0
        
        for item in self.subscriptionViewExpenseItems {
            let am = Int(item.totalAmount) ?? 0
            subExpensetItemSubtotal += am
        }
        if self.subscriptionViewExpenseItems.count >= 1 {
            subExpenseItemAvg = subExpensetItemSubtotal / self.subscriptionViewExpenseItems.count
        }
        else {
            subExpenseItemAvg = 0
        }
    }
}
