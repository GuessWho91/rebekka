//
//  StreamOperation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

/** The base class for stream operations. */
internal class StreamOperation: FTPOperation, StreamDelegate {
    var path: String?
    internal let queue: DispatchQueue
    
    private var currentStream: Stream?
    
    init(configuration: SessionConfiguration, queue: DispatchQueue) {
        self.queue = queue
        super.init(configuration: configuration)
    }
    
    fileprivate func configureStream(_ stream: Stream) {
        stream.setProperty(true, forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyShouldCloseNativeSocket as String))
        stream.setProperty(true, forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyFTPFetchResourceInfo as String))
        stream.setProperty(self.configuration.passive, forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyFTPUsePassiveMode as String))
        stream.setProperty(self.configuration.username, forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyFTPUserName as String))
        stream.setProperty(self.configuration.password, forKey: Stream.PropertyKey(rawValue: kCFStreamPropertyFTPPassword as String))
        stream.delegate = self
    }
    
    func fullURL() -> URL {
        if self.path != nil {
            return self.configuration.URL().appendingPathComponent(path!)
        }
        return self.configuration.URL()
    }
    
    @objc func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        if self.isCancelled {
            self.streamEventError(aStream: aStream)
            self.error = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
            self.finishOperation()
            return
        }
        
        switch eventCode {
        case Stream.Event.openCompleted:
            let _ = self.streamEventOpenComleted(aStream: aStream)
        case Stream.Event.hasBytesAvailable:
            let _ = self.streamEventHasBytes(aStream: aStream)
        case Stream.Event.hasSpaceAvailable:
            let _ = self.streamEventHasSpace(aStream: aStream)
        case Stream.Event.errorOccurred:
            let _ = self.streamEventError(aStream: aStream)
            self.finishOperation()
        case Stream.Event.endEncountered:
            let _ = self.streamEventEnd(aStream: aStream)
            self.finishOperation()
        default:
            print("Unkonwn NSStreamEvent: \(eventCode)")
        }
    }
    
    func startOperationWithStream(aStream: Stream) {
        self.currentStream = aStream
        self.configureStream(self.currentStream!)
        self.currentStream!.open()
        self.state = .Executing
    }
    
    func finishOperation() {
        self.currentStream?.close()
        self.currentStream = nil
        self.state = .Finished
    }
    
    func streamEventOpenComleted(aStream: Stream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    func streamEventEnd(aStream: Stream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    func streamEventHasBytes(aStream: Stream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    func streamEventHasSpace(aStream: Stream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    func streamEventError(aStream: Stream) {
        self.error = aStream.streamError as NSError?
    }
}
