//
//  SWGenerator.swift
//  LocalizedStringGenerator
//
//  Created by Stan Wu on 16/1/9.
//  Copyright © 2016年 Stan Wu. All rights reserved.
//

import Cocoa

class SWGenerator: NSObject {
    class func generateLocalizedStringsFile(path: String){
        if let ary = parseFile(path){
            let s = NSSet(array: ary)
            
            var isd: ObjCBool = false
            
            if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isd){
                var exportPath: String!
                if isd.boolValue{
                    exportPath = (path as NSString).stringByAppendingPathComponent("Localizable.strings")
                }else{
                    exportPath = ((path as NSString).stringByDeletingLastPathComponent as NSString).stringByAppendingPathComponent("Localizable.strings")
                }
                
                let mutstr = NSMutableString()
                
                for substr in s{
                    mutstr.appendString("\"\(substr)\" = \"\(substr)\"\n")
                }
                
                _ = try? mutstr.writeToFile(exportPath, atomically: false, encoding: NSUTF8StringEncoding)
            }
        }else{
            print("empty")
        }
    }
    
    class func parse(path: String) -> [String]?{
        if let content = try? String(contentsOfFile: path, encoding: NSUTF8StringEncoding){
            let prefixs = ["NSLocalizedString","SWLocalizedString"]
            var ranges = [NSRange]()
            
            for prefix in prefixs{
                let regex = "\(prefix)\\([^\\(\\)]+\\)"
                let regexEmoticons = try! NSRegularExpression(pattern: regex, options: NSRegularExpressionOptions(rawValue: 0))
                
                let chunks = regexEmoticons.matchesInString(content, options: NSMatchingOptions(rawValue: 0), range: NSMakeRange(0, content.characters.count))
                
                
                
                for i in 0..<chunks.count{
                    let chunk = chunks[i]
                    let total = chunk.numberOfRanges
                    
                    for j in 0..<total{
                        ranges.append(chunk.rangeAtIndex(j))
                    }
                }
            }
            
            var components = [String]()
            
            for range in ranges{
                let str = (content as NSString).substringWithRange(range)
                let ary = str.componentsSeparatedByString("\"")
                
                if ary.count > 1{
                    components.append(ary[1])
                }
            }
            
            
            return components.count > 0 ? components : nil
        }else{
            return nil
        }
    }
    
    class func parseFile(path: String) -> [String]?{
        var isd: ObjCBool = false
        
        var strings = [String]()
        
        if NSFileManager.defaultManager().fileExistsAtPath(path, isDirectory: &isd){
            if isd.boolValue{
                do{
                    let items = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(path)
                    for f in items{
                        let p = (path as NSString).stringByAppendingPathComponent(f)
                        if let items = parseFile(p){
                            strings.appendContentsOf(items)
                        }
                    }
                }catch{
                    
                }
            }else{
                if let items = parse(path){
                    strings.appendContentsOf(items)
                }
            }
        }
        
        return strings.count > 0 ? strings : nil
    }
}
