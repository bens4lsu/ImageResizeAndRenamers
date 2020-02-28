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
 
    func resize(toWidth width:CGFloat) {
        // calculate how mch we need to bring the width down to meet our target size
        let scale = width / self.size.width
        let height = self.size.height * scale
        resize(toSize: CGSize(width: width, height: height))
    }
    

    func resize(toHeight height:CGFloat) {
        let scale = height / self.size.height
        let width = self.size.width * scale
        resize(toSize: CGSize(width: width, height: height))
    }

    func resize(toSize targetSize: CGSize) {
        let image = self
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        self.size = newSize
    }
    
    var jpgData: Data? {
        guard let tiffRepresentation = tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffRepresentation) else { return nil }
        return bitmapImage.representation(using: .jpeg, properties: [:])
    }
    
    func jpgWrite(to url: URL) -> Bool {
        let options = Data.WritingOptions.atomic
        do {
            try jpgData?.write(to: url, options: options)
            return true
        } catch {
            print(error)
            return false
        }
    }
}
