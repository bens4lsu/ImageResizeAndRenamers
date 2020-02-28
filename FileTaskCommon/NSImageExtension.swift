//
//  NSImageExtension.swift
//  ImageRename
//
//  Created by Ben Schultz on 12/12/19.
//  Copyright © 2019 com.concordbusinessservicesllc. All rights reserved.
//

import Foundation
import AppKit
extension NSImage {
 
    func resized(toWidth width:CGFloat) -> NSImage {
        // calculate how mch we need to bring the width down to meet our target size
        let scale = width / self.size.width
        let height = self.size.height * scale
        return resized(toSize: CGSize(width: width, height: height))
    }
    
    func resized(toHeight height:CGFloat) -> NSImage {
        let scale = height / self.size.height
        let width = self.size.width * scale
        return resized(toSize: CGSize(width: width, height: height))
    }
    
    func resized (toSize targetSize: CGSize) -> NSImage {
        var newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        self.draw(in: NSMakeRect(0, 0, targetSize.width, targetSize.height), from: NSMakeRect(0, 0, self.size.width, self.size.height), operation: NSCompositingOperation.sourceOver, fraction: CGFloat(1))
        newImage.unlockFocus()
        newImage.size = targetSize
        return NSImage(data: newImage.tiffRepresentation!)!
    }
    
    
    var jpgData: Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .jpeg, properties: [:])
    }
    
    func jpgWrite(to url: URL) -> Bool {
        let options = Data.WritingOptions.atomic
        do {
            try self.jpgData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
}
