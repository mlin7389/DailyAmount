//
//  PickerName.swift
//  aCh01
//
//  Created by user on 2022/9/24.
//

import Foundation
import SQLite3

extension SQLPorvider {
    
    func insertPickerNameByName(table:PickerNameTable,name:String) {
        Trace.mPrint("insertPickerNameByName", .ExecuteFlow)
        
        var picker = queryPickerNameByName(table: table, name: name)
        if picker != nil {
            picker!.count += 1
            updatePickerName(table: table, picker: picker!)
        }
        else {
            insertPickerByName2(table: table, name: name)
        }
    }

    internal func insertPickerByName2(table:PickerNameTable,name:String) {
        Trace.mPrint("insertPickerByName2", .ExecuteFlow)
        
        
        let insertStatementString = "INSERT INTO \(table.rawValue) (Name,Count,SeqOrder) VALUES (?,?,?);"
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) ==
            SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 2, 1)
            sqlite3_bind_int(stmt, 3, 0)
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
    }

    func updatePickerName(table:PickerNameTable,picker:PickerName)  {
        Trace.mPrint("updatePickerName", .ExecuteFlow)
        
        let updateStatementString = "UPDATE \(table) SET count = ? WHERE name = ?;"
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, updateStatementString, -1, &stmt, nil) ==
            SQLITE_OK {
            
            sqlite3_bind_int(stmt, 1, Int32(picker.count))
            sqlite3_bind_text(stmt, 2, (picker.name as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        sqlite3_finalize(stmt)
    }

    func deletePickerNameByName(table:PickerNameTable,name:String) {
        Trace.mPrint("deletePickerNameByName", .ExecuteFlow)
        
        
        let deleteStatementString = "DELETE FROM \(table.rawValue) WHERE Name = ?;"
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
    }

    func deletePickerName(table:PickerNameTable) {
        Trace.mPrint("deletePickerName", .ExecuteFlow)
        
        let deleteStatementString = "DELETE FROM \(table.rawValue);"
        
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


    private func queryPickerNameByName(table:PickerNameTable,name:String) -> PickerName? {
        Trace.mPrint("queryPickerNameByName", .ExecuteFlow)
        
        let queryStatementString = "SELECT * FROM \(table.rawValue) WHERE name = ?"
        
        var stmt: OpaquePointer?
        
        var picker : PickerName?
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            
            if (sqlite3_step(stmt) == SQLITE_ROW)
            {
                guard let _ = sqlite3_column_text(stmt, 0) else {
                    Trace.mPrint("Query result is nil", .Error)
                    return nil
                }
                
                picker = PickerName()
                picker!.name = String(cString: sqlite3_column_text(stmt, 0))
                picker!.count = Int(sqlite3_column_int(stmt, 1))
                picker!.order = Int(sqlite3_column_int(stmt, 2))
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
        return picker
    }

    func queryPickerNames(table:PickerNameTable, text:String = "") -> [PickerName] {
        Trace.mPrint("queryPickerNames", .ExecuteFlow)
        
        
        var queryStatementString = ""
        
        if text == "" {
            queryStatementString = "SELECT * FROM \(table.rawValue)  ORDER BY Count DESC LIMIT 100;"
        }
        else {
            queryStatementString = "SELECT * FROM \(table.rawValue) WHERE Name LIKE \"%\(text)%\" ORDER BY Count DESC"
        }

        
        var stmt: OpaquePointer?
        
        var arr : [PickerName] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                var picker = PickerName()
                
                picker.name = String(cString: sqlite3_column_text(stmt, 0))
                picker.count = Int(sqlite3_column_int(stmt, 1))
                picker.order = Int(sqlite3_column_int(stmt, 2))
                arr.append(picker)
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
        return arr
    }

 
    internal func insertPickerGroupName(item:PickGroupExpenseItem) {
        Trace.mPrint("insertPickerGroupName", .ExecuteFlow)

        let insertStatementString = "INSERT INTO \(PickerNameTable.PickGroupExpenseItem.rawValue) (Id,ItemName,TotalAmount) VALUES (?,?,?);"
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) ==
            SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (item.id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (item.name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 3, Int32(item.amount))
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
    }
    
    internal func queryPickerGroupNames() -> [PickGroupExpenseItem] {
        Trace.mPrint("queryPickerNames", .ExecuteFlow)
                
        let queryStatementString = "SELECT * FROM \(PickerNameTable.PickGroupExpenseItem.rawValue)"

        var stmt: OpaquePointer?
        
        var arr : [PickGroupExpenseItem] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                var item = PickGroupExpenseItem()
                
                item.id = String(cString: sqlite3_column_text(stmt, 0))
                item.name = String(cString: sqlite3_column_text(stmt, 1))
                item.amount = Int(sqlite3_column_int(stmt, 2))
                arr.append(item)
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
        return arr
    }
    
    internal func deletePickerGroupName(item:PickGroupExpenseItem) {
        Trace.mPrint("deletePickerNameByName", .ExecuteFlow)
        
        
        let deleteStatementString = "DELETE FROM \(PickerNameTable.PickGroupExpenseItem.rawValue) WHERE Id = ?;"
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (item.id as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
    }

}
