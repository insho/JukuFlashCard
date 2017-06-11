//  JukuProject
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit

protocol CollapsibleTableViewHeaderDelegate_MyLists {
    func toggleSection_MyLists(header: CollapsibleTableViewHeader_MyLists, section: Int)
}

//Collapsable header cell for ListController_MyLists
class CollapsibleTableViewHeader_MyLists: UITableViewHeaderFooterView {
    
    
    var delegate: CollapsibleTableViewHeaderDelegate_MyLists?
    var section: Int = 0
    
    let starbutton = UIButton();
    let titleLabel = UILabel()
    let titleLabel_Plain = UILabel();
    
    let titleLabel_CreateAList = UnderlinedLabel();
    let emptylabel = UILabel();
    
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        
        contentView.translatesAutoresizingMaskIntoConstraints = false;
        titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        starbutton.translatesAutoresizingMaskIntoConstraints = false;
        titleLabel_Plain.translatesAutoresizingMaskIntoConstraints = false;
        emptylabel.translatesAutoresizingMaskIntoConstraints = false;
        titleLabel_CreateAList.translatesAutoresizingMaskIntoConstraints = false;
        
        titleLabel.font = UIFont.boldSystemFontOfSize(18)
        titleLabel.textAlignment = NSTextAlignment.Left;
        titleLabel_Plain.font = UIFont.boldSystemFontOfSize(18)
        titleLabel_Plain.textAlignment = NSTextAlignment.Left;
        titleLabel_CreateAList.font = UIFont.boldSystemFontOfSize(18)
        titleLabel_CreateAList.textAlignment = NSTextAlignment.Left;
        
        emptylabel.text = "  (empty)"
        emptylabel.font = UIFont.boldSystemFontOfSize(13)
        emptylabel.textAlignment = NSTextAlignment.Left;
        
        contentView.addSubview(titleLabel_Plain)
        contentView.addSubview(starbutton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(emptylabel)
        contentView.addSubview(titleLabel_CreateAList)
        contentView.backgroundColor = UIColor.clearColor();
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let views = [
            "titleLabel_Plain" : titleLabel_Plain,
            "titleLabel" : titleLabel,
            "starbutton" : starbutton,
            "emptylabel" : emptylabel,
            "titleLabel_CreateAList" : titleLabel_CreateAList
        ]
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-20-[titleLabel_CreateAList][titleLabel_Plain][starbutton][titleLabel][emptylabel]",
            options: [NSLayoutFormatOptions.AlignAllCenterY],
            metrics: nil,
            views: views
            ))
        
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[titleLabel_CreateAList]-|",
            options: [],
            metrics: nil,
            views: views
            ))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[titleLabel_Plain]-|",
            options: [],
            metrics: nil,
            views: views
            ))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[starbutton]-|",
            options: [],
            metrics: nil,
            views: views
            ))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[titleLabel]-|",
            options: [],
            metrics: nil,
            views: views
            ))
        
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-[emptylabel]-|",
            options: [],
            metrics: nil,
            views: views
            ))
        
        
        
        
        
    }
    
    // Trigger toggle section when tapping on the header
    func tapHeader(gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? CollapsibleTableViewHeader_MyLists else {
            return
        }
        delegate?.toggleSection_MyLists(self, section: cell.section)
    }
    
    func setCollapsed(collapsed: Bool) {
        
    }
    
    
    override func prepareForReuse() {
        self.userInteractionEnabled = true;
        for view in contentView.subviews {
            view.removeConstraints(view.constraints)
        }
        
    }
}
