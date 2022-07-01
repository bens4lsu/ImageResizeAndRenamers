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
var resizedImages = [String]()

if fileCollection.imageFiles.count > 0 {
    for file in fileCollection.imageFiles {
        let (thisFileSuccess, resFileName) = file.saveResizedCopies()
        success = success && thisFileSuccess
        if let fileName = resFileName {
            resizedImages.append(fileName)
        }
    }
    print (success ? "All files renamed succesfully" : "At least one file write had a problem")
    
    let folder = fileCollection.imageFiles[0].folderAbsolutePlain + "/"
    let textFileWriter = TextFileWriter()
    textFileWriter.writeGalDesc(in: folder)
    textFileWriter.writePicDesc(in: folder, from: resizedImages)
}


