//
//  initAndProperty.swift
//  aCh01
//
//  Created by user on 2022/9/25.
//

import Foundation
import SQLite3


class SQLPorvider : ObservableObject {
    
    static let shared = SQLPorvider()
    
    var sqlParams : SQLParam = SQLParam()
    
    var db : OpaquePointer? = nil
    
    @Published var demoDBMode : Bool = false {
        didSet {
            if demoDBMode == true {
                switchToDemoData()
            }
            else {
                switchToProductionData()
            }
        }
    }

    init() {
        if sqlite3_open(sqlParams.dbPath, &db) == SQLITE_OK {
            Trace.mPrint("Successfully opened connection to database", .ExecuteFlow)
        } else {
            Trace.mPrint("Unable to open database.", .Error)
            Trace.mPrint("\(sqlParams.dbPath)", .Error)
        }
     
        //let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
       
        let initAppV1 = UserDefaults.standard.bool(forKey: SettingNames.initAppV1.rawValue)
        
        if initAppV1 == false {

            createTable(SQLParam.CycleNameTableString)
            createTable(SQLParam.ExpenseItemTableString)
            createTable(SQLParam.SubscriptionTableString)
            createTable(SQLParam.AppSettngsString)
            createTable(SQLParam.PickGroupExpenseItemString)
            
            insertPickerByName2(table: PickerNameTable.CycleName, name: "每日")
            insertPickerByName2(table: PickerNameTable.CycleName, name: "每週")
            insertPickerByName2(table: PickerNameTable.CycleName, name: "每月")
            insertPickerByName2(table: PickerNameTable.CycleName, name: "每奇數月")
            insertPickerByName2(table: PickerNameTable.CycleName, name: "每偶數月")
            insertPickerByName2(table: PickerNameTable.CycleName, name: "每季")
            insertPickerByName2(table: PickerNameTable.CycleName, name: "每半年")
            insertPickerByName2(table: PickerNameTable.CycleName, name: "每年")
            insertPickerByName2(table: PickerNameTable.CycleName, name: "每兩年")
            insertPickerByName2(table: PickerNameTable.CycleName, name: "每三年")
            
    
            let d1 = Date()
            let gt = ExpenseDetailGroupType.List
            insertSettings(name: SettingNames.detailViewDisclosureGroup, value: "true")
            insertSettings(name: SettingNames.detailViewSelectDate1, value: d1.DateStringType2())
            insertSettings(name: SettingNames.detailViewSelectDate2, value: d1.DateStringType2())
            insertSettings(name: SettingNames.detailViewsrchItemName, value: "")
            insertSettings(name: SettingNames.detailViewsrchMinAmount, value: "")
            insertSettings(name: SettingNames.detailViewsrchMaxAmount, value: "")
            insertSettings(name: SettingNames.detailViewExpenseDetailGroupType, value: gt.rawValue)
            insertSettings(name: SettingNames.detailViewSortDESC, value: "true")
            insertSettings(name: SettingNames.detailViewSortAmount, value: "false")
            
            insertSettings(name: SettingNames.groupViewDisclosureGroup, value: "true")
            insertSettings(name: SettingNames.groupViewSelectDate1, value: d1.DateStringType2())
            insertSettings(name: SettingNames.groupViewSelectDate2, value: d1.DateStringType2())
            insertSettings(name: SettingNames.groupViewsrchItemName, value: "")
            insertSettings(name: SettingNames.groupMergeType, value: GroupMergeType.GroupByName.rawValue)
            insertSettings(name: SettingNames.groupViewMergeTypeByDate, value: GroupMergeTypeByDate.Day.rawValue)
            insertSettings(name: SettingNames.groupViewSortDESC, value: "true")
            insertSettings(name: SettingNames.groupViewSortAmount, value: "false")
            
            insertSettings(name: SettingNames.autoAmountCount, value: "10")
            insertSettings(name: SettingNames.notKeepAppSettings, value: "false")
            
            let _ = resetDemoDB()
            
            UserDefaults.standard.set(true, forKey: SettingNames.initAppV1.rawValue)
            UserDefaults.standard.synchronize()
        }
       
        if queryAppSetting(name: SettingNames.notKeepAppSettings) == "true" {
            let d1 = Date()
            let gt = ExpenseDetailGroupType.List
            
            UpdateAppSetting(name: SettingNames.detailViewDisclosureGroup, value: "true")
            UpdateAppSetting(name: SettingNames.detailViewSelectDate1, value: d1.DateStringType2())
            UpdateAppSetting(name: SettingNames.detailViewSelectDate2, value: d1.DateStringType2())
            UpdateAppSetting(name: SettingNames.detailViewsrchItemName, value: "")
            UpdateAppSetting(name: SettingNames.detailViewsrchMinAmount, value: "")
            UpdateAppSetting(name: SettingNames.detailViewsrchMaxAmount, value: "")
            UpdateAppSetting(name: SettingNames.detailViewExpenseDetailGroupType, value: gt.rawValue)
            UpdateAppSetting(name: SettingNames.detailViewSortDESC, value: "true")
            UpdateAppSetting(name: SettingNames.detailViewSortAmount, value: "false")
            
            UpdateAppSetting(name: SettingNames.groupViewDisclosureGroup, value: "true")
            UpdateAppSetting(name: SettingNames.groupViewSelectDate1, value: d1.DateStringType2())
            UpdateAppSetting(name: SettingNames.groupViewSelectDate2, value: d1.DateStringType2())
            UpdateAppSetting(name: SettingNames.groupViewsrchItemName, value: "")
            UpdateAppSetting(name: SettingNames.groupMergeType, value: GroupMergeType.GroupByName.rawValue)
            UpdateAppSetting(name: SettingNames.groupViewMergeTypeByDate, value: GroupMergeTypeByDate.Day.rawValue)
            UpdateAppSetting(name: SettingNames.groupViewSortDESC, value: "true")
            UpdateAppSetting(name: SettingNames.groupViewSortAmount, value: "false")
            
            UpdateAppSetting(name: SettingNames.autoAmountCount, value: "5")
        }
        
    }
 
    
    private func createTable(_ sqlString:String) {
        Trace.mPrint("createTable", .ExecuteFlow)
        Trace.mPrint(sqlString, .ExecuteFlow)
        
        var stmt: OpaquePointer?
        
        if sqlite3_prepare_v2(db, sqlString, -1, &stmt, nil) == SQLITE_OK {
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
            
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
    }
    
    
    public func queryAppSetting(name:SettingNames) -> String {
        //Trace.mPrint("queryAppSetting:\(name)", .ExecuteFlow)
        
        let queryStatementString = "SELECT * FROM \(PickerNameTable.AppSettngs.rawValue) WHERE aName = ?"
        
        var stmt: OpaquePointer?
        
        var value = ""
        
        if sqlite3_prepare_v2(db, queryStatementString, -1, &stmt, nil) == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (name.rawValue as NSString).utf8String, -1, nil)
            
            if (sqlite3_step(stmt) == SQLITE_ROW){
                value = String(cString: sqlite3_column_text(stmt, 1))
            }
            else {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
        }
        else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        
        sqlite3_finalize(stmt)
        return value
    }
    
