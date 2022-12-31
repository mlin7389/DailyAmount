//
//  SQLParam.swift
//  aCh01
//
//  Created by user on 2022/9/24.
//

import Foundation

struct SQLParam {
    
     var dbPath : String
    
    // 資料庫檔案的路徑
    init() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        documentsDirectory.appendPathComponent("sqlite3.db")
        dbPath = documentsDirectory.absoluteString
        Trace.mPrint(dbPath,.FilePath)
    }
    
    mutating func switchToDemoData() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var sqlite3_demo = paths[0]
        sqlite3_demo.appendPathComponent("sqlite3_demo.db")
        
        do {
            if FileManager.default.fileExists(atPath: sqlite3_demo.path) == false {
                let srcURL = Bundle.main.url(forResource: "sqlite3_demo", withExtension: "db")!
                try FileManager.default.copyItem(at: srcURL, to: sqlite3_demo)
            }
        } catch (let error) {
            Trace.mPrint("Cannot copy item \(error)",.Error)
        }

        dbPath = sqlite3_demo.absoluteString
        Trace.mPrint(dbPath,.FilePath)
    }
    
    mutating func switchToProductionData() {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var documentsDirectory = paths[0]
        documentsDirectory.appendPathComponent("sqlite3.db")
        dbPath = documentsDirectory.absoluteString
        Trace.mPrint(dbPath,.FilePath)
    }
    
    static let CycleNameTableString = """
    CREATE TABLE IF NOT EXISTS CycleName(
    Name VARCHAR(255) PRIMARY KEY,
    Count INT NOT NULL,
    SeqOrder INT NOT NULL);
    """
    
    static let AppSettngsString = """
    CREATE TABLE IF NOT EXISTS AppSettngs(
    aName VARCHAR(255) PRIMARY KEY,
    aValue VARCHAR(255));
    """
    
    static let PickGroupExpenseItemString = """
    CREATE TABLE IF NOT EXISTS PickGroupExpenseItem(
    Id VARCHAR(255) PRIMARY KEY,
    ItemName VARCHAR(255) NOT NULL,
    TotalAmount NUMERIC NOT NULL);
    """
    
    
    static let ExpenseItemTableString = """
    CREATE TABLE IF NOT EXISTS ExpenseItem(
    Id VARCHAR(255) PRIMARY KEY,
    ItemName VARCHAR(255) NOT NULL,
    TotalAmount NUMERIC NOT NULL,
    PurhaseDate CHAR(19) NOT NULL,
    InsertDateTime VARCHAR(255) NOT NULL);
    """
    
    static let SubscriptionTableString = """
    CREATE TABLE IF NOT EXISTS Subscription(
    Id VARCHAR(255) PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    Amount NUMERIC NOT NULL,
    AvgOfMonthAmount NUMERIC NOT NULL,
    TypeOfAmount VARCHAR(255) NOT NULL,
    CycleName VARCHAR(255) NOT NULL,
    CycleNote VARCHAR(255) NOT NULL,
    SeqOrder NUMERIC NOT NULL);
    """
}
//STRFTIME('%Y', DATE('now'))|| SUBSTR(PurhaseDate,6,5)
