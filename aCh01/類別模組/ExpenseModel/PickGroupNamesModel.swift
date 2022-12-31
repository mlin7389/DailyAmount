//
//  PickGroupNamesModel.swift
//  aCh01
//
//  Created by user on 2022/10/1.
//

import Foundation

extension ExpenseModel {
 
    func deletePickGroupName(item: PickGroupExpenseItem) {
        let indexOfA = pickGroupNames.firstIndex(of: item)!
        pickGroupNames.remove(at: indexOfA)
        sqlModel.deletePickerGroupName(item: item)
    }
        
    func queryPickGroupName() {
        pickGroupNames = sqlModel.queryPickerGroupNames()

    }
    
    func insertPickGroupName(item:PickerName) {
        var gItem = PickGroupExpenseItem()
        gItem.name = item.name
        gItem.amount = item.extraAmount
        
        sqlModel.insertPickerGroupName(item: gItem)
        self.pickGroupNames.insert(gItem, at: 0)
        

    }
    
    
}
