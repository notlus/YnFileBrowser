import Cocoa
import YnFileBrowserShared

class FileCollectionViewController: NSViewController {
    @IBOutlet var collectionView: NSCollectionView!
    var viewModel: AppViewModel!
    var delegate: SplitViewController!

    var fileNodes: [FileNode] = [] {
        didSet {
            collectionView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension FileCollectionViewController: NSCollectionViewDataSource, NSCollectionViewDelegate {
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

        item.imageView?.image = fileNodes[indexPath.item].icon
        item.textField?.stringValue = fileNodes[indexPath.item].url.lastPathComponent

        return item
    }

    func collectionView(_: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else { return }

        let selectedFile = fileNodes[indexPath.item]
        if selectedFile.isDirectory, selectedFile.children.isEmpty {
            viewModel.fileBrowser.getFileMetadata(path: selectedFile.url.path, completion: { childNode in
                selectedFile.children = childNode!.children

                self.delegate.handleSelectionChange(for: selectedFile, from: self)
            })
        }
    }
}
