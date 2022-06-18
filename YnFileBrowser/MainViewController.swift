//
//  ViewController.swift
//  YnFileBrowser
//
//  Created by Jeffrey Sulton on 6/17/22.
//

import Cocoa

class MainViewController: NSViewController, NSToolbarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear() {
//        let toolbar = NSToolbar(identifier: "yntoolbar")
//        toolbar.delegate = self
//        toolbar.allowsUserCustomization = false
//        toolbar.displayMode = .iconOnly
//        view.window?.toolbar = toolbar
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}
