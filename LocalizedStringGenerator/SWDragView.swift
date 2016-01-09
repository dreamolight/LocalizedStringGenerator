//
//  SWDragView.swift
//  LocalizedStringGenerator
//
//  Created by Stan Wu on 16/1/9.
//  Copyright © 2016年 Stan Wu. All rights reserved.
//

import Cocoa

class SWDragView: NSView {
    let tf = NSTextField()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.registerForDraggedTypes([
            NSFilenamesPboardType
            ])
        
        tf.editable = false
        tf.stringValue = "Drag files or directory"
        tf.alignment = NSTextAlignment.Center

        self.addSubview(tf)
        
        tf.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[tf(==300)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tf":tf]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[tf(==300)]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: ["tf":tf]))
    }

    override func drawRect(dirtyRect: NSRect) {
        super.drawRect(dirtyRect)

        // Drawing code here.
    }
    
    override func prepareForDragOperation(sender: NSDraggingInfo) -> Bool {
        NSLog("Drag released")
        
        return true
    }
    
    override func draggingEntered(sender: NSDraggingInfo) -> NSDragOperation {
        let p = sender.draggingPasteboard()
        
        var option = NSDragOperation.None
        
        if let types = p.types{
            if types.contains(NSFilenamesPboardType){
                option = NSDragOperation.Copy
                
                if let paths = p.propertyListForType(NSFilenamesPboardType) as? [String]{
                    for path in paths{
                        NSLog("path is:\(path)")
                    }
                }
            }
        }
        
        return option
    }
    
    override func performDragOperation(sender: NSDraggingInfo) -> Bool {
        NSLog("Drag Handled")
        tf.stringValue = "Handling"
        
        let p = sender.draggingPasteboard()
                
        if let types = p.types{
            if types.contains(NSFilenamesPboardType){                
                if let paths = p.propertyListForType(NSFilenamesPboardType) as? [String]{
                    for path in paths{
                        
                        NSThread.detachNewThreadSelector("doJobInBackgroundThread:", toTarget: self, withObject: path)
                        
                    }
                }else{
                    tf.stringValue = "Drag files or directory"
                }
            }else{
                tf.stringValue = "Drag files or directory"
            }
        }else{
            tf.stringValue = "Drag files or directory"
        }
        
        return true
    }

    func doJobInBackgroundThread(path: String){
        autoreleasepool { () -> () in
            SWGenerator.generateLocalizedStringsFile(path)

            dispatch_sync(dispatch_get_main_queue(), { () -> Void in
                self.tf.stringValue = "Drag files or directory"
            })
        }
    }
    

    
}
