import Cocoa
import YnFileBrowserShared

class FileCollectionViewController: NSViewController {
    @IBOutlet var collectionView: NSCollectionView!

    var fileNodes: [FileNode] = []

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension FileCollectionViewController: NSCollectionViewDataSource {
    func collectionView(
        _: NSCollectionView,
        numberOfItemsInSection _: Int) -> Int {
        fileNodes.count
    }

    func collectionView(
        _: NSCollectionView,
        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(
            withIdentifier: NSUserInterfaceItemIdentifier("FileCollectionViewItem"),
            for: indexPath)

        guard let item = item as? FileCollectionViewItem else { return item }

        item.imageView?.image = fileNodes[indexPath.item].getIcon()

        return item
    }
}
