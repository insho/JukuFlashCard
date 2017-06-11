//
//  Preferences.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit


//Choose preferences. User can select which "system lists" to include in the ListControlle_MyLists
class Preferences: UITableViewController, UITextFieldDelegate {
    
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds)
    let screenBounds = UIScreen.mainScreen().bounds
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDefaultPreferences();
        
        let favoritesArray = NSUserDefaults.standardUserDefaults().stringArrayForKey("favoritesstarsarray");
        let image = UIImage(named: "ic_star_black")?.imageWithRenderingMode(.AlwaysTemplate)
        let showmylistheadercount = NSUserDefaults.standardUserDefaults().boolForKey("showmylistheadercount");
        
        showmylistheadercount_switch.on = showmylistheadercount;
        
        blustar.setImage(image, forState: .Normal)
        greenstar.setImage(image, forState: .Normal)
        redstar.setImage(image, forState: .Normal)
        yellowstar.setImage(image, forState: .Normal)
        
        if(favoritesArray != nil) {
            
            if(favoritesArray!.contains("Blue")){
                bluestar_switch.on = true;
                blustar.tintColor = UIColor.blueColor()
                bluestar_switch.superview?.alpha = 1.0;
            }else {
                bluestar_switch.on = false;
                blustar.tintColor = UIColor.blackColor()
                bluestar_switch.superview?.alpha = 0.5;
            }
            
            
            
            if(favoritesArray!.contains("Green")){
                greenstar_switch.on = true;
                greenstar.tintColor = UIColor.greenColor()
                greenstar_switch.superview?.alpha = 1.0;
            } else {
                greenstar_switch.on = false;
                greenstar.tintColor = UIColor.blackColor()
                greenstar_switch.superview?.alpha = 0.5;
                
            }
            
            if(favoritesArray!.contains("Red")){
                redstar_switch.on = true;
                redstar.tintColor = UIColor.redColor()
                redstar_switch.superview?.alpha = 1.0;
            }else {
                redstar_switch.on = false;
                redstar.tintColor = UIColor.blackColor()
                redstar_switch.superview?.alpha = 0.5;
            }
            
            
            if(favoritesArray!.contains("Yellow")){
                yellowstar_switch.on = true;
                yellowstar.tintColor = UIColor.yellowColor()
                yellowstar_switch.superview?.alpha = 1.0;
            }else {
                yellowstar_switch.on = false;
                yellowstar.tintColor = UIColor.blackColor()
                yellowstar_switch.superview?.alpha = 0.5;
            }
            
            
            
        }
        
        
    }
    
    /**
     Activates/deactivates one of the available favorite stars (i.e. system lists). Update the switch colors/alpha and
     add/remove the system list from available words array
     
     - parameter starcolor: color of system list ("Blue", "Red" etc). Also the "name" of the system list. One and the same
     - parameter ON: bool true for activated, false for deactivated
     */
    func starswitchpressed(starcolor : String, ON : Bool) {
        
        var favoritesArray = NSUserDefaults.standardUserDefaults().stringArrayForKey("favoritesstarsarray") as [String]!;
        
        switch starcolor {
        case "Blue":
            if(ON == true){
                blustar.tintColor = UIColor.blueColor()
                bluestar_switch.superview?.alpha = 1.0;
                if(!favoritesArray.contains("Blue")) {
                    favoritesArray.append("Blue");
                }
                
            } else {
                blustar.tintColor = UIColor.blackColor()
                bluestar_switch.superview?.alpha = 0.5;
                if(favoritesArray.contains("Blue")) {
                    favoritesArray.removeAtIndex(favoritesArray.indexOf("Blue")!);
                }
                
            }
        case "Green":
            if(ON == true){
                greenstar.tintColor = UIColor.greenColor()
                greenstar_switch.superview?.alpha = 1.0;
                if(!favoritesArray.contains("Green")) {
                    favoritesArray.append("Green");
                }
            } else {
                greenstar.tintColor = UIColor.blackColor()
                greenstar_switch.superview?.alpha = 0.5;
                if(favoritesArray.contains("Green")) {
                    favoritesArray.removeAtIndex(favoritesArray.indexOf("Green")!);
                }
            }
        case "Red":
            if(ON == true){
                redstar.tintColor = UIColor.redColor()
                redstar_switch.superview?.alpha = 1.0;
                
                if(!favoritesArray.contains("Red")) {
                    favoritesArray.append("Red");
                }
            } else {
                redstar.tintColor = UIColor.blackColor()
                redstar_switch.superview?.alpha = 0.5;
                if(favoritesArray.contains("Red")) {
                    favoritesArray.removeAtIndex(favoritesArray.indexOf("Red")!);
                }
            }
        case "Yellow":
            if(ON == true){
                yellowstar.tintColor = UIColor.yellowColor()
                yellowstar_switch.superview?.alpha = 1.0;
                if(!favoritesArray.contains("Yellow")) {
                    favoritesArray.append("Yellow");
                }
                
            } else {
                yellowstar.tintColor = UIColor.blackColor()
                yellowstar_switch.superview?.alpha = 0.5;
                
                if(favoritesArray.contains("Yellow")) {
                    favoritesArray.removeAtIndex(favoritesArray.indexOf("Yellow")!);
                }
            }
        default:
            break;
        }
        
        
        NSUserDefaults.standardUserDefaults().setObject(favoritesArray, forKey: "favoritesstarsarray")
        
        print("UPDATING THE NAV BAR CLICKED- TRUE")
        tellNavContoUpdateMainViews(true);
    }
    
    @IBAction func bluestar_switchpressed(sender: AnyObject) {
        starswitchpressed("Blue", ON: sender.on)
    }
    @IBAction func greenstar_switchpressed(sender: AnyObject) {
        starswitchpressed("Green", ON: sender.on)
    }
    @IBAction func redstar_switchpressed(sender: AnyObject) {
        starswitchpressed("Red", ON: sender.on)
    }
    @IBAction func yellowstar_switchpressed(sender: AnyObject) {
        starswitchpressed("Yellow", ON: sender.on)
    }
    
    
    @IBOutlet weak var bluestar_switch: UISwitch!
    @IBOutlet weak var greenstar_switch: UISwitch!
    @IBOutlet weak var redstar_switch: UISwitch!
    @IBOutlet weak var yellowstar_switch: UISwitch!
    @IBOutlet weak var blustar: UIButton!
    @IBOutlet weak var greenstar: UIButton!
    @IBOutlet weak var redstar: UIButton!
    @IBOutlet weak var yellowstar: UIButton!
    
    @IBAction func showmylistheadercount_switchpressed(sender: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(sender.on, forKey: "showmylistheadercount")
        
        tellNavContoUpdateMainViews(true);
    }
    @IBOutlet weak var showmylistheadercount_switch: UISwitch!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     Passes message to the Parent VC (which is then relayed to ViewControllerMain when back is pressed), to update
     related VCs like MyList MainMenu because a change has been made in the preferences that affects them
     */
    func tellNavContoUpdateMainViews(changeit: Bool){
        
        if let navcon = self.navigationController as? Preferences_NavController {
            navcon.updatethemanview = changeit;
        }
    }
    
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
        
        
        if let navCon = self.navigationController as? Preferences_NavController {
            
            let triggerTime = (Int64(NSEC_PER_MSEC) * 200)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, triggerTime), dispatch_get_main_queue(), { () -> Void in
                
                if(toInterfaceOrientation.isLandscape) {
                    navCon.setUpNavigationBar(longside, screenheight: shortside);
                } else {
                    navCon.setUpNavigationBar(shortside, screenheight: longside);
                }
            })
            
            
        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0) {
            switch indexPath.row {
            case 0:
                starswitchpressed("Blue", ON : !bluestar_switch.on);
                bluestar_switch.on = !bluestar_switch.on;
            case 1:
                starswitchpressed("Green", ON : !greenstar_switch.on);
                greenstar_switch.on = !greenstar_switch.on;
            case 2:
                starswitchpressed("Red", ON : !redstar_switch.on);
                redstar_switch.on = !redstar_switch.on;
            case 3:
                starswitchpressed("Yellow", ON : !yellowstar_switch.on);
                yellowstar_switch.on = !yellowstar_switch.on;
            default:
                break;
            }
        }
        
    }
    
}

