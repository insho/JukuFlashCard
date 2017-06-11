//
//  ContainerMainView.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit


//Parent VC for tab controller with Search and MyList tabs.
class ContainerMainView: UIViewController, ContainerMainView_ChangeNavBarDelegate {
    
    var centerNavigationController: UINavigationController!
    var centerViewController: UITabBarController!
    
    var goldenRatio : CGFloat!;
    
    var navbartitle : String!;
    var navBar: UINavigationBar!;
    var navBarHeight: CGFloat!;
    var subviewstack = [String]();  // Title for each subview
    var mylistsorjlpt = 1;
    var selectall : UIButton!;
    var cutcopy : UIButton!;
    var trash : UIButton!;
    var cancel : UIButton!;
    var viewtodirectlypopto : String!;
    var screenBounds = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goldenRatio = setGoldenRatio(screenBounds);
        let main_storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        centerViewController = main_storyboard.instantiateViewControllerWithIdentifier("tabcontroller_main") as? UITabBarController;
        
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        
        centerViewController.tabBarItem.title = "";
        centerViewController.tabBar.itemSpacing = screenBounds.width/3 - 20.0 * goldenRatio;
        centerNavigationController = UINavigationController(rootViewController: centerViewController)
        centerNavigationController.interactivePopGestureRecognizer?.enabled = false
        
        navBar = UINavigationBar()
        navBarHeight = 44 * goldenRatio;
        navBar.frame = CGRect(x: 0, y: 0, width: screenBounds.width, height: navBarHeight)
        
        centerNavigationController.navigationBar.hidden = true;
        centerNavigationController.view.addSubview(navBar);
        navBar.barTintColor = UIColor(hex: 0x2196F3);
        
        navbartitle = "JukuFlashCard";
        
        // Set up the menu button on the left side of the navigation bar
        changeNavBarButtons_SetMain();
        