    public func UpdateAppSetting(name:SettingNames,value:String) {
        Trace.mPrint("UpdateAppSetting", .ExecuteFlow)
        
        let updateStatementString = "UPDATE \(PickerNameTable.AppSettngs.rawValue) SET aValue = ? WHERE aName = ?;"
        
        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, updateStatementString, -1, &stmt, nil) ==
            SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (value as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (name.rawValue as NSString).utf8String, -1, nil)
            
            if sqlite3_step(stmt) != SQLITE_DONE {
                Trace.mPrint("Error sqlite3_step is not SQLITE_DONE", .Error)
            }
        } else {
            let errorMessage = String(cString: sqlite3_errmsg(db))
            Trace.mPrint(errorMessage, .Error)
        }
        sqlite3_finalize(stmt)
    }
    
    private func insertSettings(name:SettingNames,value:String) {
        Trace.mPrint("insertSettings", .ExecuteFlow)
        
        let insertStatementString = "INSERT INTO \(PickerNameTable.AppSettngs.rawValue) (aName,aValue) VALUES (?,?);"
        
        var stmt: OpaquePointer?
        
        let rt = sqlite3_prepare_v2(db, insertStatementString, -1, &stmt, nil)
        if rt == SQLITE_OK {
            
            sqlite3_bind_text(stmt, 1, (name.rawValue as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (value as NSString).utf8String, -1, nil)
            
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
}

