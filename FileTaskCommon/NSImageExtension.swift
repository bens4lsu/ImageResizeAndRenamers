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
 
    func resized(toWidth width:CGFloat) -> CGImage? {
        // calculate how mch we need to bring the width down to meet our target size
        let scale = width / self.size.width
        let height = self.size.height * scale
        return resized(toSize: CGSize(width: width, height: height))
    }
    
    func resized(toHeight height:CGFloat) -> CGImage? {
        let scale = height / self.size.height
        let width = self.size.width * scale
        return resized(toSize: CGSize(width: width, height: height))
    }
    
    func resized (toSize targetSize: CGSize) -> CGImage? {
        var frame = NSRect(x: 0, y: 0, width: targetSize.width, height: targetSize.height)
        let cgImage = self.cgImage(forProposedRect: &frame, context: nil, hints: nil)
        return cgImage
    }
}
