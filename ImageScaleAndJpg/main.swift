//
//  main.swift
//  ImageScaleAndJpg
//
//  Created by Ben Schultz on 12/12/19.
//  Copyright © 2019 com.concordbusinessservicesllc. All rights reserved.
//

import Foundation




let fileCollection = FileCollection()
var success = true;
for file in fileCollection.imageFiles {
    success = success && file.saveResizedCopies()
}
print (success ? "All files renamed succesfully" : "")

