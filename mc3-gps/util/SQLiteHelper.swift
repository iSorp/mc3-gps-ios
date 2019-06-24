//
//  sqliteHelper.swift
//  mc3-gps
//
//  Created by Simon Wälti on 22.06.19.
//  Copyright © 2019 Simon Wälti. All rights reserved.
//

import Foundation
import SQLite3

func destroyDatabase(fileURL: URL) {
    do {
        if FileManager.default.fileExists(atPath: fileURL.path) {
            try FileManager.default.removeItem(atPath: fileURL.path)
        }
    } catch {
        print("Could not destroy \(fileURL) Database file.")
    }
}

func openDatabase(fileURL: URL) -> OpaquePointer? {
    var db: OpaquePointer? = nil
    if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
        print("Successfully opened connection to database at \(fileURL)")
        return db
    } else {
        print("Unable to open database. Verify that you created the directory described " +
            "in the Getting Started section.")
        return nil
    }
}

func closeDatabase(db: OpaquePointer){
    if sqlite3_close(db) == SQLITE_OK {
        print("Successfully closed connection to database")
    } else {
        print("Unable to close database. Verify that you created the directory described " +
            "in the Getting Started section.")
    }
}

func commandDatabase(db: OpaquePointer, commandStatement:String) {
    var statement: OpaquePointer? = nil
    if sqlite3_prepare_v2(db, commandStatement, -1, &statement, nil) == SQLITE_OK {
        if sqlite3_step(statement) == SQLITE_DONE {
            print("Successfully executed statement")
        }
    } else {
        print("statement could not be prepared.")
    }
    sqlite3_finalize(statement)
}



