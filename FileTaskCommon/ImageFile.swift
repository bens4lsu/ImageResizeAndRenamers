//
//  ImageFile.swift
//  ImageRename
//
//  Created by Ben Schultz on 12/6/19.
//  Copyright © 2019 com.concordbusinessservicesllc. All rights reserved.
//

import Foundation
import CoreServices
import AppKit

enum ImageDimension {
    case width
    case height
}

struct ImageResizeInstruction {
    let basedOnDimension: ImageDimension
    let fullDimension: CGFloat
    let thumbnailDimension: CGFloat
}

enum ImageOrientation {
    case portrait
    case landscape
    case panorama
    case square
    case other
    
    var resizeFormula: ImageResizeInstruction {
        switch self {
        case .portrait:
            return ImageResizeInstruction(basedOnDimension: .height, fullDimension: 1000, thumbnailDimension: 100)
        case .landscape, .panorama:
            return ImageResizeInstruction(basedOnDimension: .width, fullDimension: 1500, thumbnailDimension: 150)
        case .square:
            return ImageResizeInstruction(basedOnDimension: .width, fullDimension: 1000, thumbnailDimension: 100)
        case .other:
            return ImageResizeInstruction(basedOnDimension: .width, fullDimension: 500, thumbnailDimension: 100)
        }
    }
}

class ImageFile: CustomStringConvertible {
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_HHmmss"
        return df
    }()
    
    let fileManager = FileManager.default
    let currentPath = FileManager.default.currentDirectoryPath
    
    var currentFile: String
    
    
    // MARK: computed properties
    
    var folderRelative: String {
        (currentFile as NSString).deletingLastPathComponent.replacingOccurrences(of: " ", with: #"%20"#) + "/"
    }
    
    var folderAbsolute: String {
        let fullPath = URL(fileURLWithPath: currentFile).absoluteURL.path
        return (fullPath as NSString).deletingLastPathComponent.replacingOccurrences(of: " ", with: #"%20"#)
    }
    
    var folderAbsolutePlain: String {
        let fullPath = URL(fileURLWithPath: currentFile).absoluteURL.path
        return (fullPath as NSString).deletingLastPathComponent
    }
    
    var currentFileNameOnly: String {
        currentFile.replacingOccurrences(of: " ", with: #"%20"#)
                   .replacingOccurrences(of: folderAbsolute + "/", with: "")
            .replacingOccurrences(of: folderRelative, with: "")
    }
    
    var currentFileURL: URL? {
        URL(string: ("file://" + currentFile).replacingOccurrences(of: " ", with: #"%20"#))
    }
    
    var image: NSImage? {
        NSImage(byReferencingFile: currentFile)
    }
    
    var imageOrientation: ImageOrientation? {
        guard let image = image else { return nil }
        if image.size.width > image.size.height * 2 {
            return .panorama
        }
        else if image.size.width > image.size.height {
            return .landscape
        }
        else if image.size.width == image.size.height {
            return .square
        }
        else {
            return .portrait
        }
    }
    
    var resImgURL: URL? {
        let resFileName = folderAbsolute + "/res" + currentFileNameOnly
        return URL(string: ("file://" + resFileName).replacingOccurrences(of: " ", with: #"%20"#))
    }
    
    var thbImgURL: URL? {
        let thbFileName = folderAbsolute + "/_thb_res" + currentFileNameOnly
        return URL(string: ("file://" + thbFileName).replacingOccurrences(of: " ", with: #"%20"#))
    }
    
    //  to conform with CustomStringConvertible protocol.  description gets used when there's an error -- to print
    //  the name of the erroring file.
    var description: String { currentFile }
    
    // MARK: methods
    init (filePath: String) {
        currentFile = filePath
    }
    
    
    private func creationDateFromMetadata() -> String? {
        guard let mditem = MDItemCreate(nil, currentFile as CFString),
            let mdnames = MDItemCopyAttributeNames(mditem),
            let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any],
            let creationDate = mdattrs["kMDItemContentCreationDate"] as? Date
        else {
            print("Can't get attributes for \(currentFile).  File might have been moved or rennamed.")
            return nil
        }
        return dateFormatter.string(from: creationDate)
    }
    

    private func seqNumbers(butNot omitString: String? = nil) -> String {
        let myFileParts = currentFileNameOnly.split { $0 == "_" || $0 == "." }
                                //.compactMap { Int($0) }
                                .map { String($0) }
        if let omitString = omitString {
            return myFileParts.joined(separator: "_")
                .replacingOccurrences(of: omitString, with: "")
                .replacingOccurrences(of: "_jpeg", with: "")
                .replacingOccurrences(of: "_jpg", with: "")
                                                    
        }
        else {
            return myFileParts.joined(separator: "_")
        }
    }

    
    func rename() -> Bool {
        guard let creationDate = creationDateFromMetadata() else {
            print("Content Creation Metadata not found for file \(self).")
            return false
        }
        var newFileName = ("IMG_" + creationDate + "_" + seqNumbers(butNot: creationDate) + ".jpg")
            .replacingOccurrences(of: " ", with: "_")
            .replacingOccurrences(of: "(", with: "_")
            .replacingOccurrences(of: ")", with: "_")
        return rename(to: newFileName)
    }
    
    func rename(to desitnatonFileName: String) -> Bool{
        guard let originURL = currentFileURL,
            let destinationURL = URL(string: "file://" + folderAbsolute + "/" + desitnatonFileName)
            else {
                print ("""
                    Error with a file URL.
                    originFilePath: \(currentFile)
                    destinationFilePath: \("file://" + folderAbsolute + "/" + desitnatonFileName)
                    """)
                return false
        }
        do{
            try fileManager.moveItem(at: originURL, to: destinationURL)
        } catch {
            print(error)
            return false
        }
        return true
    }
    

    func resized() -> (NSImage, NSImage)? {
        guard let image = self.image, let imageOrientation = imageOrientation else {
            print ("Could not convert file \(self) to native image.")
            return nil
        }
        
        var resImg: NSImage
        var thbImg: NSImage
        
        switch imageOrientation.resizeFormula.basedOnDimension {
        case .width:
            resImg = image.resized(toWidth: imageOrientation.resizeFormula.fullDimension)
            thbImg = image.resized(toWidth: imageOrientation.resizeFormula.thumbnailDimension)
        case .height:
            resImg = image.resized(toHeight: imageOrientation.resizeFormula.fullDimension)
            thbImg = image.resized(toHeight: imageOrientation.resizeFormula.thumbnailDimension)
        }
        return (resImg, thbImg)
    }
    
    func saveResizedCopies() -> (Bool, String?) {
        guard let (resImg, thbImg) = resized(),
              let resImgURL = resImgURL,
              let thbImgURL = thbImgURL
        else {
            print ("Error creating urls for resized files.")
            return (false, nil)
        }
        //print ("Folder is \(folderAbsolute) or \(folderRelative)")
        //print ("Writing thumbnail to \(thbImgURL.path)")
        var success = resImg.jpgWrite(to: resImgURL)
        success = success && thbImg.jpgWrite(to: thbImgURL)
        return (success, "res" + currentFileNameOnly)
    }
    
}
