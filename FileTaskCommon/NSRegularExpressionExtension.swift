//
//  NSRegularExpressionExtension.swift
//  ImageRename
//
//  Created by Ben Schultz on 12/6/19.
//  Copyright © 2019 com.concordbusinessservicesllc. All rights reserved.
//

import Foundation
extension NSRegularExpression {
    
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}
