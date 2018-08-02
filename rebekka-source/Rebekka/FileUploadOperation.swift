//
//  FileUploadOperation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

/** Operation for file uploading. */
internal class FileUploadOperation: WriteStreamOperation {
    private var fileHandle: FileHandle?
    var fileURL: URL!
    
    override func start() {
        do {
            self.fileHandle = try FileHandle(forReadingFrom: fileURL)
            self.startOperationWithStream(aStream: self.writeStream)
        } catch let error as NSError {
            self.error = error
            self.fileHandle = nil
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
    }
    
    override func streamEventHasSpace(aStream: Stream) -> (Bool, NSError?) {
        if let writeStream = aStream as? OutputStream {
            let offsetInFile = self.fileHandle!.offsetInFile
            let data = self.fileHandle!.readData(ofLength: 1024)
            let writtenBytes = writeStream.write((data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), maxLength: data.count)
            if writtenBytes > 0 {
                self.fileHandle?.seek(toFileOffset: offsetInFile + UInt64(writtenBytes))
            } else if writtenBytes == -1 {
                self.finishOperation()
            }
        }
        return (true, nil)
    }
    
}
