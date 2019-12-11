//
//  FileCollection.swift
//  ImageRename
//
//  Created by Ben Schultz on 12/6/19.
//  Copyright © 2019 com.concordbusinessservicesllc. All rights reserved.
//

import Foundation

enum CommandLineOption {
    case allImages              // no parameters on command line
    case fileNameParameters     // file list, or list that might include wildcard
    case fileNameRegex(regex: NSRegularExpression)          // first parameter starts -r or --regex
    case help                   // first parameter -h or --help
    case invalid                // error when trying to parse one of the other options
    case unknown                // first parameter starts with hyphen but isn't defined
    
    static let usage:String = """
        
        ImageRename [option] [FILE1 FILE2 .... FILEX]

        1.  Run with no parameters to pick up all images in current directory and renames them.
        2.  Run with any number of file names as command line arguements:  each one gets renamed.
        3.  -r{pattern} or --regex{pattern}  Pick up files whose names match the regex pattern.  Requires file list.
        4.  -h or --help   Shows this help.
        """
    
    init(firstArguement: String, argCount: Int){
        
        func parseRegexPattern(from param: String) -> CommandLineOption {
            do {
                let paramRegex = try NSRegularExpression(pattern: String(param))
                return .fileNameRegex(regex: paramRegex)
            }
            catch {
                print (CommandLineOption.usage)
                return .invalid
            }
        }
        
        if argCount == 0 {
            self = .allImages
        }
        else if argCount == 1 && firstArguement.prefix(2) == "-r" {
            let param = firstArguement.suffix(firstArguement.count - 2)
            self = parseRegexPattern(from: String(param))
        }
        else if argCount == 1 && firstArguement.prefix(7) == "--regex" {
            let param = firstArguement.suffix(firstArguement.count - 7)
            self = parseRegexPattern(from: String(param))
        }
        else if argCount == 1 && firstArguement.prefix(2) == "-h" {
            self = .help
         }
         else if argCount == 1 && firstArguement.prefix(6) == "--help" {
            self = .help
         }
        else if firstArguement.prefix(1) == "-" {
            self = .unknown
        }
        else {
            self = .fileNameParameters
        }
    }

}


class FileCollection{
    
    let fileManager = FileManager.default
    let currentPath = FileManager.default.currentDirectoryPath
    
    var files: [String]?
    
    var imageFiles: [ImageFile] {
        if let files = files {
            return files.map { ImageFile(filePath: $0) }
        }
        return []
    }
    
    init(){
        
        func getFileListing(matchingRegex regex: NSRegularExpression) -> [String]?{
            do {
                let files = try fileManager.contentsOfDirectory(atPath: currentPath)
                return files.compactMap { regex.matches($0) ? $0 : nil}
            }
            catch {
                print ("Error getting file listing.")
                return nil
            }
        }
        
        
        let argCount = Int(CommandLine.argc) - 1
        let arguement = argCount > 0 ? CommandLine.arguments[1] : ""
        let commandLineOption = CommandLineOption(firstArguement: arguement, argCount: argCount)
        switch commandLineOption {
        case .allImages:
            let allJpgsRegex = try! NSRegularExpression(pattern: #"(?i).*\.(jpeg|jpg)$"#)
            files = getFileListing(matchingRegex: allJpgsRegex)
        case .fileNameParameters:
            var allFiles = [String]()
            for i in 1...argCount {
                let arg = CommandLine.arguments[i]
                if arg.contains("*") || arg.contains("?") {
                    let regexPatternTxt = arg.replacingOccurrences(of: "*", with: ".*")
                                          .replacingOccurrences(of: "?", with: ".")
                    let regexPattern = try! NSRegularExpression(pattern: regexPatternTxt)
                    if let someMoreFiles = getFileListing(matchingRegex: regexPattern) {
                        allFiles += someMoreFiles
                    }
                }
                else {
                    allFiles.append(arg)
                }
            }
            files = allFiles
        case let .fileNameRegex(regex):
            files = getFileListing(matchingRegex: regex)
        case .help:
            print (CommandLineOption.usage)
            files = nil
        case .invalid:
            files = nil
        case .unknown:
            print ("Unknown parameter, or invalid input.")
            print (CommandLineOption.usage)
            files = nil
        }
    }
}
