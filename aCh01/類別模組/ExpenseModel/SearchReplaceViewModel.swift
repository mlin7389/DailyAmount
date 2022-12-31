//
//  SearchReplaceViewModel.swift
//  aCh01
//
//  Created by user on 2022/9/25.
//

import Foundation

extension ExpenseModel {
    func searchItemName()  {
        if self.replaceMinAmount.isNumber && self.replaceMaxAmount.isNumber  {
            searchResultItemNames = sqlModel.queryExpenseItemByBetweenAmount(name:replaceViewStr1,minAmount: Int(self.replaceMinAmount)!, maxAmount: Int(self.replaceMaxAmount)!, searchType: searchType)
        }
        else {
            searchResultItemNames = sqlModel.queryExpenseItemByName(replaceViewStr1, searchType)
        }
       
        searchResultCount = searchResultItemNames.count
    }
    
    func updateSearchItemName(_ item:ExpenseItem) {
        let indexOfA = searchResultItemNames.firstIndex(of: item)!
       searchResultItemNames.remove(at: indexOfA)
        searchResultCount = searchResultItemNames.count
    }
    
    
    func updateItemNames() {
        if searchResultItemNames.count > 0 {
            for i in 0...searchResultItemNames.count-1 {
                searchResultItemNames[i].itemName = replaceViewStr2
                sqlModel.updateExpenseItem(item: searchResultItemNames[i])
            }
            reloadAllExpenseViewItems(false)
        }
       
    }
}
