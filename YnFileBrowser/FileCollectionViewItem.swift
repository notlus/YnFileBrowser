import Cocoa

class FileCollectionViewItem: NSCollectionViewItem {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        textField?.stringValue = "My string"
    }
    
}
