//
//  ImportExortModel.swift
//  aCh01
//
//  Created by user on 2022/9/25.
//

import Foundation

extension ExpenseModel {
    func exportExpenseItems() -> String{
       
        var csvString : String = "日期,項目,金額\n"
        
        let dateFormatterGet = DateFormatter()
        
        let tmpExpenseItems = sqlModel.queryExpenseItem()
        for item in tmpExpenseItems {
            dateFormatterGet.dateFormat = "yyyy/MM/dd"
            let dateString = dateFormatterGet.string(from:  item.purhaseDate)
      
            let newString = item.itemName.replacingOccurrences(of: ",", with: "")

            csvString = csvString.appending("\(dateString),\(newString),\(item.totalAmount)\n")
        }
        
        return csvString
    }
    
 
    
   
    //轉換csv檔案為ExpenseItem陣列，顯示於畫面
    func importMessageToExpenseItems() {
        importFormatCheck = true
        importExpenseItems = [ExpenseItem]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        
        var rows = importMessage.components(separatedBy: "\n")
        rows.remove(at: 0)
        do {
            for row in rows {
                let columns = row.components(separatedBy: ",")
              
                if columns.count == 3 {
                    var item = ExpenseItem()
                    
                    guard let date_temp = dateFormatter.date(from: columns[0]) else {
                        throw DateFormatError.dateFormatError
                    }
                    
                    item.purhaseDate = date_temp
                    item.itemName = columns[1]
                    item.totalAmount = columns[2].components(separatedBy: "\r").first!
                    
                    importExpenseItems.append(item)
                }
                
            }
        }
        catch {
            Trace.mPrint(error.localizedDescription, .Error)
            importFormatCheck = false
        }
        
        if importExpenseItems.count == 0 {
            importFormatCheck = false
        }
        
    }
    
    //匯入的資料，以append的方式匯入
    func importActionAppend(_ onImporting:(Int) -> ()) {
        
        if importExpenseItems.count == 0 {
            return
        }

        importAction(onImporting)
    }
    
    //匯入的資料，以全取取代的方式匯入
    func importActionReplace(_ onImporting:(Int) -> ()) {
        
        if importExpenseItems.count == 0 {
            return
        }
        
        sqlModel.deleteExpenseItems()
        
        importAction(onImporting)
    }

    func importAction(_ onImporting:(Int) -> ()) {
        
        var cnt = 1
        for item in importExpenseItems {
            sqlModel.insertExpenseItem(item: item)

            onImporting(cnt)
            cnt += 1
        }
        importExpenseItems.removeAll()
    }
    
    func importActionAfter() {
       reloadAllExpenseViewItems(false)
    }
}
