//
//  EnterViewModel.swift
//  aCh01
//
//  Created by user on 2022/9/25.
//

import Foundation

extension ExpenseModel {
    
    func verifyEnterError() -> Bool {
        if self.enterViewExpenseItem.itemName == "" {
            self.newItemErrorMessage = "項目名稱不可空白"
            self.newItemErrorMessageFlg = true
            return true
        }
        
        if self.enterViewExpenseItem.totalAmount == "" {
            self.newItemErrorMessage = "金額不可空白"
            self.newItemErrorMessageFlg = true
            return true
        }
        
        if self.enterViewExpenseItem.totalAmount.isNumber == false {
            self.newItemErrorMessage = "金額非數字"
            self.newItemErrorMessageFlg = true
            return true
        }
        
        return false
    }
    
    func reloadEnterViewExpenseItems() {
        enterViewExpenseItems = sqlModel.queryExpenseItemByBetweenDate(enterViewSelectedDate, enterViewSelectedDate,.List)
    }
    
    func reloadAllExpenseViewItems(_ chgDBSource:Bool) {
        
        if self.quickPickerDate == .allDays {
            detailViewSelectDate1 = sqlModel.queryExpenseItemSingleDate(.FirstDate)
            detailViewSelectDate2 = sqlModel.queryExpenseItemSingleDate(.LastDate)
        }
        
        if self.quickPickerDate2 == .allDays {
            groupViewSelectDate1 = sqlModel.queryExpenseItemSingleDate(.FirstDate)
            groupViewSelectDate2 = sqlModel.queryExpenseItemSingleDate(.LastDate)
        }

        reloadEnterViewExpenseItems()
        
        reloadDeatilViewExpenseItems()
        
        reloadGroupExpenseData()
        
        queryPickGroupName()
        
    }
    
    func enterViewAddExpenseItem() {
        

        if verifyEnterError() == true {
            return
        }
        
        sqlModel.insertExpenseItem(item: enterViewExpenseItem)
        
        reloadAllExpenseViewItems(false)
        
        let da = self.enterViewExpenseItem.purhaseDate
        self.enterViewExpenseItem = ExpenseItem()
        self.enterViewExpenseItem.purhaseDate = da
        self.enterViewModifyMode = false
        
        
        if  UserDefaults.standard.bool(forKey: SettingNames.firstTimeAdd.rawValue) == false {
            self.newItemErrorMessage = "左右滑到底可刪除或修改"
            self.newItemErrorMessageFlg = true
            
            UserDefaults.standard.set(true, forKey: SettingNames.firstTimeAdd.rawValue)
            UserDefaults.standard.synchronize()
        }

    }
    
    func enterViewDeleteItem(item: ExpenseItem) {
        
        sqlModel.deleteExpenseItemByID(id: item.id)
        
        let indexOfA = enterViewExpenseItems.firstIndex(of: item)!
        enterViewExpenseItems.remove(at: indexOfA)
        
        reloadDeatilViewExpenseItems()
        reloadGroupExpenseData()
    }
    
    func enterViewPutItemToUpdateMode(item: ExpenseItem) {
        self.enterViewExpenseItem = item
        enterViewModifyMode = true
    }
    
    func enterViewUpdateExpenseItemText(selectText: String) {
        self.enterViewExpenseItem.itemName = selectText
    }
    
    

    func enterViewUpdateExpenseItemAmount(amount: Int)  {
        self.enterViewExpenseItem.totalAmount = String(amount)
    }

    ///重算輸入畫面合計金額
    func reCalEnterViewSubTotal() {
        enterViewSubtotal = 0

        for item in self.enterViewExpenseItems {
            let am = Int(item.totalAmount) ?? 0
            enterViewSubtotal += am
        }
    }
    

}
