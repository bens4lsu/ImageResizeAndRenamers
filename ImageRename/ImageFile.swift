//
//  ImageFile.swift
//  ImageRename
//
//  Created by Ben Schultz on 12/6/19.
//  Copyright © 2019 com.concordbusinessservicesllc. All rights reserved.
//

import Foundation
import CoreServices

class ImageFile: CustomStringConvertible {
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_HHmmss"
        return df
    }()
    
    let fileManager = FileManager.default
    let currentPath = FileManager.default.currentDirectoryPath
    
    var currentFile: String
    lazy var currentFileURL = URL(string: "file://" + currentPath + "/" + currentFile)
    
    var description: String {
        return currentFile
    }
    
    init (filePath: String) {
        currentFile = filePath
    }
    
    func creationDateFromMetadata() -> String? {
        guard let mditem = MDItemCreate(nil, currentFile as CFString),
            let mdnames = MDItemCopyAttributeNames(mditem),
            let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any],
            let creationDate = mdattrs["kMDItemContentCreationDate"] as? Date
        else {
            print("Can't get attributes for \(currentFile)")
            return nil
        }
        return dateFormatter.string(from: creationDate)
    }
    

    func seqNumbers() -> String {
        let myFileParts = currentFile.split { $0 == "_" || $0 == "." }
                                .compactMap { Int($0) }
                                .map { String($0) }
        return "_" + myFileParts.joined(separator: "_")
    }

    
    
    func rename(to desitnatonFileName: String){
        guard let originURL = currentFileURL,
            let destinationURL = URL(string: "file://" + currentPath + "/" + desitnatonFileName)
            else {
                return
        }
        do{
            try fileManager.moveItem(at: originURL, to: destinationURL)
        } catch {
            print(error)
        }
    }
}
