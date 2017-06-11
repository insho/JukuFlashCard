//
//  Structures.swift
//  Juku
//
//  Created by System Administrator on 5/24/17.
//  Copyright © 2017 jukuproject. All rights reserved.
//

import UIKit


/**
 Object representing a word in the Japanese "Edict" dictionary. It also contains
 a StarColorData object, which contains data for those favorite lists that the word is
 associated with.
 
 */
struct WordEntry {
    var _id : Int!
    var kanji : String!
    var furigana : String!
    var definition : String!
    var favoriteLists : StarColorData!
    
    init(_id: Int!) {
        self._id = _id
        self.favoriteLists = StarColorData();
    }
    
    init(_id: Int!, kanji : String!, furigana: String!, definition : String!) {
        self._id = _id
        self.kanji = kanji
        self.furigana = furigana
        self.definition = definition
        self.favoriteLists = StarColorData();
    }
    
    //Creates a combo of Kanji and Furigana to be displayed in Search/MyList Browse VCs
    func getDisplayKanji() -> String {
        if(furigana != nil && furigana.characters.count > 0
            && furigana != kanji){
            return kanji.stringByAppendingString(" \(furigana)");
        } else {
            return kanji;
        }
    }
    
    
    
    /**
     Returns the definition string, parsed into a multiple lines with a bullet point for each definition
     Sub-definitions are demarkated like so: "(1)","(2)","(3)" etc
     */
    func getDisplayDefinition() -> String {
        
        var stringBuilder : String! = "";
        for i in 1 ..< 21 {
            let s = "(\(i))";
            let sNext = "(\(i + 1))";
            
            
            if(definition == nil) {
                return stringBuilder;
            } else if (definition.containsString(s)) {
                var endIndex = definition.endIndex;
                if (definition.containsString(sNext)) { //If we can find the next "(#)" in the string, we'll use it as this definition's end point
                    endIndex = (definition.rangeOfString(sNext, options: .LiteralSearch)?.startIndex)!;
                }
                
                var sentence = definition.substringWithRange(Range<String.Index>((definition.rangeOfString(s, options: .LiteralSearch)?.endIndex)! ..< endIndex));
                
                
                //Capitalize it
                if (sentence.characters.count > 1) {
                    
                    sentence  = sentence[sentence.startIndex...sentence.startIndex].uppercaseString.stringByAppendingString(sentence[sentence.startIndex.advancedBy(1) ..< sentence.endIndex])
                    
                }
                
                if(i == 1) {
                    stringBuilder = stringBuilder.stringByAppendingString("• \(sentence)");
                } else {
                    stringBuilder = stringBuilder.stringByAppendingString("\n• \(sentence)");
                }
                
            } else if (i == 1) { //if the thing doesn't contain a "(1)", just print the whole definition in line 1 of the array.
                var sentence = definition;
                if (sentence.characters.count > 1) {
                    
                    sentence  = sentence[sentence.startIndex...sentence.startIndex].uppercaseString.stringByAppendingString(sentence[sentence.startIndex.advancedBy(1) ..< sentence.endIndex])
                }
                if(i == 1) {
                    stringBuilder = stringBuilder.stringByAppendingString("• \(sentence)");
                } else {
                    stringBuilder = stringBuilder.stringByAppendingString("\n• \(sentence)");
                }
            }
            
        }
        
        
        return stringBuilder;
    }
    
}

/**
 Object containing arrays of the favorite lists that a word
 can be assigned to, or is currently assigned to. Lists are broken
 into two categories: "system lists"--the default lists with
 the colored stars beside them that a user can toggle through by clicking
 the favorites star next to a word-- and regular "user created" lists.
 */
struct StarColorData {
    var systemlists: [String]!
    var otherlists: [String]!
    
    init(systemlists: [String]!, otherlists: [String]!) {
        self.systemlists = systemlists
        self.otherlists = otherlists
        
    }
    
    init(){
        self.systemlists = [String]();
        self.otherlists = [String]();
    }
    
    func getTotalWordListCount() -> Int {
        return self.systemlists.count + self.otherlists.count
        
    }
    
    func shouldOpenListPopoverOnClick() -> Bool {
        if(self.systemlists.count > 1 || self.otherlists.count > 0) {
            return true;
        }
        
        return false;
        
    }
    
    
}

/* Object with info that is relayed between the FlashCards MenuPopover and the
 MyList VC (which then segues to the flashcard activity) */
struct MenuPopoverToSeguePackage {
    
    var frontvalue : String!
    var backvalue : String!
    var currentMyList : MyListEntry!;
    
    init(frontvalue: String!, backvalue: String!, currentMyList : MyListEntry!) {
        self.frontvalue = frontvalue
        self.backvalue = backvalue
        self.currentMyList = currentMyList
    }
    
}


/**
 Used to create the Romaji-to-Japanese translation map, which
 helps translate english Romaji dictionary queries into Japanese so that
 the Edict dictionary can be queried correctly
 */
struct RomajiTranslation {
    var hiragana : String!;
    var katakana : String!;
    
    init(hiragana: String!, katakana : String!) {
        self.hiragana = hiragana
        self.katakana = katakana
    }
}

/**
 Flashcard Object representing a flashcard
 */
struct FlashCardData {
    var _id : Int!;
    var front : String!;
    var back : String!;
    var furigana : String!;
    
    init(_id: Int!, front : String!, back: String!, furigana : String!) {
        self._id = _id
        self.front = front
        self.back = back
        self.furigana = furigana
    }
}


/**
 Represents a single list in the MyLists VC. Used when editing or adding to lists,
 as well as when displaying the expandable list items in the ListController_MyLists VC
 */
struct MyListEntry {
    
    var name: String!
    var sys: Int!
    var checkedstatus: Int!
    var idstoaddorremove: String!
    
    var items: [String]!
    var collapsed: Bool!
    var wordCount : Int!
    
    init(name: String!, sys: Int!, checkedstatus: Int!, idstoaddorremove: String!) {
        self.name = name
        self.sys = sys
        self.checkedstatus = checkedstatus
        self.idstoaddorremove = idstoaddorremove
    }
    
    init(name: String!, sys: Int!, items : [String]!, collapsed: Bool!,wordCount: Int!) {
        self.name = name
        self.sys = sys
        self.items = items
        self.collapsed = collapsed
        self.wordCount = wordCount
    }
    
}


