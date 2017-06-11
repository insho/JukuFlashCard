//
//  customTableViewCell_BrowseItem_MyLists.swift
//  JukuFlashCard
//
//  Created by System Administrator on 5/28/17.
//  Copyright © 2017 jukuproject. All rights reserved.
//

import UIKit


/**
 Custom cell displaying a single word from the Edict dictionary. Used in MyLists Browse VC.
 */
class customTableViewCell_BrowseItem_MyLists: UITableViewCell , UIPopoverPresentationControllerDelegate  {
    
    
    @IBOutlet weak var mcellKanji: UILabel!
    @IBOutlet weak var mcellDefinition: UILabel!
    
    
    var pkey : Int?;
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func prepareForReuse() {
        super.selected = false;
        mcellKanji.text = "";
        mcellDefinition.text = "";
        super.backgroundColor = UIColor.clearColor();
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}


protocol TrashPressedUndoDelegate {
    func trashPressedUndo(pkeyarray_tmp : [WordEntry] );
}
