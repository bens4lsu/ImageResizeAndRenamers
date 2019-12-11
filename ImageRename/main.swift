//
//  main.swift
//  ImageRename
//
//  Created by Ben Schultz on 12/6/19.
//  Copyright © 2019 com.concordbusinessservicesllc. All rights reserved.
//

import Foundation

let fileCollection = FileCollection()
for file in fileCollection.imageFiles {
    guard let creationDate = file.creationDateFromMetadata() else {
        print("Content Creation Metadata not found for file \(file).")
        break
    }
    let newFileName = "IMG_" + creationDate + file.seqNumbers() + ".jpg"
    file.rename(to: newFileName)
}
