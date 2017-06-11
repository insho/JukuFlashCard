//
//  Extensions.swift
//
//  Created by JukuProject on 1/1/17.
//  Copyright © 2016 jukuproject. All rights reserved.
//

import UIKit


func print(items: Any..., separator: String = " ", terminator: String = "\n") {
    
    #if DEBUG
        
        var idx = items.startIndex
        let endIdx = items.endIndex
        
        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        }
            while idx < endIdx
        
    #endif
}

extension String {
    init(sep:String, _ lines:String...){
        self = ""
        for (idx, item) in lines.enumerate() {
            self += "\(item)"
            if idx < lines.count-1 {
                //                self += sep
            }
        }
    }
    
    init(_ lines:String...){
        self = ""
        for (idx, item) in lines.enumerate() {
            self += "\(item)"
            if idx < lines.count-1 {
                self += "\n"
            }
        }
    }
}



extension UIColor {
    
    convenience init(hex:Int, alpha:CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }
    
}


extension UIView {
    
    func rotate(toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.removedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.addAnimation(animation, forKey: nil)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat, goldenratio: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, self.frame.size.height * goldenratio - width, self.frame.size.width, width)
        self.layer.addSublayer(border)
        
        
        
    }
    func addBottomBorderWithColor_stupid(color: UIColor, width: CGFloat, goldenratio: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0, self.frame.size.height * goldenratio + 10 * goldenratio - width, self.frame.size.width, width)
        self.layer.addSublayer(border)
        
        
        
    }
    
}

extension UILabel{
    
    func requiredHeight() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, self.frame.width, CGFloat.max))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        return label.frame.height
    }
    
    
    func requiredWidth() -> CGFloat{
        
        let label:UILabel = UILabel(frame: CGRectMake(0, 0, CGFloat.max, self.frame.height))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.ByWordWrapping
        label.font = self.font
        label.text = self.text
        
        label.sizeToFit()
        
        return label.frame.width
    }
    
}


extension Double {
    private static let arc4randomMax = Double(UInt32.max)
    
    static func random0to1() -> Double {
        return Double(arc4random()) / arc4randomMax
    }
}

extension String {
    
    var asDate: NSDate? {
        return NSDate.Formatter.custom.dateFromString(self)
    }
    func asDateFormatted(with dateFormat: String) -> NSDate? {
        return NSDateFormatter(dateFormat: dateFormat).dateFromString(self)
    }
    
    
    
    func indexOf(string: String) -> String.Index? {
        return rangeOfString(string, options: .LiteralSearch, range: nil, locale: nil)?.startIndex
    }
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (r: Range<Int>) -> String {
        let start = startIndex.advancedBy(r.startIndex)
        let end = start.advancedBy(r.endIndex - r.startIndex)
        return self[Range(start ..< end)]
    }
    
    func contains(find: String) -> Bool{
        return self.rangeOfString(find) != nil
    }
    
    func containsIgnoringCase(find: String) -> Bool{
        return self.rangeOfString(find, options: NSStringCompareOptions.CaseInsensitiveSearch) != nil
    }
    
}

extension MutableCollectionType where Index == Int {
    
    mutating func shuffleInPlace() {
        
        if count < 2 { return }
        for i in startIndex ..< endIndex - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i
            guard i != j else { continue }
            swap(&self[i], &self[j])
        }
    }
}

extension CollectionType {
    func shuffle() -> [Generator.Element] {
        var list = Array(self)
        list.shuffleInPlace()
        return list
    }
}

extension NSDateFormatter {
    convenience init(dateFormat: String) {
        self.init()
        self.dateFormat =  dateFormat
    }
}

extension NSDate {
    struct Formatter {
        static let custom = NSDateFormatter(dateFormat: "MM/dd")
    }
    var customFormatted: String {
        return Formatter.custom.stringFromDate(self)
    }
}


extension NSMutableAttributedString {
    
    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        
        let foundRange = self.mutableString.rangeOfString(textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(NSLinkAttributeName, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
    
}

class UnderlinedLabel: UILabel {
    
    override var text: String? {
        didSet {
            guard let text = text else { return }
            let textRange = NSMakeRange(0, text.characters.count)
            let attributedText = NSMutableAttributedString(string: text)
            attributedText.addAttribute(NSUnderlineStyleAttributeName, value:NSUnderlineStyle.StyleSingle.rawValue, range: textRange)
            
            self.attributedText = attributedText
        }
    }
}


class CustomLongPressRecognizer: UILongPressGestureRecognizer {
    internal var index: NSInteger!
    init(target: AnyObject?, action: Selector, index: NSInteger) {
        super.init(target: target, action: action)
        self.index = index
        
    }
}

class CustomTabBar: UITabBar {
    
    
    override func intrinsicContentSize() -> CGSize {
        var intrinsicSize = super.frame.size
        
        let screenBounds = UIScreen.mainScreen().bounds
        let goldenRatio = setGoldenRatio(screenBounds);
        
        
        intrinsicSize.height = 44 * goldenRatio
        
        return intrinsicSize
    }
    
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var  sizeThatFits = size;
        
        let screenBounds = UIScreen.mainScreen().bounds
        let goldenRatio = setGoldenRatio(screenBounds)
        
        sizeThatFits.height = 44 * goldenRatio;
        
        return sizeThatFits;
    }
    
    
    
}


class CustomSearchBar: UISearchBar {
    
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds);
    override func intrinsicContentSize() -> CGSize {
        var intrinsicSize = super.frame.size
        intrinsicSize.height = 44 * goldenRatio;
        return intrinsicSize
    }
    
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var  sizeThatFits = size;
        
        let screenBounds = UIScreen.mainScreen().bounds
        let goldenRatio = setGoldenRatio(screenBounds)
        
        if(screenBounds.size.width > screenBounds.size.height) {
            sizeThatFits.height = 44 * goldenRatio;
            
        } else {
            sizeThatFits.height = 44 * goldenRatio;
        }
        
        return sizeThatFits;
    }
    
}


class CustomButton: UIButton {
    
    var shadowLayer: CAShapeLayer!
    let goldenRatio = setGoldenRatio(UIScreen.mainScreen().bounds)
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius:  0.5 * bounds.size.width).CGPath
            shadowLayer.fillColor = UIColor(hex: 0x2196F3).CGColor // UIColor.whiteColor().CGColor
            shadowLayer.shadowColor = UIColor.darkGrayColor().CGColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 2.0 * goldenRatio, height: 2.0 * goldenRatio)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2 * goldenRatio
            
            layer.insertSublayer(shadowLayer, atIndex: 0)
            
        }        
    }
    
}
