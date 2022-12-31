//
//  PickNamesModel.swift
//  aCh01
//
//  Created by user on 2022/9/25.
//

import Foundation

extension ExpenseModel {
    
    func loadExpensePickerNames() {
        
        if let _ = Int(searchItemAmountIsText) {
            self.loadExpensePickerNames(text: searchItemNameContainText,amount:searchItemAmountIsText)
        }
        else {
            self.loadExpensePickerNames(text: searchItemNameContainText,amount:"")
        }
    }
    
    func loadExpensePickerNames(text:String = "",amount:String)  {
    
        if text == "" && amount == "" {
            expenseItemNames = sqlModel.queryExpenseItemNames(text,autoAmountCount)
        }
        else  if text != "" && amount == "" {
            expenseItemNames = sqlModel.queryExpenseItemNames(text,autoAmountCount)
        }
        else  if text == "" && amount != "" {
            let amt = Int(amount) ?? 0
            expenseItemNames = sqlModel.queryExpenseItemNameAmount(amt, "")
        }
        else  {
            let amt = Int(amount) ?? 0
            expenseItemNames = sqlModel.queryExpenseItemNameAmount(amt, text)
        }

    }
    
    
    func pickGroupNameAddExpenseItems() {

        self.groupInsertCount = 0
        for item in self.pickGroupNames {
            var e = ExpenseItem()
            e.itemName = item.name
            e.totalAmount  = String(item.amount)
            e.purhaseDate = self.enterViewSelectedDate
            sqlModel.insertExpenseItem(item: e)
            self.groupInsertCount += 1
        }

        reloadAllExpenseViewItems(false)
        self.enterViewModifyMode = false
    }
}
