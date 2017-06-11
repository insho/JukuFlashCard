//
//  customTableViewCell_ListPopover.swift
//  JukuFlashCard
//
//  Created by System Administrator on 5/29/17.
//  Copyright © 2017 jukuproject. All rights reserved.
//

import UIKit



//Custom cell for the ChooseFavoritesLists popover. Checkbox, star image, listname label
class customTableViewCell_ListPopover: UITableViewCell {
    
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var checkbox: UIButton!
    @IBOutlet weak var starimage: UIButton!
    @IBOutlet weak var listlabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func prepareForReuse() {
        
        super.selected = false;
        
        for constraint in self.constraints {
            self.removeConstraint(constraint)
        }
        
    }
    
    
}