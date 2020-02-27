//
//  FileManagerHelper.swift
//  DownloadManager
//
//  Created by SOTSYS026 on 28/12/18.
//  Copyright © 2018 SOTSYS026. All rights reserved.
//

import UIKit
import MobileCoreServices

var documentDirectoryRootPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
public var currentDocDirectoryPath = documentDirectoryRootPath
var rootPathForDocDirectory = documentDirectoryRootPath
var downloadsFolderName     = "Downloads"
var downloadsDirPath = documentDirectoryRootPath?.appendPathComponent(downloadsFolderName)

class FileManagerHelper: NSObject {

    static var shared: FileManagerHelper = FileManagerHelper()
    let fileManager = FileManager.default
   
    func uniqeName(currentFilePath:URL,fileExtenstion:String ) -> URL
    {
        do
        {
            if fileManager.fileExists(atPath: currentFilePath.path)
            {
                let directoryContents = try FileManager.default.contentsOfDirectory(at: currentFilePath.deletingLastPathComponent(), includingPropertiesForKeys: nil, options: [])
                for  index in 0..<directoryContents.count
                {
                    let newFileNamePath = currentFilePath.path + "_" + String(index + 1)
                    if !fileManager.fileExists(atPath: newFileNamePath)
                    {
                        return URL(fileURLWithPath: newFileNamePath)
                    }
                }
            }
        }
        catch
        {
            //print(error.localizedDescription)
        }
        return currentFilePath
    }
    
