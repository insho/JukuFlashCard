//
//  MyListTrashUndo.swift
//  JukuFlashCard
//
//  Created by System Administrator on 5/26/17.
//  Copyright © 2017 jukuproject. All rights reserved.
//

import UIKit

/**
 "Undo Delete" popup that shows after a user has deleted items from a MyList. It has
 one button that, when pressed, undoes the delete
 */
class MyListTrashUndo: UIViewController
{
    
    var delegate: TrashPressedUndoDelegate!
    var listdata : MyListEntry!;
    var tmpDataSet : [WordEntry]!;
    
    @IBOutlet weak var txtLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var txtUndo: UIButton!
    @IBAction func undobutton(sender: UIButton) {
        
        SQLiteDataStore.insertWordsIntoFavorites(listdata)
        delegate.trashPressedUndo(tmpDataSet);
    }
    
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bounds = UIScreen.mainScreen().bounds
        var shorterlength : CGFloat;
        if(bounds.width > bounds.height) {
            shorterlength = bounds.height
        } else {
            shorterlength = bounds.width
        }
        
        
        let totalwidth = shorterlength * 0.8;
        
        txtLabel.font = txtLabel.font.fontWithSize(19.0 * goldenRatio);
        txtUndo.titleLabel?.font = txtUndo.titleLabel?.font.fontWithSize(19.0 * goldenRatio);
        
        txtLabel.widthAnchor.constraintEqualToConstant((200.0/320.0) * totalwidth).active = true;
        txtUndo.widthAnchor.constraintEqualToConstant((120/320.0) * totalwidth ).active = true;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
}