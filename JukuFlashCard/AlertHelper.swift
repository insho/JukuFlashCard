//
//  AlertHelper.swift
//  JukuFlashCard
//
//  Created by System Administrator on 5/28/17.
//  Copyright © 2017 jukuproject. All rights reserved.
//

import UIKit

//Loads the Loading Overlay while a search is ongoing
class AlertHelper {
    func showAlert(fromController controller: UIViewController, messagetoshow: String, indicator: Bool, goldenRatio: CGFloat) {
        let alert = UIAlertController(title: nil, message: messagetoshow, preferredStyle: .Alert)
        
        
        alert.view.tintColor = UIColor.blackColor()
        if(indicator) {
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRectMake(10 * goldenRatio, 5 * goldenRatio, 50 * goldenRatio, 50 * goldenRatio)) as UIActivityIndicatorView
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            
            
        }
        
        controller.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
}