        // MAKE THE TITLE WHITE
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(20.0 * goldenRatio)]
        navBar.titleTextAttributes = titleDict as? [String : AnyObject]
        
        //MAKE THE BACK ARROW WHITE
        navBar.tintColor = UIColor.whiteColor();
        navBar.barTintColor = UIColor(hex: 0x2196F3);
        
        view.addSubview(centerNavigationController.view)
        addChildViewController(centerNavigationController)
        
        centerNavigationController.didMoveToParentViewController(self)
        
        let childview_mylists =  centerViewController.childViewControllers[1].childViewControllers[0] as? ListController_MyLists
        childview_mylists?.navbardelegate_mainview = self;
        
        
    }
    
    /**
     Sets the Navigation bar so the title displays app name and there is one options menu button on the right,
     which opens Prefences VC
     */
    func changeNavBarButtons_SetMain(){
        let button = UIButton(type: .System)
        button.setImage(UIImage(named: "ic_menu_white")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        button.setTitle("", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        
        let buttonheight = 24.0 * goldenRatio;
        button.frame = CGRectMake(0,0,buttonheight,buttonheight)
        button.addTarget(self, action: #selector(self.showPreferences), forControlEvents: .TouchUpInside)
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(20.0 * goldenRatio)]
        navBar.titleTextAttributes = titleDict as? [String : AnyObject]
        navBar.tintColor = UIColor.whiteColor();
        navBar.barTintColor = UIColor(hex: 0x2196F3);
        button.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
        
        let suggestButtonContainer = UIView(frame: button.frame)
        suggestButtonContainer.addSubview(button)
        
        let sidemenuButton = UIBarButtonItem();
        let navItem = UINavigationItem(title: "JukuFlashCard");
        navItem.leftBarButtonItem = sidemenuButton;
        navBar.setItems([navItem], animated: false);
        
        navBar.topItem?.rightBarButtonItem = UIBarButtonItem(customView: suggestButtonContainer);
        navBar.topItem?.leftBarButtonItems = [];
        
    }
    
    /**
     Changes nav bar so the title displays mylist name on the left next to the back button
     
     - parameter title: the title that will be displayed in the navbar, either the generic "JukuFlashCard", or
     the title of the current activity
     
     */
    func changeNavBarButton_SetBackButton(title : String) {
        
        let button = UIButton(type: .System)
        button.setImage(UIImage(named: "ic_keyboard_arrow_left_white")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        
        
        //        if(goldenRatio >= 1) {
        
        
        var title = "   ";
        title.appendContentsOf(title)
        button.setTitle(title, forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.titleLabel!.font = button.titleLabel!.font.fontWithSize(15.0 * goldenRatio)
        
        let buttonheight = 36.0 * goldenRatio;
        button.frame = CGRectMake(0,0,buttonheight + (button.titleLabel?.requiredWidth())!,buttonheight)
        button.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
        
        
        
        var vertadjustment : CGFloat = 0.0;
        if (goldenRatio < 1) {
            vertadjustment = -2.0 * goldenRatio;
        }
        navBar.setTitleVerticalPositionAdjustment(-vertadjustment, forBarMetrics: .Default)
        button.transform = CGAffineTransformMakeTranslation(0, -(vertadjustment + 2.0 * goldenRatio))
        
        
        button.addTarget(self, action: #selector(ContainerMainView.backtomain), forControlEvents: .TouchUpInside)
        button.tag = 10;
        
        let suggestButtonContainer = UIView(frame: button.frame)
        suggestButtonContainer.addSubview(button)
        
        navBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: suggestButtonContainer);
        navBar.topItem?.rightBarButtonItems = [];
        //        } else {
        //            button.setTitle("", forState: .Normal)
        //            button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        //
        //            let buttonheight = 36.0 * goldenRatio;
        //            button.frame = CGRectMake(0,0,buttonheight,buttonheight)
        //
        //
        //            navBar.setTitleVerticalPositionAdjustment(8 * goldenRatio, forBarMetrics: .Default)
        //
        //
        //            button.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill;
        //            button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
        //            button.transform = CGAffineTransformMakeTranslation(0, (8 * goldenRatio))
        //
        //                button.addTarget(self, action: #selector(ContainerMainView.poptheview), forControlEvents: .TouchUpInside)
        //                button.tag = 10;
        //
        //
        //            let suggestButtonContainer = UIView(frame: button.frame)
        //            suggestButtonContainer.addSubview(button)
        //
        //            navBar.topItem?.leftBarButtonItem = UIBarButtonItem(customView: suggestButtonContainer);
        //            navBar.topItem?.rightBarButtonItems = [];
        //        }
        
    }
    
    
    /**
     Pops stack returning to main level (MyList controller) and change nav bar buttons to their original state
     */
    func backtomain(){
        
        NSNotificationCenter.defaultCenter().postNotificationName("updatemylistcontroller", object: self)
        
        poptheview();
        changeNavBarButtons_SetMain()
        navBar.topItem?.title = "JukuFlashCard"
        subviewstack = [];
        centerViewController.tabBar.hidden = false;
    }
    
    
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    //Show Preferences VC
    func showPreferences() {
        let prefsController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("mainmenunav") as! Preferences_NavController
        prefsController.popoverPresentationController?.sourceView = self.view
        self.presentViewController(prefsController, animated: true, completion: nil)
    }
    
    
    /**
     Displays the set of navbar buttons for the BrowseItems_MyLists controller, allowing user to
     cut/copy, select all and deselect-all options for selected groups of words
     */
    func setthecutcopyitems_mainview() {
        
        selectall = UIButton(type: .System)
        cutcopy = UIButton(type: .System)
        trash = UIButton(type: .System)
        cancel = UIButton(type: .System)
        
        
        selectall.setImage(UIImage(named: "ic_select_all_white_24dp")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        cutcopy.setImage(UIImage(named: "ic_content_copy_white_24dp")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        trash.setImage(UIImage(named: "ic_delete_white_24dp")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        cancel.setImage(UIImage(named: "ic_clear_white_24dp")?.imageWithRenderingMode(.AlwaysOriginal), forState: .Normal)
        
        // Set up the title
        selectall.addTarget(self, action: #selector(selectallPressed), forControlEvents: .TouchUpInside)
        cutcopy.addTarget(self, action: #selector(cutcopyPressed), forControlEvents: .TouchUpInside)
        trash.addTarget(self, action: #selector(trashPressed), forControlEvents: .TouchUpInside)
        cancel.addTarget(self, action: #selector(cancelPressed), forControlEvents: .TouchUpInside)
        
        setCutCopyButtonFormatting(selectall)
        setCutCopyButtonFormatting(cutcopy)
        setCutCopyButtonFormatting(trash)
        setCutCopyButtonFormatting(cancel)
        
    }
    
    /**
     Sets formatting for a UIButton being placed into a custom navbar
     - parameter button: button that is being formatted
     */
    private func setCutCopyButtonFormatting(button: UIButton) {
        button.setTitle("", forState: .Normal)
        let buttonheight = 24.0 * goldenRatio;
        button.frame = CGRectMake(0,0,buttonheight,buttonheight)
        
        var vertadjustment : CGFloat = 0.0;
        if(navBarHeight > (44*goldenRatio) && goldenRatio >= 1){
            vertadjustment = 4.0 * goldenRatio;
        } else if (goldenRatio < 1) {
            vertadjustment = -2.0 * goldenRatio;
        }
        
        button.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill;
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill;
        if(goldenRatio >= 1) {
            button.transform = CGAffineTransformMakeTranslation(0, -(vertadjustment + 2.0 * goldenRatio))
        } else {
            button.transform = CGAffineTransformMakeTranslation(0, 8*goldenRatio)
        }
    }
    
    
    func selectallPressed(){
        NSNotificationCenter.defaultCenter().postNotificationName("selectallPressedNotification", object: self)
    }
    
    func cutcopyPressed(){
        NSNotificationCenter.defaultCenter().postNotificationName("cutcopyPressedNotification", object: self)
    }
    
    func trashPressed(){
        NSNotificationCenter.defaultCenter().postNotificationName("trashPressedNotification", object: self)
    }
    
    func cancelPressed(){
        NSNotificationCenter.defaultCenter().postNotificationName("cancelPressedNotification", object: self)
    }
    
    
    /*
     When the cut/copy button is pressed (While user is browsing words and has selected some), this launches
     the BrowseItems_MyLists_CutCopy popover
     - parameter show : bool, true to show cut/copy items, false to hide
     */
    func showthecutcopyitems_mainview(show: Bool) {
        
        if(show == true) {
            
            if(selectall == nil) {
                setthecutcopyitems_mainview()
            }
            
            let spacerframe = UIButton(type: .System)
            spacerframe.frame = CGRectMake(0,0,2 * goldenRatio,24 * goldenRatio)
            let spacer = UIView(frame: spacerframe.frame);
            
            let buttonContainer_cancel = UIView(frame: cancel.frame)
            buttonContainer_cancel.addSubview(cancel)
            let buttonContainer_trash = UIView(frame: trash.frame)
            buttonContainer_trash.addSubview(trash)
            let buttonContainer_cutcopy = UIView(frame: cutcopy.frame)
            buttonContainer_cutcopy.addSubview(cutcopy)
            let buttonContainer_selectall = UIView(frame: selectall.frame)
            buttonContainer_selectall.addSubview(selectall)
            
            
            if(navBar.topItem != nil) {
                navBar.topItem?.title = "";
            }
            
            if(goldenRatio >= 1) {
                navBar.topItem?.rightBarButtonItems = [UIBarButtonItem(customView: buttonContainer_cancel),UIBarButtonItem(customView: spacer),UIBarButtonItem(customView: buttonContainer_trash),UIBarButtonItem(customView: spacer),UIBarButtonItem(customView: buttonContainer_cutcopy),UIBarButtonItem(customView: spacer),UIBarButtonItem(customView: buttonContainer_selectall)];
                
            } else {
                
                navBar.topItem?.rightBarButtonItems = [UIBarButtonItem(customView: buttonContainer_cancel),UIBarButtonItem(customView: buttonContainer_trash),UIBarButtonItem(customView: buttonContainer_cutcopy),UIBarButtonItem(customView: buttonContainer_selectall)];
            }
            
            
        } else {
            navBar.topItem?.rightBarButtonItems = [];
        }
        
    }
    
    
    
    func starPressed() {
        NSNotificationCenter.defaultCenter().postNotificationName("starPressedNotification", object: self)
        
    }
    
    
    
    /**
     Popping ONE view back in the stack
     If we hit the top, show the menu, etc, and the stack should be EMPTY
     */
    func poptheview(){
        
        print("Popping stack")
        
        
        if let x = centerViewController.childViewControllers[mylistsorjlpt] as? UINavigationController {
            
            
            
            if(subviewstack.count <= 1) {
                
                //Update main MyList menu
                NSNotificationCenter.defaultCenter().postNotificationName("updatemylistcontroller", object: self)
                
                navbartitle = "JukuFlashCard"
                changeNavBarButtons_SetMain()
                centerViewController.tabBar.hidden = false;
                
            } else {
                navbartitle = subviewstack.last
                changeNavBarButton_SetBackButton(navbartitle)
                centerViewController.tabBar.hidden = true;
            }
            
            if(subviewstack.count>0) {
                subviewstack.removeLast()
            }
            x.popViewControllerAnimated(true);
            
        }
        
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        
        screenBounds = UIScreen.mainScreen().bounds
        redoNavBar(screenBounds.width)
        
        if(centerViewController != nil && centerViewController.tabBar.items != nil && centerViewController.tabBar.items?.count == 2) {
            centerViewController.tabBar.items![0].imageInsets = UIEdgeInsetsMake(6 * goldenRatio,0,-6*goldenRatio, 0);
            centerViewController.tabBar.items![1].imageInsets = UIEdgeInsetsMake(6 * goldenRatio,0,-6 * goldenRatio, 0);
        }
        centerViewController.reloadInputViews()
    }
    
    
    func reloadmainlistcontroller() {
        if let childview_mylists =  centerViewController.childViewControllers[1].childViewControllers[0] as? ListController_MyLists {
            childview_mylists.reloadtableselector();
        }
        
    }
    
    
    //Adjusts custom navigation bars width/height on orientation change
    override func willRotateToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        
        var longside: CGFloat;
        var shortside: CGFloat;
        if(screenBounds.width > screenBounds.height) {
            longside = screenBounds.width
            shortside = screenBounds.height
        } else {
            longside = screenBounds.height
            shortside = screenBounds.width
        }
        
        
        
        if (navBar != nil) {
            
            let triggerTime = (Int64(NSEC_PER_MSEC) * 200)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                
                if(toInterfaceOrientation.isLandscape) {
                    self.redoNavBar(longside);
                } else {
                    self.redoNavBar(shortside);
                }
                
                
            })
            
            
        }
    }
    
    /**
     Adjusts navigation bar width, as well as view controller tab bar item spacing
     
     - parameter width: new width for the navigation bar
     */
    func redoNavBar(width: CGFloat) {
        
        navBarHeight = 44 * goldenRatio;
        navBar.frame = CGRect(x: 0, y: 0, width: width, height: navBarHeight)
        centerViewController.tabBar.itemSpacing = width/3 - 20.0 * goldenRatio;
    }
    
    
    
    //When navigating back to the main VC (Search/MyLists), this updates the current visible VCs if an update is needed
    @IBAction func unwindToMain(segue: UIStoryboardSegue) {
        
        if let sourceViewController = segue.sourceViewController as? Preferences_NavController {
            
            // IF Something has happened in the preferences screen that has changed the way the main VCs will look, reload those VCs
            if(sourceViewController.updatethemanview == true) {
                if(centerViewController != nil && centerViewController.childViewControllers.count == 2) {
                    if let childview_mylists =  centerViewController.childViewControllers[1].childViewControllers[0] as? ListController_MyLists {
                        
                        childview_mylists.reloadtableselector();
                    } else if let childview_mylists =  centerViewController.childViewControllers[1].childViewControllers[0] as? BrowseItems_MyLists {
                        childview_mylists.reloadtableselector_mylist();
                    }
                    
                    if let childview_search =  centerViewController.childViewControllers[0].childViewControllers[0] as? Search_test {
                        
                        childview_search.updatePreferenceFavorites();
                    }
                    
                    
                }
                
                
            }
            
        }
        
    }
    
}
