//
//  TextFileWriter.swift
//  ImageScaleAndJpg
//
//  Created by Ben Schultz on 2/28/20.
//  Copyright © 2020 com.concordbusinessservicesllc. All rights reserved.
//

import Foundation

class TextFileWriter {
    
    func writePicDesc(in folder: String, from files: [String]){
        let picUrl = URL(fileURLWithPath: folder + "pic-desc.txt")
        do {
            try picDescText(from: files).write(to: picUrl, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            print ("Error writing pic-desc to disk:  \(error)")
        }
    }
    
    func writeGalDesc(in folder: String) {
        let picUrl = URL(fileURLWithPath: folder + "gal-desc.txt")
        do {
            try galDescText().write(to: picUrl, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {
            print ("Error writing gal-desc to disk:  \(error)\nfolder: \(folder)")
        }
    }
    
    private func picDescText(from files: [String]) -> String {
        var returnStr = ""
        for file in files {
            returnStr += "\(file)|\n"
        }
        return returnStr
    }

    private func galDescText() -> String {
        """
        <h2></h2>
        <div class="datestamp"></div>
        <p></p>
        """
    }

}