    func createFolderInDocumentDirectory(_ folderName: String) ->  URL {
        // path to documents directory
//        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        if let documentDirectoryPath = documentDirectoryRootPath {
            // create the custom folder path
            let directoryPath = documentDirectoryPath.appendingPathComponent(folderName)
                //documentDirectoryPath.appending("/\(folderName)")
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: directoryPath.path) {
                do {
                    try fileManager.createDirectory(atPath: directoryPath.path,
                                                    withIntermediateDirectories: false,
                                                    attributes: nil)
                } catch {
                    print("Error creating folder in documents dir: \(error)")
                }
            }
            return directoryPath
        }
        return documentDirectoryRootPath!
    }
    
    func createFolder(folderName:String){
        var dataPath = currentDocDirectoryPath!.appendingPathComponent(folderName)
        let newFolderName = uniqeName(currentFilePath: dataPath, fileExtenstion: "")
        dataPath = newFolderName
        
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
           // self.getAttributesOfFile(filePath: dataPath, type: FileType.folder.rawValue)
        }
        catch
        {
            print("Error creating directory: \(error.localizedDescription)")
        }
    }
    
    func getItemsCountAtCurrentPath(subFolderName: String = "") -> [URL]{
        var theItems = [URL]()
        do {
            let pathForCount = subFolderName.count > 0 ? currentDocDirectoryPath?.appendingPathComponent(subFolderName) : currentDocDirectoryPath
            theItems = try fileManager.contentsOfDirectory(at: pathForCount!, includingPropertiesForKeys: nil, options: [])
            theItems = theItems.filter{$0.lastPathComponent != ".DS_Store"}
            return theItems
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return theItems
    }
    
    func sizeOfFolder(_ folderPath: String) -> String? {
        do {
            let contents = try FileManager.default.contentsOfDirectory(atPath: folderPath)
            var folderSize: Int64 = 0
            for content in contents {
                do {
                    let fullContentPath = folderPath + "/" + content
                    let fileAttributes = try FileManager.default.attributesOfItem(atPath: fullContentPath)
                    folderSize += fileAttributes[FileAttributeKey.size] as? Int64 ?? 0
                } catch _ {
                    continue
                }
            }
            
            /// This line will give you formatted size from bytes ....
            let fileSizeStr = ByteCountFormatter.string(fromByteCount: folderSize, countStyle: ByteCountFormatter.CountStyle.file)
            return fileSizeStr
            
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    }

    func getItemsCountAtRootPath() -> [URL]{
                var theItems = [URL]()
                do {
                    theItems = try fileManager.contentsOfDirectory(at: currentDocDirectoryPath!, includingPropertiesForKeys: nil, options: [])
                    theItems = theItems.filter{$0.lastPathComponent != ".DS_Store"}
                    return theItems
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                return theItems
            }
    

    func deleteFile(url:URL){
        var strFile = URL.init(string: "")
        if url.path.contains("Documents")
        {
            strFile = url
        }
        else
        {
            strFile = URL(fileURLWithPath:documentDirectoryRootPath!.path + "/" + url.relativePath)
        }
        do{
             try fileManager.removeItem(atPath:(strFile!.path))
        }catch{
            Helper.shared.openAlertWith(title: error.localizedDescription, message: "", type: .onlyok, viewController: nil, handler: nil)
        }
    }
    
    func isFileExistAtPath(filePath:String)-> Bool{
        if fileManager.fileExists(atPath: filePath){
            return true
        }else{
            return false
        }
    }
    
    func getfileCreatedDate(path: String) -> Date {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            return attrs.fileCreationDate()!
        } catch {
            return Date()
        }
    }
    
    func getfileSize(path: String) -> UInt64 {
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: path) as NSDictionary
            return attrs.fileSize()
        } catch {
            return UInt64(0)
        }
    }
    
    func convertBytesToKbMb(byteCount: UInt64) -> String{
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = .useAll
        bcf.countStyle = .file
        let strFormate = bcf.string(fromByteCount: Int64(byteCount))
        return strFormate
    }
    
    func setFileExtention(extention: String) -> FileType{
        switch extention.lowercased() {
        case FileType.png.rawValue:
            return FileType.png
        case FileType.jpg.rawValue:
            return FileType.jpg
        case FileType.jpeg.rawValue:
            return FileType.jpeg
        case FileType.pdf.rawValue:
            return FileType.pdf
        case FileType.doc.rawValue:
            return FileType.doc
        case FileType.txt.rawValue:
            return FileType.txt
        case FileType.mp3.rawValue:
            return FileType.mp3
        case FileType.m4a.rawValue:
            return FileType.m4a
        case FileType.other.rawValue:
            return FileType.other
        case FileType.zip.rawValue:
            return FileType.zip
        case FileType.mp4.rawValue:
            return FileType.mp4
        case FileType.vcf.rawValue:
            return FileType.vcf
        case FileType.mov.rawValue:
            return FileType.mov
        default:
            return FileType.other
        }
    }
    
    func checkSelectedFileIsImage(extention: String) -> Bool{
        switch extention.lowercased() {
        case FileType.png.rawValue:
            return true
        case FileType.jpg.rawValue:
            return true
        case FileType.jpeg.rawValue:
            return true
        default:
            return false
        }
    }
    
    
    func moveFile(oldFileURL:URL,newFileURL:URL, completionHandler: @escaping (_ success:Bool,_ error:String?)-> ()){
        var strOldFile = URL.init(string: "")
         var strNewFile = URL.init(string: "")
        if oldFileURL.path.contains("Documents")
        {
            strOldFile = oldFileURL
        }
        else
        {
            strOldFile = URL(fileURLWithPath:documentDirectoryRootPath!.path + "/" + oldFileURL.relativePath)
        }
        
        if newFileURL.path.contains("Documents")
        {
            strNewFile = newFileURL
        }
        else
        {
            strNewFile = URL(fileURLWithPath:documentDirectoryRootPath!.path + "/" + newFileURL.relativePath)
        }
        strNewFile = (strNewFile?.appendingPathComponent((oldFileURL.lastPathComponent)))!
        
        if oldFileURL == strNewFile{
            completionHandler (false,msgMoveAtSameLocation)
        }
        do{
            try fileManager.moveItem(at: oldFileURL, to: strNewFile!)
        completionHandler (true,nil)
        }catch let error{
            print("\(error.localizedDescription)")
            completionHandler (false,error.localizedDescription)
        }
    }
    
    func renameFile(oldFileName:String,newFileName:String)-> Bool{
        let oldFileURL = currentDocDirectoryPath?.appendingPathComponent(oldFileName)
        let  newFileURL = currentDocDirectoryPath?.appendingPathComponent(newFileName)
        
        if oldFileName == newFileName{
            Helper.shared.openAlertWith(title: msgSameNameFileExist, message:"" , type: .onlyok, viewController: nil, handler: nil)
            return false
        }
        do{
            try fileManager.moveItem(at: oldFileURL!, to: newFileURL!)
            return true
        }catch let error{
           Helper.shared.openAlertWith(title: error.localizedDescription, message: "", type: .onlyok, viewController: nil, handler: nil)
            print("\(error.localizedDescription)")
            return false
        }
    }
    
    func copyFile(oldFileName:URL,newFileName:URL,itemType:String, completionHandler: @escaping (_ success:Bool,_ error:String?)-> ()){
        var strOldFile = URL.init(string: "")
        var strNewFile = URL.init(string: "")
        if oldFileName.path.contains("Documents")
        {
            strOldFile = oldFileName
        }
        else
        {
            strOldFile = URL(fileURLWithPath:documentDirectoryRootPath!.path + "/" + oldFileName.relativePath)
        }
        
        if newFileName.path.contains("Documents")
        {
            strNewFile = newFileName
        }
        else
        {
            strNewFile = URL(fileURLWithPath:documentDirectoryRootPath!.path + "/" + newFileName.relativePath)
        }
        do{
            var newItemPath = (strNewFile?.appendingPathComponent((oldFileName.lastPathComponent)))!
            var fileName =  (oldFileName.lastPathComponent as NSString).deletingPathExtension
            let extention = oldFileName.pathExtension
            var counter = 0
            
            while FileManagerHelper.shared.isFileExistAtPath(filePath: (newItemPath.path)){
                counter += 1
                fileName = "\(fileName)_copy(\(counter))"
                if extention == ""{
                    newItemPath = (currentDocDirectoryPath?.appendingPathComponent("\(fileName)"))!
                }else{
                    newItemPath = (currentDocDirectoryPath?.appendingPathComponent("\(fileName).\(extention)"))!
                }
            }
            
            try fileManager.copyItem(at: oldFileName, to: newItemPath)
           completionHandler (true,nil)
        }catch let error{
            print("\(error.localizedDescription)")
            completionHandler (false, error.localizedDescription)
        }
    }
    
    
    func getAttributesOfFile(filePath:URL,type:String){
        do{
            //let fileManager = FileManager.default
            let attributes = try fileManager.attributesOfItem(atPath:filePath.path) as NSDictionary
            let date  = attributes.fileCreationDate()
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMM yyyy HH:mm"
            let StrDate = formatter.string(from: date!)
            let dirContents = try? fileManager.contentsOfDirectory(atPath: filePath.path)
            let count = dirContents?.count ?? 0
            let byteSize = ByteCountFormatter.string(fromByteCount: Int64(attributes.fileSize()), countStyle: .file)
            let array = filePath.path.components(separatedBy: "Documents/")
            let dictInfo = ["name":filePath.deletingPathExtension().lastPathComponent,"type":type, "createDate":StrDate,"size": "\(count) files","url":array[1 ] , "bytesize":byteSize] as [String : Any]
        }catch{
             print("Ooops! Something went wrong: \(error)")
        }
    }
    
    func saveItemToDocumentDiretory(fileURL:URL) -> Bool{
        var fileName = URL(fileURLWithPath: fileURL.absoluteString).deletingPathExtension().lastPathComponent
        fileName = fileName.removingPercentEncoding!
      //  let fileURL = fileURL
        let ext = (fileURL.absoluteString as NSString).pathExtension
        
        var file_local_path = currentDocDirectoryPath?.relativePath.appendingFormat("/%@.%@", fileName,ext)
        var counter = 0
        
        while FileManagerHelper.shared.isFileExistAtPath(filePath: (file_local_path!)){
            counter += 1
            fileName = "\(fileName)_copy(\(counter))"
            file_local_path = currentDocDirectoryPath?.relativePath.appendingFormat("/%@.%@", fileName,ext)
        }

        let url =  fileURL
        
        do {
            let fileData = try Data.init(contentsOf: url)
            let url = URL (fileURLWithPath: file_local_path!)
            try fileData.write(to: url)
            return true
        }catch{
            Helper.shared.openAlertWith(title: error.localizedDescription, message: "", type: .onlyok, viewController: nil, handler: nil)
            return false
        }
    }
    
    func saveVideoToDocuemtDirectory(videoURL:URL,videoName:String,path:String?) -> Bool{
       // let fileName = videoURL.path.removingPercentEncoding
        var dataPath = ""
        if path == nil{
            dataPath = (currentDocDirectoryPath?.relativePath.appendingFormat("/\(videoName).mp4"))!
        }else{
            dataPath = path!
        }
        
        
        if fileManager.fileExists(atPath: dataPath){
            dataPath = (currentDocDirectoryPath?.relativePath.appendingFormat("/\(videoName)_1.mp4"))!
        }
        
        do {
            let fileData = try! Data.init(contentsOf: videoURL)
            let url = URL (fileURLWithPath: dataPath)
            try fileData.write(to: url)
            return true
        }catch{
            return false
        }
}
    
    func saveImageToDocuemtDirectory(fileName:String, img:UIImage,path:URL?) -> Bool{
        var dataPath:URL?
        
        if path != nil{
            dataPath = path!
        }else{
            dataPath = currentDocDirectoryPath?.appendingPathComponent("\(fileName).jpg")
        }
        
      //  var fileName = fileName

        var imgName =  (path!.lastPathComponent as NSString).deletingPathExtension
        let extention = path!.pathExtension
        var counter = 0
        
        while FileManagerHelper.shared.isFileExistAtPath(filePath: (dataPath!.path)){
            counter += 1
            imgName = "\(fileName)_copy(\(counter))"
            if extention == ""{
                dataPath =  (currentDocDirectoryPath?.appendingPathComponent("\(imgName)"))!
            }else{
                dataPath = (currentDocDirectoryPath?.appendingPathComponent("\(imgName).\(String(describing: extention))"))!
            }
            
        }
        
        if let data = img.jpegData(compressionQuality: 1.0){
            do{
                try data.write(to: dataPath!)
                return true
            }catch{
                print("Somethin went wrong")
                return  false
            }
        }
        return false
    }
    
    func isFIleVideo(pathFile:URL)->Bool{
        let fileType = NSURL(fileURLWithPath: pathFile.path).pathExtension
        if fileType != nil {
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileType! as CFString, nil)
            if (UTTypeConformsTo((uti?.takeRetainedValue())!, kUTTypeMovie))
                {
//                print("This is an video!")
                return true
            }
        }
        return false
    }
    
    func isFileImage(pathFile:URL)-> Bool{
        let fileType = NSURL(fileURLWithPath: pathFile.path).pathExtension
        if fileType != nil {
            let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileType! as CFString, nil)
            if (UTTypeConformsTo((uti?.takeRetainedValue())!, kUTTypeImage))
            {
//                print("This is an image!")
                return true
            }
        }
        return false
    }
}
