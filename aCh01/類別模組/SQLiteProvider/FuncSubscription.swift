//
//  FuncSubscription.swift
//  aCh01
//
//  Created by user on 2022/9/25.
//

import Foundation
import SQLite3

extension SQLPorvider {

    func insertSubscription(item:Subscription) {
        Trace.mPrint("insertSubscription", .ExecuteFlow)
        
        if let _ = querySubscriptionById(item.id) {
           updateSubscription(item: item)
        }
        else {
            var item_new = item
            item_new.seqOrder = querySubscriptionLastSeqOrder() + 1
            insertSubscription2(item: item_new)
        }
    }
    
    
    func querySubscriptionLastSeqOrder() -> Int {
        Trace.mPrint("querySubscriptionLastSeqOrder", .ExecuteFlow)
        
        let queryStatementString = "select SeqOrder from Subscription ORDER BY SeqOrder desc limit 1;"
        
        var stmt: OpaquePointer?
        
        var seqOrder : Int = 0
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {

            if (sqlite3_step(stmt) == SQLITE_ROW)
            {
                seqOrder = Int(sqlite3_column_int(stmt, 0))
            }
            
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
        return seqOrder
    }
    
    func insertSubscription2(item:Subscription) {
        Trace.mPrint("insertSubscription2", .ExecuteFlow)
        
        let insertStatementString = "INSERT INTO \(PickerNameTable.Subscription.rawValue) (Id,Name,Amount,AvgOfMonthAmount,TypeOfAmount,CycleName,CycleNote,SeqOrder) VALUES (?,?,?,?,?,?,?,?);"
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (item.id as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (item.name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 3, Int32(item.amountInt))
            sqlite3_bind_int(stmt, 4, Int32(item.avgOfMonthAmountInt))
            sqlite3_bind_text(stmt, 5, (item.typeOfAmount as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (item.cycleName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 7, (item.cycleNote as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 8, Int32(item.seqOrder))
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
            
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint("\(errorMessage)", .Error)
        }
        
        sqlite3_finalize(stmt)
    }
    
    func updateSubscription(item:Subscription) {
        Trace.mPrint("updateSubscription", .ExecuteFlow)
        
        
        let updateStatementString = """
        UPDATE \(PickerNameTable.Subscription.rawValue)
        SET Name = ?, Amount = ?, AvgOfMonthAmount = ?, TypeOfAmount = ?, CycleName = ?, CycleNote = ?, SeqOrder = ?
        WHERE id = ?;
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (item.name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 2, Int32(item.amountInt))
            sqlite3_bind_int(stmt, 3, Int32(item.avgOfMonthAmountInt))
            sqlite3_bind_text(stmt, 4, (item.typeOfAmount as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 5, (item.cycleName as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 6, (item.cycleNote as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 7, Int32(item.seqOrder))
            sqlite3_bind_text(stmt, 8, (item.id as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
    }
    
    
    func updateSubscriptionSeqOrder(_ uuid:String,_ seqOrder:Int) {
        Trace.mPrint("updateSubscriptionSeqOrder", .ExecuteFlow)

        let updateStatementString = """
        UPDATE \(PickerNameTable.Subscription.rawValue)
        SET SeqOrder = ? WHERE id = ?;
        """
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_int(stmt, 1, Int32(seqOrder))
            sqlite3_bind_text(stmt, 2, (uuid as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
    }
    
    func deleteSubscriptions() {
        Trace.mPrint("deleteSubscriptions", .ExecuteFlow)
        
        let deleteStatementString = "DELETE FROM \(PickerNameTable.Subscription.rawValue);"
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, deleteStatementString, -1, &stmt, nil) == SQLITE_OK {
            
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
    
    func deleteSubscriptionByID(id:String) {
        Trace.mPrint("deleteSubscriptionByID", .ExecuteFlow)
        
        let deleteStatementString = "DELETE FROM \(PickerNameTable.Subscription.rawValue) WHERE Id = ?;"
        
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
    
    func querySubscription() -> [Subscription] {
        Trace.mPrint("querySubscription", .ExecuteFlow)
        
        let queryStatementString = "SELECT * FROM \(PickerNameTable.Subscription.rawValue) ORDER BY SeqOrder DESC;"
        
        var stmt: OpaquePointer?
        
        var arr : [Subscription] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                var item = Subscription()
                item.id = String(cString: sqlite3_column_text(stmt, 0))
                item.name = String(cString: sqlite3_column_text(stmt, 1))
                item.amount = String(cString: sqlite3_column_text(stmt, 2))
                item.avgOfMonthAmount = String(cString: sqlite3_column_text(stmt, 3))
                item.typeOfAmount = String(cString: sqlite3_column_text(stmt, 4))
                item.cycleName = String(cString: sqlite3_column_text(stmt, 5))
                item.cycleNote = String(cString: sqlite3_column_text(stmt, 6))
                item.seqOrder = Int(sqlite3_column_int(stmt, 7))
                arr.append(item)
            }
            
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
        return arr
    }
    
    
    func querySubscriptionByCycleName(_ name:String) -> [Subscription] {
        //Trace.mPrint("querySubscriptionByCycleName:\(name)", .ExecuteFlow)
        
        let queryStatementString = "SELECT * FROM \(PickerNameTable.Subscription.rawValue) WHERE CycleName = ? ORDER BY SeqOrder DESC;"
        
        var stmt: OpaquePointer?
        
        var arr : [Subscription] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                var item = Subscription()
                item.id = String(cString: sqlite3_column_text(stmt, 0))
                item.name = String(cString: sqlite3_column_text(stmt, 1))
                item.amount = String(cString: sqlite3_column_text(stmt, 2))
                item.avgOfMonthAmount = String(cString: sqlite3_column_text(stmt, 3))
                item.typeOfAmount = String(cString: sqlite3_column_text(stmt, 4))
                item.cycleName = String(cString: sqlite3_column_text(stmt, 5))
                item.cycleNote = String(cString: sqlite3_column_text(stmt, 6))
                item.seqOrder = Int(sqlite3_column_int(stmt, 7))
                arr.append(item)
            }
            
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
        return arr
    }
    
    func querySubscriptionGroupByCycleName() -> [String] {
        //Trace.mPrint("querySubscriptionGroupByCycleName", .ExecuteFlow)
        
        let queryStatementString = "SELECT DISTINCT [Name] FROM \(PickerNameTable.CycleName);"
        
        var stmt: OpaquePointer?
        
        var arr : [String] = []
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            while(sqlite3_step(stmt) == SQLITE_ROW)
            {
                arr.append(String(cString: sqlite3_column_text(stmt, 0)))
            }
            
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
        return arr
    }
    
    
    func querySubscriptionById(_ uuid:String) -> Subscription? {
        Trace.mPrint("querySubscriptionById", .ExecuteFlow)
        
        let queryStatementString = "SELECT * FROM \(PickerNameTable.Subscription.rawValue) WHERE Id = ?;"
        
        var stmt: OpaquePointer?
        
        var item : Subscription?
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (uuid as NSString).utf8String, -1, nil)
            
            if (sqlite3_step(stmt) == SQLITE_ROW)
            {
                guard let _ = sqlite3_column_text(stmt, 0) else {
                    Trace.mPrint("Query result is nil", .Error)
                    return nil
                }
                
                item = Subscription()
                item!.id = String(cString: sqlite3_column_text(stmt, 0))
                item!.name = String(cString: sqlite3_column_text(stmt, 1))
                item!.amount = String(cString: sqlite3_column_text(stmt, 2))
                item!.avgOfMonthAmount = String(cString: sqlite3_column_text(stmt, 3))
                item!.typeOfAmount = String(cString: sqlite3_column_text(stmt, 4))
                item!.cycleName = String(cString: sqlite3_column_text(stmt, 5))
                item!.cycleNote = String(cString: sqlite3_column_text(stmt, 6))
                item!.seqOrder = Int(sqlite3_column_int(stmt, 7))
               
            }
            
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
        return item
    }
   
}
