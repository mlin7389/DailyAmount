//
//  FuncExpense.swift
//  aCh01
//
//  Created by user on 2022/9/25.
//

import Foundation
import SQLite3

extension SQLPorvider {
    
    

     // MARK: - Expense
     func insertExpenseItem(item:ExpenseItem) {
         if let _ = queryExpenseItemByID(item.id) {
             updateExpenseItem(item: item)
         }
         else {
             insertExpenseItem2(item: item)
         }
     }
     
     private func insertExpenseItem2(item:ExpenseItem) {
         Trace.mPrint("insertExpenseItem2", .ExecuteFlow)

         let insertStatementString = "INSERT INTO \(PickerNameTable.ExpenseItem.rawValue) (id,itemName,totalAmount,purhaseDate,InsertDateTime) VALUES (?,?,?,?,?);"
         
         var stmt: OpaquePointer?
         
         if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             sqlite3_bind_text(stmt, 1, (item.id as NSString).utf8String, -1, nil)
             sqlite3_bind_text(stmt, 2, (item.itemName as NSString).utf8String, -1, nil)
             sqlite3_bind_int(stmt, 3, Int32(item.totalAmountInt))
             sqlite3_bind_text(stmt, 4, (item.purhaseDateForDB as NSString).utf8String, -1, nil)
             sqlite3_bind_text(stmt, 5, (Date.now.InsertDateTimeForDB() as NSString).utf8String, -1, nil)
             
             if sqlite3_step(stmt) != SQLITE_DONE {
                 Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
     }
     
      func updateExpenseItem(item:ExpenseItem) {
         Trace.mPrint("updateExpenseItem", .ExecuteFlow)
         
         let updateStatementString = "UPDATE \(PickerNameTable.ExpenseItem.rawValue) SET itemName = ?,totalAmount = ?,purhaseDate = ? WHERE id = ?;"
         
         var stmt: OpaquePointer?
         
         if sqlite3_prepare_v2(db, updateStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             sqlite3_bind_text(stmt, 1, (item.itemName as NSString).utf8String, -1, nil)
             sqlite3_bind_int(stmt, 2, Int32(item.totalAmountInt))
             sqlite3_bind_text(stmt, 3, (item.purhaseDateForDB as NSString).utf8String, -1, nil)
             sqlite3_bind_text(stmt, 4, (item.id as NSString).utf8String, -1, nil)
             
             if sqlite3_step(stmt) != SQLITE_DONE {
                 Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
             }
             
         }
          else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
     }
     
     func deleteExpenseItemByID(id:String) {
         Trace.mPrint("deleteExpenseItemByID", .ExecuteFlow)
         
         let deleteStatementString = "DELETE FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE id = ?;"
         
         var stmt: OpaquePointer?
         
         if sqlite3_prepare_v2(db, deleteStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             sqlite3_bind_text(stmt, 1, (id as NSString).utf8String, -1, nil)
             
             if sqlite3_step(stmt) != SQLITE_DONE {
                 Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
             }
             
         }
         else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
     }
     
     func deleteExpenseItems() {
         
         Trace.mPrint("deleteExpenseItems", .ExecuteFlow)
         
         let deleteStatementString = "DELETE FROM \(PickerNameTable.ExpenseItem.rawValue);"
         
         var stmt: OpaquePointer?
         
         if sqlite3_prepare_v2(db, deleteStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             if sqlite3_step(stmt) != SQLITE_DONE {
                 Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
     }
     
     
     func queryExpenseItemSingleDate(_ singleDate:ExpenseItemSingleDate) -> Date {
         Trace.mPrint("queryExpenseItemSingleDate", .ExecuteFlow)
         
         var queryStatementString = ""
         switch singleDate {
         case .FirstDate:
             queryStatementString = "select PurhaseDate from ExpenseItem ORDER BY PurhaseDate ASC LIMIT 1"
         case .LastDate:
             queryStatementString = "select PurhaseDate from ExpenseItem ORDER BY PurhaseDate DESC LIMIT 1"
         }
       
         
         var stmt: OpaquePointer?
         
         var result : Date = Date.now
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var item = ExpenseItem()
                 item.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 0)))
                 result = item.purhaseDate
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return result
     }
     
