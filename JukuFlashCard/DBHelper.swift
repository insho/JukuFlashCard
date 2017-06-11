//
//  DBHelper.swift
//  JukuFlashCard
//
//  Created by System Administrator on 5/28/17.
//  Copyright © 2017 jukuproject. All rights reserved.
//
import Foundation

class SQLiteDataStore {
    static let sharedInstance = SQLiteDataStore()
    let myDatabase: FMDatabase
    
    private init() {
        
        //Initiate DB and attach internal db
        let databaseURL = (NSBundle.mainBundle().resourceURL!).URLByAppendingPathComponent("JQuiz.db")
        let databasePath : NSString = databaseURL.absoluteString
        myDatabase = FMDatabase(path: databasePath as String)
        
    }
    
    
    /**
     Adds a pairing of a Word (or multiple words) and a Favorites list to the JFavorites table
     */
    static func insertWordsIntoFavorites(listEntry : MyListEntry) -> Bool {
        
        
        if (SQLiteDataStore.sharedInstance.myDatabase.open()) {
            
            attachInternalxDB();
            
            do {
                print("inserting id: \(listEntry.idstoaddorremove) into: \(listEntry.name), sys: \(listEntry.sys)")
                
                try SQLiteDataStore.sharedInstance.myDatabase.executeUpdate("INSERT OR REPLACE INTO JFavorites SELECT _id, ? as [Name], ? as [Sys] FROM Edict where _id in (\(listEntry.idstoaddorremove))", values: [listEntry.name, listEntry.sys]);
                SQLiteDataStore.sharedInstance.myDatabase.close()
                return true;
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            
            SQLiteDataStore.sharedInstance.myDatabase.close()
            
        } else {
            print("insertWordsIntoFavorites db not open error: \(SQLiteDataStore.sharedInstance.myDatabase.lastErrorMessage())")
            
        }
        
        
        
        return false;
        
        
    }
    
    
    /**
     Removes a Word/Favorite List pairing from the JFavorites table, thereby removing them from
     the "MyLists" in ListController_MyLists VC
     
     - parameter listeEntry: list item whose words (contained in listEntry.idstoaddorremove) are being deleted
     */
    static func deleteWordsFromFavorites(listEntry : MyListEntry) -> Bool {
        
        if (SQLiteDataStore.sharedInstance.myDatabase.open()) {
            
            attachInternalxDB();
            
            do {
                
                try SQLiteDataStore.sharedInstance.myDatabase.executeUpdate("DELETE FROM JFavorites WHERE [Name] = ? and Sys = ? and _id in (\(listEntry.idstoaddorremove))", values: [listEntry.name, listEntry.sys]);
                
                SQLiteDataStore.sharedInstance.myDatabase.close()
                
                return true;
            } catch let error as NSError {
                print("failed: \(error.localizedDescription)")
            }
            
            SQLiteDataStore.sharedInstance.myDatabase.close()
            
        } else {
            print("deleteWordsFromFavorites db not open: \(SQLiteDataStore.sharedInstance.myDatabase.lastErrorMessage())")
            
        }
        
        
        return false;
        
    }
    
    
    
    
    /*
     Create Internal tables (for creating and maintaining favorites lists)
     */
    static func createDefaultTables(){
        
        
        let databaseURL_Internal = NSURL(fileURLWithPath:NSTemporaryDirectory()).URLByAppendingPathComponent("JQuiz_Internal.db")
        let databasePath_Internal = databaseURL_Internal.absoluteString
        let myDatabase_internal = FMDatabase(path: databasePath_Internal as String)
        
        
        do {
            myDatabase_internal.open()
            try myDatabase_internal.executeUpdate("CREATE TABLE IF NOT EXISTS JFavorites (_id INTEGER, Name TEXT, Sys INTEGER)", values: nil)
            try myDatabase_internal.executeUpdate("CREATE TABLE IF NOT EXISTS JFavoritesLists (Name TEXT)", values: nil)
            
        } catch let error as NSError {
            print("createDefaultTables failed: \(error.localizedDescription)")
        }
        
        myDatabase_internal.close()
        
    }
    
    
    /**
     Attaches internal DB for queries (almost all queries) dealing with JFavorites db and favorites lists
     */
    static func attachInternalxDB() {
        
        
        let databaseURL_Internal = NSURL(fileURLWithPath:NSTemporaryDirectory()).URLByAppendingPathComponent("JQuiz_Internal.db")
        let databasePath_Internal = databaseURL_Internal.absoluteString
        
        //Attempt to attach internal DB
        SQLiteDataStore.sharedInstance.myDatabase.executeStatements("Attach DATABASE '\(databasePath_Internal)' AS JQuizInternal")
        
        
    }
    
    
    
}
