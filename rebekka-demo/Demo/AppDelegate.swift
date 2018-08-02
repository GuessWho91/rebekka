//
//  AppDelegate.swift
//  Demo
//
//  Created by Constantine Fry on 17/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import UIKit
import RebekkaTouch



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var session: Session!
    
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
            // Override point for customization after application launch.
            
            var configuration = SessionConfiguration()
            configuration.host = "ftp://speedtest.tele2.net"
            self.session = Session(configuration: configuration)
            
            testList()
            //testDownload()
            //testUpload()
            //testCreate()
            return true
    }
    
    func testList() {
        self.session.list(path: "/") {
            (resources, error) -> Void in
            print("List directory with result:\n\(String(describing: resources)), error: \(String(describing: error))\n\n")
        }
    }
    
    func testUpload() {
        if let URL = Bundle.main.url(forResource: "TestUpload", withExtension: "png") {
            let path = "/upload/\(NSUUID().uuidString).png"
            self.session.upload(fileURL: URL as NSURL, path: path) {
                (result, error) -> Void in
                print("Upload file with result:\n\(result), error: \(String(describing: error))\n\n")
            }
        }
    }
    
    func testDownload() {
        self.session.download(path: "/1MB.zip") {
            (fileURL, error) -> Void in
            print("Download file with result:\n\(String(describing: fileURL)), error: \(String(describing: error))\n\n")
            if let fileURL = fileURL {
                do {
                    try FileManager.default.removeItem(at: fileURL as URL)
                } catch let error as NSError {
                    print("Error: \(error)")
                }
                
            }
        }
    }
    
    func testCreate() {
        let name = NSUUID().uuidString
        self.session.createDirectory(path: "/upload/\(name)") {
            (result, error) -> Void in
            print("Create directory with result:\n\(result), error: \(String(describing: error))")
        }
    }
    
    
}

