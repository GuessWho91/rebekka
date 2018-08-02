//
//  Operation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

internal enum OperationState {
    case None
    case Ready
    case Executing
    case Finished
}

/** The base class for FTP operations used in framework. */
internal class FTPOperation: Operation {

    var error: NSError?
    
    internal let configuration: SessionConfiguration
    
    internal var state = OperationState.Ready {
        willSet {
            self.willChangeValue(forKey: "isReady")
            self.willChangeValue(forKey: "isExecuting")
            self.willChangeValue(forKey: "isFinished")
        }
        didSet {
            self.didChangeValue(forKey: "isReady")
            self.didChangeValue(forKey: "isExecuting")
            self.didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isAsynchronous: Bool { get { return true } }
    
    override var isReady: Bool { get { return self.state == .Ready } }
    override var isExecuting: Bool { get { return self.state == .Executing } }
    override var isFinished: Bool { get { return self.state == .Finished } }
    
    init(configuration: SessionConfiguration) {
        self.configuration = configuration
    }
}
