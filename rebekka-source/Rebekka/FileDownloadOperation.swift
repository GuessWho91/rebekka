//
//  FileDownloadOperation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

/** Operation for downloading a file from FTP server. */
internal class FileDownloadOperation: ReadStreamOperation {
    
    private var fileHandle: FileHandle?
    var fileURL: URL?
    
    override func start() {
        let filePath = (NSTemporaryDirectory() as NSString).appendingPathComponent(NSUUID().uuidString)
        self.fileURL = URL(fileURLWithPath: filePath)
        do {
            try NSData().write(to: self.fileURL! as URL, options: NSData.WritingOptions.atomic)
            self.fileHandle = try FileHandle(forReadingFrom: self.fileURL!)
            self.startOperationWithStream(aStream: self.readStream)
        } catch let error as NSError {
            self.error = error
            self.finishOperation()
        }
    }
    
    override func streamEventEnd(aStream: Stream) -> (Bool, NSError?) {
        self.fileHandle?.closeFile()
        return (true, nil)
    }
    
    override func streamEventError(aStream: Stream) {
        super.streamEventError(aStream: aStream)
        self.fileHandle?.closeFile()
        if self.fileURL != nil {
            do {
                try FileManager.default.removeItem(at: self.fileURL! as URL)
            } catch _ {
            }
        }
        self.fileURL = nil
    }
    
    override func streamEventHasBytes(aStream: Stream) -> (Bool, NSError?) {
        if let inputStream = aStream as? InputStream {
            var parsetBytes: Int = 0
            repeat {
                parsetBytes = inputStream.read(self.temporaryBuffer, maxLength: 1024)
                if parsetBytes > 0 {
                    autoreleasepool {
                        let data = NSData(bytes: self.temporaryBuffer, length: parsetBytes)
                        self.fileHandle!.write(data as Data)
                    }
                }
            } while (parsetBytes > 0)
        }
        return (true, nil)
    }
}
