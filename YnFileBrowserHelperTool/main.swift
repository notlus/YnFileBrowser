//
//  main.swift
//  ynXPC
//
//  Created by Jeffrey Sulton on 5/17/22.
//

import Foundation


let fileBrowserService = FileBrowserService() //FileBrowserServiceDelegate()
let listener = NSXPCListener.service()
listener.delegate = fileBrowserService
listener.resume()
