//
//  Preferences_NavController
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit



//Navigation controller for Preference fragment. Has its own navigation bar and back button
class Preferences_NavController: UINavigationController
    
{
    
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds);
    var navbartitle : String!;
    var updatethemanview = false;
    var afterunwindopenworddetail_id : Int!;
    
    var navBar : UINavigationBar!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Create the Navigation Bar
        self.navigationBar.removeFromSuperview()
        navBar = UINavigationBar()
        navBar.barTintColor = UIColor(hex: 0x2196F3);
        self.view.addSubview(navBar)
        let screenBounds = UIScreen.mainScreen().bounds
        
        setUpNavigationBar(screenBounds.width, screenheight: screenBounds.height)
        
    }
    
    
    
    func backbuttonpressed(){
        self.performSegueWithIdentifier("unwindToMainVC", sender: nil)
    }
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    /**
     Creates custom navigation bar for the navcontroller
     
     - parameter screenwidth: width of screen
     - parameter screenheight: height of screen
     */
    func setUpNavigationBar(screenwidth: CGFloat, screenheight: CGFloat)  {
        
        if(navBar == nil) {
            navBar = UINavigationBar()
            navBar.barTintColor = UIColor(hex: 0x2196F3);
            self.view.addSubview(navBar)
            
        }
        
        var navItem = UINavigationItem(title: "Preferences");
        if(navbartitle != nil) {
            navItem = UINavigationItem(title: navbartitle);
            
        }
        
        
        
        let navBarHeight : CGFloat = 44 * goldenRatio;
        
        navBar.frame = CGRect(x: 0, y: 0, width: screenwidth, height: navBarHeight)
        
        let button = UIButton(type: .System)
        button.setImage(UIImage(named: "ic_keyboard_arrow_left_white")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        button.setTitle("", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        let buttonheight = 36.0 * goldenRatio;
        button.frame = CGRectMake(0,0,buttonheight,buttonheight)
        
        var vertadjustment : CGFloat = 0.0;
        if(navBarHeight > (44*goldenRatio)){
            vertadjustment = 4.0 * goldenRatio;
        }
        
        // Set up the title
        if(goldenRatio >= 1) {
            navBar.setTitleVerticalPositionAdjustment(-vertadjustment, forBarMetrics: .Default)
        } else {
            navBar.setTitleVerticalPositionAdjustment(8*goldenRatio, forBarMetrics: .Default)
        }
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(20.0 * goldenRatio)]
        navBar.titleTextAttributes = titleDict as? [String : AnyObject]
        navBar.tintColor = UIColor.whiteColor();
        button.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
        
        if(goldenRatio >= 1) {
            button.transform = CGAffineTransformMakeTranslation(0, -(vertadjustment + 2.0 * goldenRatio))
        } else {
            button.transform = CGAffineTransformMakeTranslation(0, 8*goldenRatio)
        }
        
        button.addTarget(self, action: #selector(backbuttonpressed), forControlEvents: .TouchUpInside)
        
        let suggestButtonContainer = UIView(frame: button.frame)
        suggestButtonContainer.addSubview(button)
        
        navBar.setItems([navItem], animated: false);
        navBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: suggestButtonContainer);
        navBar.topItem?.rightBarButtonItems = [];
        self.view.reloadInputViews();
        
    }
    
}
