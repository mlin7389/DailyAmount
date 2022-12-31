//
//  FuncDemoMode.swift
//  aCh01
//
//  Created by user on 2022/9/25.
//

import Foundation
import SQLite3

extension SQLPorvider {
    
    
    
    func resetDemoDB() -> (resut: Bool,firstDate: String,lastDate: String) {
        do {
            
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            var sqlite3_demo = paths[0]
            sqlite3_demo.appendPathComponent("sqlite3_demo.db")
            
            if FileManager.default.fileExists(atPath: sqlite3_demo.path) {
                try FileManager.default.removeItem(at: sqlite3_demo)
            }
            
            let srcURL = Bundle.main.url(forResource: "sqlite3_demo", withExtension: "db")!
            
            try FileManager.default.copyItem(at: srcURL, to: sqlite3_demo)
            Trace.mPrint("Cannot copy item \(srcURL)", .Error)
            Trace.mPrint("Cannot copy item \(sqlite3_demo)", .Error)
            
            switchToDemoData()
            
            //todo 更新資料日期
            let year1 = Calendar.current.component(.year, from: Date())
            let offset = year1 - 2022
            
            updateResetDemoDb(offsetYear: offset, year: "2021")
            
            updateResetDemoDb(offsetYear: offset, year: "2022")
            
            
        } catch (let error) {
            Trace.mPrint("Cannot copy item \(error)", .Error)
            return (false,"","")
        }
        
        let fs = queryFirstAndLastDate()
        
        if demoDBMode  == false {
            switchToProductionData()
        }
        
        return (true,fs.firstDate,fs.lastDate)
    }

    func switchToDemoData() {
        
        sqlite3_close(db)
        sqlParams.switchToDemoData()
        if sqlite3_open(sqlParams.dbPath, &db) != SQLITE_OK {
            Trace.mPrint("Unable to open database.", .Error)
            Trace.mPrint(sqlParams.dbPath, .Error)
        }
    }
    
    func switchToProductionData() {
        
        sqlite3_close(db)
        sqlParams.switchToProductionData()
        if sqlite3_open(sqlParams.dbPath, &db) != SQLITE_OK {
            Trace.mPrint("Unable to open database.", .Error)
            Trace.mPrint(sqlParams.dbPath, .Error)
        }
    }
    
    func updateResetDemoDb(offsetYear:Int,year:String) {
        Trace.mPrint("updateResetDemoDb", .ExecuteFlow)
        
        let offsetYearString = String(offsetYear)

        let updateStatementString = "update ExpenseItem set PurhaseDate = CAST(CAST(substr(PurhaseDate,1,4) as INT) + \(offsetYearString) as CHAR) || substr(PurhaseDate,5,6) where substr(PurhaseDate,1,4) = '\(year)';"
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, updateStatementString, -1, &stmt, nil) == SQLITE_OK {
            
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