     func queryFirstAndLastDate() -> (firstDate: String,lastDate: String)  {
         Trace.mPrint("queryFirstAndLastDate", .ExecuteFlow)
         
         let fm = DateFormatter()
         fm.dateFormat = "yyyy/MM/dd"
         var firstDate : Date?
         var lastDate : Date?
         
         let queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) ORDER BY PurhaseDate ASC"
         
         var stmt: OpaquePointer?
       
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {


             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 let s = String(cString: sqlite3_column_text(stmt, 3))
                 if (firstDate == nil) {
                     firstDate = fm.date(from: s) ?? Date.now
                 }
                 lastDate = fm.date(from: s) ?? Date.now
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
        
         return (fm.string(from: firstDate ?? Date.now) , fm.string(from: lastDate ?? Date.now))
     }
     
     
     func queryExpenseItem() -> [ExpenseItem] {
         Trace.mPrint("queryExpenseItem", .ExecuteFlow)
         
         let queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) ORDER BY PurhaseDate DESC,InsertDateTime ASC;"
         
         var stmt: OpaquePointer?
         
         var arr : [ExpenseItem] = []
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var item = ExpenseItem()
                 item.id = String(cString: sqlite3_column_text(stmt, 0))
                 item.itemName = String(cString: sqlite3_column_text(stmt, 1))
                 item.totalAmount = String(sqlite3_column_int(stmt, 2))
                 item.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 3)))
                 arr.append(item)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
     func queryExpenseItemForGroupNameDisplay(startDate:Date,endDate:Date,displayType:GroupMergeTypeByDate,srchString:String) -> [ExpenseItem] {
        // Trace.mPrint("queryExpenseItemForGroupNameDisplay", .ExecuteFlow)
         
         var date1 = startDate
         var date2 = endDate
         
         if date1.compare(date2) == .orderedDescending {
             let tmp = date1
             date1 = date2
             date2 = tmp
         }
         let minDate = ExpenseItem.purhaseDateForDBFormat(date1)
         let maxDate = ExpenseItem.purhaseDateForDBFormat(date2)
         
         var queryStatementString = ""
         
         var ItemNameSQL = ""
         if srchString != "" {
             ItemNameSQL = " AND (UPPER(ItemName) LIKE UPPER(\"%\(srchString)%\"))"
         }
          
         switch displayType {
         case .Day:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) \(ItemNameSQL) Group By ItemName,PurhaseDate ORDER BY ItemName,PurhaseDate ASC;"
         case .Month:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) \(ItemNameSQL) Group By ItemName,SUBSTR(PurhaseDate,1,7) ORDER BY ItemName,PurhaseDate ASC;"
         case .Season:
             queryStatementString = """
             select  Id, ItemName , SUM(totalAmount) , PurhaseDate,
             CASE
             WHEN Substr(PurhaseDate,6,2) >= '01' and  Substr(PurhaseDate,6,2) <= '03' THEN Substr(PurhaseDate,1,4) || '第一季'
             WHEN Substr(PurhaseDate,6,2) >= '04' and  Substr(PurhaseDate,6,2) <= '06' THEN Substr(PurhaseDate,1,4) || '第二季'
             WHEN Substr(PurhaseDate,6,2) >= '07' and  Substr(PurhaseDate,6,2) <= '09' THEN Substr(PurhaseDate,1,4) || '第三季'
             WHEN Substr(PurhaseDate,6,2) >= '10' and  Substr(PurhaseDate,6,2) <= '12' THEN Substr(PurhaseDate,1,4) || '第四季'
             END as Season
             from \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) \(ItemNameSQL) Group By ItemName, Season ORDER BY ItemName,PurhaseDate ASC;
             """
         case .HalfYear:
             queryStatementString = """
             select  Id, ItemName , SUM(totalAmount) , PurhaseDate,
             CASE
             WHEN Substr(PurhaseDate,6,2) >= '01' and  Substr(PurhaseDate,6,2) <= '06' THEN Substr(PurhaseDate,1,4) || '上半年'
             WHEN Substr(PurhaseDate,6,2) >= '07' and  Substr(PurhaseDate,6,2) <= '12' THEN Substr(PurhaseDate,1,4) || '下半年'
             END as HalfYear
             from \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) \(ItemNameSQL) Group By ItemName, HalfYear ORDER BY ItemName,PurhaseDate ASC;
             """
         case .Year:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) \(ItemNameSQL) Group By ItemName,SUBSTR(PurhaseDate,1,4) ORDER BY ItemName,PurhaseDate ASC;"
         }
  
         var stmt: OpaquePointer?
         
         var arr : [ExpenseItem] = []
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             sqlite3_bind_text(stmt, 1, (minDate as NSString).utf8String, -1, nil)
             sqlite3_bind_text(stmt, 2, (maxDate as NSString).utf8String, -1, nil)
             
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var item = ExpenseItem()
                 item.id = String(cString: sqlite3_column_text(stmt, 0))
                 item.itemName = String(cString: sqlite3_column_text(stmt, 1))
                 item.totalAmount = String(sqlite3_column_int(stmt, 2))
                 item.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 3)))
                 if displayType == .Season || displayType == .HalfYear {
                     item.extraName = String(cString: sqlite3_column_text(stmt, 4))
                 }
                 arr.append(item)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
     func queryExpenseItemForGroupDateDisplay(startDate:Date,endDate:Date,displayType:GroupMergeTypeByDate,srchString:String) -> [ExpenseItem] {
         Trace.mPrint("queryExpenseItemForGroupDateDisplay", .ExecuteFlow)
         
         var date1 = startDate
         var date2 = endDate
         
         if date1.compare(date2) == .orderedDescending {
             let tmp = date1
             date1 = date2
             date2 = tmp
         }
         let minDate = ExpenseItem.purhaseDateForDBFormat(date1)
         let maxDate = ExpenseItem.purhaseDateForDBFormat(date2)
         
         var queryStatementString = ""
         
         var ItemNameSQL = ""
         if srchString != "" {
             ItemNameSQL = " AND (UPPER(ItemName) LIKE UPPER(\"%\(srchString)%\"))"
         }
       
         switch displayType {
         case .Day:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) \(ItemNameSQL) Group By PurhaseDate ORDER BY PurhaseDate ASC;"
         case .Month:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) \(ItemNameSQL) Group By SUBSTR(PurhaseDate,1,7) ORDER BY PurhaseDate ASC;"
         case .Season:
             queryStatementString = """
             select  Id, ItemName , SUM(totalAmount) , PurhaseDate,
             CASE
             WHEN Substr(PurhaseDate,6,2) >= '01' and  Substr(PurhaseDate,6,2) <= '03' THEN Substr(PurhaseDate,1,4) || '第一季'
             WHEN Substr(PurhaseDate,6,2) >= '04' and  Substr(PurhaseDate,6,2) <= '06' THEN Substr(PurhaseDate,1,4) || '第二季'
             WHEN Substr(PurhaseDate,6,2) >= '07' and  Substr(PurhaseDate,6,2) <= '09' THEN Substr(PurhaseDate,1,4) || '第三季'
             WHEN Substr(PurhaseDate,6,2) >= '10' and  Substr(PurhaseDate,6,2) <= '12' THEN Substr(PurhaseDate,1,4) || '第四季'
             END as Season
             from \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) \(ItemNameSQL) Group By Season ORDER BY PurhaseDate ASC;
             """
         case .HalfYear:
             queryStatementString = """
             select  Id, ItemName , SUM(totalAmount) , PurhaseDate,
             CASE
             WHEN Substr(PurhaseDate,6,2) >= '01' and  Substr(PurhaseDate,6,2) <= '06' THEN Substr(PurhaseDate,1,4) || '上半年'
             WHEN Substr(PurhaseDate,6,2) >= '07' and  Substr(PurhaseDate,6,2) <= '12' THEN Substr(PurhaseDate,1,4) || '下半年'
             END as HalfYear
             from \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) \(ItemNameSQL) Group By HalfYear ORDER BY PurhaseDate ASC;
             """
         case .Year:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) \(ItemNameSQL) Group By SUBSTR(PurhaseDate,1,4) ORDER BY PurhaseDate ASC;"
         }
  
         var stmt: OpaquePointer?
         
         var arr : [ExpenseItem] = []
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
         
             sqlite3_bind_text(stmt, 1, (minDate as NSString).utf8String, -1, nil)
             sqlite3_bind_text(stmt, 2, (maxDate as NSString).utf8String, -1, nil)
             
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var item = ExpenseItem()
                 item.id = String(cString: sqlite3_column_text(stmt, 0))
                 item.itemName = String(cString: sqlite3_column_text(stmt, 1))
                 item.totalAmount = String(sqlite3_column_int(stmt, 2))
                 item.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 3)))
                 if displayType == .Season || displayType == .HalfYear {
                     item.extraName = String(cString: sqlite3_column_text(stmt, 4))
                 }
                 arr.append(item)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
     private func queryExpenseItemByID(_ uuid:String) -> ExpenseItem? {
         Trace.mPrint("queryExpenseItemByID", .ExecuteFlow)
         
         
         let queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE Id = ?"
         
         var stmt: OpaquePointer?
         
         var item : ExpenseItem?
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             sqlite3_bind_text(stmt, 1, (uuid as NSString).utf8String, -1, nil)
             
             if (sqlite3_step(stmt) == SQLITE_ROW)
             {
                 guard let _ = sqlite3_column_text(stmt, 0) else {
                     Trace.mPrint("Query result is nil", .Error)
                     return nil
                 }
                 
                 item = ExpenseItem()
                 item!.id = String(cString: sqlite3_column_text(stmt, 0))
                 item!.itemName = String(cString: sqlite3_column_text(stmt, 1))
                 item!.totalAmount = String(sqlite3_column_int(stmt, 2))
                 item!.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 3)))
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return item
     }
     
     
     func queryExpenseItemByBetweenDate(_ startDate:Date,_ endDate:Date,_ displayType:ExpenseDetailGroupType) -> [ExpenseItem] {
        // Trace.mPrint("queryExpenseItemByBetweenDate \(displayType.rawValue)", .ExecuteFlow)
         
         var date1 = startDate
         var date2 = endDate
         
         if date1.compare(date2) == .orderedDescending {
             let tmp = date1
             date1 = date2
             date2 = tmp
         }
         let minDate = ExpenseItem.purhaseDateForDBFormat(date1)
         let maxDate = ExpenseItem.purhaseDateForDBFormat(date2)
         
         var queryStatementString = ""
         
         switch (displayType) {
         case .GroupByDate:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE PurhaseDate >= ? AND PurhaseDate <= ? GROUP BY PurhaseDate ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         case .GroupByName:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE PurhaseDate >= ? AND PurhaseDate <= ? GROUP BY ItemName ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         case .List:
             queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE PurhaseDate >= ? AND PurhaseDate <= ? ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         }
  
         var stmt: OpaquePointer?
         
         var arr : [ExpenseItem] = []
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             sqlite3_bind_text(stmt, 1, (minDate as NSString).utf8String, -1, nil)
             sqlite3_bind_text(stmt, 2, (maxDate as NSString).utf8String, -1, nil)
             
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var item = ExpenseItem()
                 item.id = String(cString: sqlite3_column_text(stmt, 0))
                 item.itemName = String(cString: sqlite3_column_text(stmt, 1))
                 item.totalAmount = String(sqlite3_column_int(stmt, 2))
                 item.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 3)))
                 arr.append(item)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
     func queryExpenseItemByBetweenDateNameAmount(startDate:Date,endDate:Date,itemName:String,minAmount:Int,maxAmount:Int,displayType:ExpenseDetailGroupType) -> [ExpenseItem] {
         Trace.mPrint("queryExpenseItemByBetweenDate", .ExecuteFlow)
         
         var date1 = startDate
         var date2 = endDate
         
         if date1.compare(date2) == .orderedDescending {
             let tmp = date1
             date1 = date2
             date2 = tmp
         }
         let minDate = ExpenseItem.purhaseDateForDBFormat(date1)
         let maxDate = ExpenseItem.purhaseDateForDBFormat(date2)
         
         var amt1 = minAmount
         var amt2 = maxAmount
         
         if amt1 > amt2 {
             let tmp = amt1
             amt1 = amt2
             amt2 = tmp
         }
         let minAmt = amt1
         let maxAmt = amt2
         
         
         var queryStatementString = ""
         
         switch (displayType) {
         case .GroupByDate:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) AND (TotalAmount >= ? AND TotalAmount <= ?) AND (ItemName LIKE \"%\(itemName)%\") GROUP BY PurhaseDate ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         case .GroupByName:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) AND (TotalAmount >= ? AND TotalAmount <= ?) AND (ItemName LIKE \"%\(itemName)%\") GROUP BY ItemName ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         case .List:
             queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) AND (TotalAmount >= ? AND TotalAmount <= ?) AND (ItemName LIKE \"%\(itemName)%\") ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         }
        
         var stmt: OpaquePointer?
         
         var arr : [ExpenseItem] = []
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             sqlite3_bind_text(stmt, 1, (minDate as NSString).utf8String, -1, nil)
             sqlite3_bind_text(stmt, 2, (maxDate as NSString).utf8String, -1, nil)
             sqlite3_bind_int(stmt, 3, Int32(minAmt))
             sqlite3_bind_int(stmt, 4, Int32(maxAmt))
             sqlite3_bind_text(stmt, 5, (itemName as NSString).utf8String, -1, nil)
             
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var item = ExpenseItem()
                 item.id = String(cString: sqlite3_column_text(stmt, 0))
                 item.itemName = String(cString: sqlite3_column_text(stmt, 1))
                 item.totalAmount = String(sqlite3_column_int(stmt, 2))
                 item.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 3)))
                 arr.append(item)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
     func queryExpenseItemByBetweenDateAmount(startDate:Date,endDate:Date,minAmount:Int,maxAmount:Int,displayType:ExpenseDetailGroupType) -> [ExpenseItem] {
         Trace.mPrint("queryExpenseItemByBetweenDate", .ExecuteFlow)
         
         var date1 = startDate
         var date2 = endDate
         
         if date1.compare(date2) == .orderedDescending {
             let tmp = date1
             date1 = date2
             date2 = tmp
         }
         let minDate = ExpenseItem.purhaseDateForDBFormat(date1)
         let maxDate = ExpenseItem.purhaseDateForDBFormat(date2)
         
         var amt1 = minAmount
         var amt2 = maxAmount
         
         if amt1 > amt2 {
             let tmp = amt1
             amt1 = amt2
             amt2 = tmp
         }
         let minAmt = amt1
         let maxAmt = amt2
         
         var queryStatementString = ""
         
         switch (displayType) {
         case .GroupByDate:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) AND (TotalAmount >= ? AND TotalAmount <= ?) GROUP BY PurhaseDate ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         case .GroupByName:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) AND (TotalAmount >= ? AND TotalAmount <= ?) GROUP BY ItemName ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         case .List:
             queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) AND (TotalAmount >= ? AND TotalAmount <= ?) ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         }
         
       
         
         var stmt: OpaquePointer?
         
         var arr : [ExpenseItem] = []
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             sqlite3_bind_text(stmt, 1, (minDate as NSString).utf8String, -1, nil)
             sqlite3_bind_text(stmt, 2, (maxDate as NSString).utf8String, -1, nil)
             sqlite3_bind_int(stmt, 3, Int32(minAmt))
             sqlite3_bind_int(stmt, 4, Int32(maxAmt))
             
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var item = ExpenseItem()
                 item.id = String(cString: sqlite3_column_text(stmt, 0))
                 item.itemName = String(cString: sqlite3_column_text(stmt, 1))
                 item.totalAmount = String(sqlite3_column_int(stmt, 2))
                 item.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 3)))
                 arr.append(item)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
     func queryExpenseItemByBetweenAmount(name:String,minAmount:Int,maxAmount:Int,searchType:SearchType) -> [ExpenseItem] {
         Trace.mPrint("queryExpenseItemByBetweenAmount", .ExecuteFlow)
         
         var amt1 = minAmount
         var amt2 = maxAmount
         
         if amt1 > amt2 {
             let tmp = amt1
             amt1 = amt2
             amt2 = tmp
         }
         let minAmt = amt1
         let maxAmt = amt2
         
         var queryStatementString = ""
         
         
         if searchType == .LikeSearch {
             if name == "" {
                 queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (TotalAmount >= ? AND TotalAmount <= ?) ORDER BY PurhaseDate DESC,InsertDateTime ASC;"
             }
             else {
                 queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE ItemName LIKE \"%\(name)%\" AND (TotalAmount >= ? AND TotalAmount <= ?) ORDER BY PurhaseDate DESC,InsertDateTime ASC;"
             }
          
         }
         else {
             if name == "" {
                 queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (TotalAmount >= ? AND TotalAmount <= ?) ORDER BY PurhaseDate DESC,InsertDateTime ASC;"
             }
             else {
                 queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE ItemName = '\(name)' AND (TotalAmount >= ? AND TotalAmount <= ?) ORDER BY PurhaseDate DESC,InsertDateTime ASC;"
             }
             
         }

         var stmt: OpaquePointer?
         
         var arr : [ExpenseItem] = []
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {

             sqlite3_bind_int(stmt, 1, Int32(minAmt))
             sqlite3_bind_int(stmt, 2, Int32(maxAmt))
             
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var item = ExpenseItem()
                 item.id = String(cString: sqlite3_column_text(stmt, 0))
                 item.itemName = String(cString: sqlite3_column_text(stmt, 1))
                 item.totalAmount = String(sqlite3_column_int(stmt, 2))
                 item.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 3)))
                 arr.append(item)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
     func queryExpenseItemByBetweenDateName(startDate:Date,endDate:Date,itemName:String,displayType:ExpenseDetailGroupType) -> [ExpenseItem] {
         Trace.mPrint("queryExpenseItemByBetweenDate", .ExecuteFlow)
         
         var date1 = startDate
         var date2 = endDate
         
         if date1.compare(date2) == .orderedDescending {
             let tmp = date1
             date1 = date2
             date2 = tmp
         }
         let minDate = ExpenseItem.purhaseDateForDBFormat(date1)
         let maxDate = ExpenseItem.purhaseDateForDBFormat(date2)
         
         var queryStatementString = ""
         
         switch (displayType) {
         case .GroupByDate:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) AND (ItemName LIKE \"%\(itemName)%\") GROUP BY PurhaseDate ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         case .GroupByName:
             queryStatementString = "SELECT Id, ItemName , SUM(totalAmount) AS totalAmount, PurhaseDate, InsertDateTime FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) AND (ItemName LIKE \"%\(itemName)%\") GROUP BY ItemName ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         case .List:
             queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) AND (ItemName LIKE \"%\(itemName)%\") ORDER BY PurhaseDate DESC,InsertDateTime DESC;"
         }
    
         var stmt: OpaquePointer?
        
         var arr : [ExpenseItem] = []
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             sqlite3_bind_text(stmt, 1, (minDate as NSString).utf8String, -1, nil)
             sqlite3_bind_text(stmt, 2, (maxDate as NSString).utf8String, -1, nil)
            //sqlite3_bind_text(stmt, 3, (itemName as NSString).utf8String, -1, nil)
             
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var item = ExpenseItem()
                 item.id = String(cString: sqlite3_column_text(stmt, 0))
                 item.itemName = String(cString: sqlite3_column_text(stmt, 1))
                 item.totalAmount = String(sqlite3_column_int(stmt, 2))
                 item.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 3)))
                 arr.append(item)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
     
     
     func queryExpenseItemByName(_ name:String,_ searchType:SearchType) -> [ExpenseItem] {
         Trace.mPrint("queryExpenseItemByName", .ExecuteFlow)
         
         var queryStatementString = ""
         if searchType == .LikeSearch {
             queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE ItemName LIKE \"%\(name)%\" ORDER BY PurhaseDate DESC,InsertDateTime ASC;"
         }
         else {
             queryStatementString = "SELECT * FROM \(PickerNameTable.ExpenseItem.rawValue) WHERE ItemName = ? ORDER BY PurhaseDate DESC,InsertDateTime ASC;"
         }
         
         var stmt: OpaquePointer?
         
         var arr : [ExpenseItem] = []
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             if searchType == .FullSearch {
                sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
             }
             
             
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var item = ExpenseItem()
                 item.id = String(cString: sqlite3_column_text(stmt, 0))
                 item.itemName = String(cString: sqlite3_column_text(stmt, 1))
                 item.totalAmount = String(sqlite3_column_int(stmt, 2))
                 item.setPurhaseDateFromDB(dString: String(cString: sqlite3_column_text(stmt, 3)))
                 arr.append(item)
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
    func queryExpenseItemNames2(_ name:String) -> [PickerName]{
        Trace.mPrint("queryExpenseItemNames", .ExecuteFlow)
        
        var queryStatementString = ""
        if name != "" {
            queryStatementString = "Select DISTINCT ItemName,count() as count From ExpenseItem WHERE ItemName LIKE \"%\(name)%\" group by ItemName  order by count desc"
        }
        else {
            queryStatementString = "Select DISTINCT ItemName,count() as count  From ExpenseItem group by ItemName  order by count desc LIMIT 100;"
        }
        
        var stmt: OpaquePointer?
        
        var arr : [PickerName] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
  
            var duplicate : [String] = []
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                var pickName = PickerName()
                pickName.name = String(cString: sqlite3_column_text(stmt, 0))

                if duplicate.contains(pickName.name) == false {
                    duplicate.append(pickName.name)
                    arr.append(pickName)
                }
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
        return arr
    }
    
     func queryExpenseItemNames(_ name:String,_ count:Int,_ containAmount:Bool = true) -> [PickerName]{
         Trace.mPrint("queryExpenseItemNames", .ExecuteFlow)
         
         var queryStatementString = ""
         if name != "" {
             queryStatementString = "Select DISTINCT ItemName,TotalAmount,count() as count From ExpenseItem WHERE ItemName LIKE \"%\(name)%\" group by ItemName,TotalAmount  order by count desc"
         }
         else {
             queryStatementString = "Select DISTINCT ItemName,TotalAmount,count() as count  From ExpenseItem WHERE (PurhaseDate >= ? AND PurhaseDate <= ?) group by ItemName,TotalAmount  order by count desc LIMIT 100;"
         }
         
         var stmt: OpaquePointer?
         
         var arr : [PickerName] = []
     
         var date_30 : Date?
         var minDate : String?
         var maxDate : String?

         if name == "" {
             date_30 = Date.now.addingTimeInterval(-24*60*60*31)
             minDate = ExpenseItem.purhaseDateForDBFormat(date_30!)
             maxDate = ExpenseItem.purhaseDateForDBFormat(Date.now)
         }
         
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
          
             if name == "" {
                 sqlite3_bind_text(stmt, 1, (minDate! as NSString).utf8String, -1, nil)
                 sqlite3_bind_text(stmt, 2, (maxDate! as NSString).utf8String, -1, nil)
             }
   
             var duplicate : [String] = []
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var pickName = PickerName()
                 pickName.name = String(cString: sqlite3_column_text(stmt, 0))
                 pickName.count = Int(sqlite3_column_int(stmt, 2))
                 
                 if pickName.count > count && containAmount == true {
                     pickName.extraAmount = Int(sqlite3_column_int(stmt, 1))
                 }
                 else {
                     pickName.extraAmount = 0
                 }
                 
                 let str = "\(pickName.name)\(pickName.extraAmount)"
                 if duplicate.contains(str) == false {
                     duplicate.append(str)
                     arr.append(pickName)
                 }
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
     func queryExpenseItemNameAmount(_ amount:Int,_ name:String) -> [PickerName]{
         
         var queryStatementString = ""
         if name != "" {
             queryStatementString = "Select DISTINCT ItemName,TotalAmount,count() as count From ExpenseItem WHERE ItemName LIKE \"%\(name)%\" AND TotalAmount = ? group by ItemName,TotalAmount order by count desc;"
         }
         else {
             queryStatementString = "Select DISTINCT ItemName,TotalAmount,count() as count  From ExpenseItem WHERE TotalAmount = ? group by ItemName,TotalAmount order by count desc;"
         }
         
         var stmt: OpaquePointer?
         
         var arr : [PickerName] = []
         
         if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
             
             sqlite3_bind_int(stmt, 1, Int32(amount))
            
             var duplicate : [String] = []
             while(sqlite3_step(stmt) == SQLITE_ROW)
             {
                 var pickName = PickerName()
                 pickName.name = String(cString: sqlite3_column_text(stmt, 0))
                 pickName.count = Int(sqlite3_column_int(stmt, 2))
                 pickName.extraAmount = Int(sqlite3_column_int(stmt, 1))
                 
                 let str = "\(pickName.name)\(pickName.extraAmount)"
                 if duplicate.contains(str) == false {
                     duplicate.append(str)
                     arr.append(pickName)
                 }
             }
             
         } else {
             let errorMessage = String(cString: sqlite3_errmsg(db))
             Trace.mPrint(errorMessage, .Error)
         }
         
         sqlite3_finalize(stmt)
         return arr
     }
     
     
    
}
