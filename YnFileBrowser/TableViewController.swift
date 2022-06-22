//
//  NavigatorViewController.swift
//  YnFileBrowser
//
//  Created by Jeffrey Sulton on 6/18/22.
//

import Cocoa
import YnFileBrowserShared

class ViewModel {
    let root: FileNode

    var fileName: String {
        root.url.lastPathComponent
    }

    init() {
        let url = NSURL(string: "/usr/local/bin")!

        let c1 = FileNode(url: NSURL(string: "/usr/local/bin/vimr")!, children: [])
        root = FileNode(url: url, children: [c1])
    }
}

class TableViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!

    private let viewModel: ViewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension TableViewController: NSTableViewDataSource {
    func numberOfRows(in _: NSTableView) -> Int {
        return viewModel.root.children.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cellView = tableView.makeView(
            withIdentifier: tableColumn!.identifier,
            owner: self) as? NSTableCellView else { return nil }
        
        // TODO: Add image for pre macOS 11
        if #available(macOS 11.0, *) {
            if let image = NSImage(
                systemSymbolName: "folder.fill",
                accessibilityDescription: "Folder image") {
                cellView.imageView?.image = image
            }
        } else {
            // Fallback on earlier versions
        }
        cellView.textField?.stringValue = viewModel.root.children[row].url.lastPathComponent

        return cellView
    }
}

extension TableViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_: Notification) {
        guard tableView.selectedRow != -1 else { return }
        guard let splitVC = parent as? NSSplitViewController else { return }

//        if let filesViewController = splitVC.children[1] as? FilesViewController {
//            filesViewController.imageSelected(name: viewModel.root.children[tableView.selectedRow])
//        }
    }
}
