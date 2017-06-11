//
//  Functions.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit


/**
 Create a ratio of the current screen bounds adjusted to the height of an iphone 6s, so that
 the layout items for larger/smaller device can be adjusted based on this ratio so they are the same relative size
 
 - parameter screenBounds: current screen bounds CGRect
 */
func setGoldenRatio(screenBounds: CGRect) -> CGFloat {
    
    var goldenRatio : CGFloat;
    
    if(screenBounds.width > screenBounds.height) {
        goldenRatio = screenBounds.width / 736;
    } else {
        goldenRatio = screenBounds.height / 736;
    }
    
    
    return goldenRatio;
}

/**Adjusts tables down past the height of the custom navbar (since the navbar is inserted dynamically). This is redundent,
 as the top anchor for tables won't change. It used to be that the custom navbar height shifted based on the orientation of the device,
 and therefore it was necessary to adjust table insets dynamically as well. This is no longer the case. SHOULD REMOVE
 */
func setTableInset(width: CGFloat, height:CGFloat, goldenRatio: CGFloat, extrapoints: CGFloat, extrasubtract: CGFloat, bottominset: CGFloat) -> UIEdgeInsets {
    return UIEdgeInsetsMake((44.0 + extrapoints) * goldenRatio, 0, bottominset*goldenRatio, 0);
}



//Checks if a preference default already exists
func userAlreadyExist(usernameKey: String) -> Bool {
    return NSUserDefaults.standardUserDefaults().objectForKey(usernameKey) != nil
}

//Creates default prefs
func setDefaultPreferences() {
    
    if(!userAlreadyExist("favoritesstarsarray")) {
        NSUserDefaults.standardUserDefaults().setObject(["Blue","Red"], forKey: "favoritesstarsarray")
    }
    
    if(!userAlreadyExist("showmylistheadercount")) {
        NSUserDefaults.standardUserDefaults().setObject(false, forKey: "showmylistheadercount")
        
    }
    
    
}




/*Creates a map of "translatios" between an english character in the alphabet and
 and its japanese Hiragana and Katakana equivalents. This will then be used to
 turn an english "Romaji" query into Japanese before searching the database **/
func getRomaji() -> [String : [RomajiTranslation]] {
    
    var romajiMap = [String : [RomajiTranslation]]();
    
    if (SQLiteDataStore.sharedInstance.myDatabase.open()) {
        
        SQLiteDataStore.attachInternalxDB()
        
        let characterQuery = String(sep:", ",
                                    
                                    "SELECT DISTINCT Key ",
                                    ",Type ",
                                    "FROM [Characters] ",
                                    "WHERE Type in ('Romaji','Hiragana','Katakana') ORDER BY [Type] asc, _id  asc "
        );
        
        
        let results:FMResultSet! = SQLiteDataStore.sharedInstance.myDatabase.executeQuery(characterQuery,
                                                                                          withArgumentsInArray: nil)
        
        if (results != nil) {
            
            var hiragana = [String]();
            var katakana = [String]();
            var romaji = [String]();
            
            while (results.next()) {
                switch(results.stringForColumn("Type")) {
                case "Romaji":
                    romaji.append(results.stringForColumn("Key"))
                    break;
                case "Hiragana":
                    hiragana.append(results.stringForColumn("Key"))
                    break;
                case "Katakana":
                    katakana.append(results.stringForColumn("Key"))
                    break;
                default:
                    break;
                }
                
            }
            
            
            for i in 0 ..< romaji.count {
                var tmp = [RomajiTranslation]();
                
                if(romajiMap.keys.contains(romaji[i])){
                    tmp = romajiMap[romaji[i]]!;
                } else {
                    tmp = [RomajiTranslation]();
                }
                
                tmp.append(RomajiTranslation(hiragana: hiragana[i],katakana: katakana[i]));
                romajiMap[romaji[i]] = tmp;
                
            }
            
            
            var extratmp = [RomajiTranslation]();
            extratmp.append(RomajiTranslation(hiragana: "ん",katakana: "ン"));
            romajiMap["n"] = extratmp;
            
        }
        
        SQLiteDataStore.sharedInstance.myDatabase.close()
    } else {
        print("Error3: \(SQLiteDataStore.sharedInstance.myDatabase.lastErrorMessage())")
    }
    
    
    return romajiMap;
}



/**
 Creates a map of [wordids : favoritelists associated with that word] for a string of word ids. Used to attach favorite lists
 to a set of words (so when a search returns a set of words, this map can attach favorite lists to them if applicable, and those
 words that are saved to mylists already will show it
 
 - parameter wordIds: comma delimited string of word ids (for which the favorite lists will be pulled)
 - parameter database: db connection
 - parameter colorlistsPrefs: available system lists
 */
func getCurrentFavoritesForWordIds(wordIds : String, database : FMDatabase, colorlistsPrefs : [String]) -> [Int : StarColorData]  {
    
    var currentFavoritesMap = [Int : StarColorData]();
    let sqlQuery = "SELECT DISTINCT [_id],[Name],[Sys] FROM JFavorites where [_id] in (\(wordIds)) ORDER BY _id asc, sys desc, Name asc"
    
    do {
        
        let rs = try database.executeQuery(sqlQuery, values: nil)
        var currentidgroup : Int = -1;
        var idgroupSystemLists : [String] = [];
        var idgroupOtherLists : [String] = [];
        
        while rs.next() {
            
            let id = Int(rs.intForColumn("_id"))
            let name = rs.stringForColumn("Name")
            let sys = rs.intForColumn("Sys")
            
            print("xx: id: \(id) name: \(name) sys: \(sys)")
            
            if(currentidgroup == -1 ) {
                currentidgroup = id
            }
            
            
            if(id != currentidgroup || rs.hasAnotherRow() == false) {
                let tmpid = currentidgroup;
                let tmpsystemlists = idgroupSystemLists;
                let tmpotherlists = idgroupOtherLists;
                currentFavoritesMap[tmpid] =  StarColorData(systemlists: tmpsystemlists, otherlists: tmpotherlists);
                print("xxx colorhash: \(tmpid) - \(currentFavoritesMap[tmpid] )")
                currentidgroup = id;
                idgroupSystemLists = [];
                idgroupOtherLists = [];
                
            }
            
            if(sys == 1 && colorlistsPrefs.contains(name)) {
                idgroupSystemLists.append(name)
                print("yy: id: \(id) idgroupSystemLists: \(idgroupSystemLists)")
            } else if(sys == 0) {
                idgroupOtherLists.append(name)
                print("yy: id: \(id) idgroupOtherLists: \(idgroupOtherLists)")
            }
            
        }
        
        /** Insert the final grouping (after there are no more rows)*/
        currentFavoritesMap[currentidgroup] =  StarColorData(systemlists: idgroupSystemLists, otherlists: idgroupOtherLists);
        
        print("xxx FINAL colorhash: \(currentidgroup) - \(currentFavoritesMap[currentidgroup] )")
        
    } catch let error as NSError {
        print("failed: \(error.localizedDescription)")
    }
    
    return currentFavoritesMap;
}


//Finds current longer side and shorter side of the screen, so that navbar (etc) lengths can be adjusted on screen rotation changed
func lengthsizes() -> (CGFloat, CGFloat) {
    var shorterlength : CGFloat;
    var longerlength : CGFloat;
    let screenbounds = UIScreen.mainScreen().bounds;
    if(screenbounds.width > screenbounds.height) {
        shorterlength = screenbounds.height;
        longerlength = screenbounds.width;
    } else {
        shorterlength = screenbounds.width
        longerlength = screenbounds.height;
    }
    
    return (shorterlength,longerlength)
}
















