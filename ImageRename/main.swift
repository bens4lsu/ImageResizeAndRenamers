//
//  main.swift
//  ImageRename
//
//  Created by Ben Schultz on 12/6/19.
//  Copyright © 2019 com.concordbusinessservicesllc. All rights reserved.
//

import Foundation

let fileCollection = FileCollection()
var success = true;
for file in fileCollection.imageFiles {
    success = success && file.rename()
}
print (success ? "All files renamed succesfully" : "")
