import Cocoa
import YnFileBrowserShared

class DetailViewContainer: NSView {
    override var acceptsFirstResponder: Bool { return true }
}

class SplitViewController: NSSplitViewController {
    var viewModel: AppViewModel!
    var imageViewController: ImageViewController!
    var fileMetadataViewController: FileDetailsViewController!
    var fileCollectionViewController: FileCollectionViewController!

    var detailViewController: NSViewController {
        splitViewItems[1].viewController
    }

    override func viewDidLoad() {
        viewModel = AppViewModel(splitViewController: self)
        super.viewDidLoad()

        imageViewController = storyboard!.instantiateController(
            withIdentifier: "ImageViewController") as? ImageViewController

        fileMetadataViewController = storyboard!.instantiateController(
            withIdentifier: "MetadataViewController") as? FileDetailsViewController

        fileCollectionViewController = storyboard!.instantiateController(
            withIdentifier: "FileCollectionViewController") as? FileCollectionViewController
    }

    func handleSelectionChange(for fileNode: FileNode) {
        if !detailViewController.children.isEmpty {
            // Remove existing child
            detailViewController.removeChild(at: 0)
            detailViewController.view.subviews[0].removeFromSuperview()
        }

        if fileNode.isImage {
            addChildToDetailViewController(imageViewController)
            imageViewController.imageView.image = fileNode.getFileContents()
        }
        else if fileNode.isDirectory, !fileNode.children.isEmpty {
            // Show the child files and folders
            addChildToDetailViewController(fileCollectionViewController)
            fileCollectionViewController.fileNodes = fileNode.children
        }
        else {
            // Show file metadata
            addChildToDetailViewController(fileMetadataViewController)
            fileMetadataViewController.fileNode = fileNode
        }
    }

    private func addChildToDetailViewController(_ childViewController: NSViewController) {
        detailViewController.addChild(childViewController)
        detailViewController.view.addSubview(childViewController.view)

        NSLayoutConstraint.activate([
            childViewController.view.topAnchor.constraint(equalTo: detailViewController.view.topAnchor),
            childViewController.view.bottomAnchor.constraint(equalTo: detailViewController.view.bottomAnchor),
            childViewController.view.leadingAnchor.constraint(equalTo: detailViewController.view.leadingAnchor),
            childViewController.view.trailingAnchor.constraint(equalTo: detailViewController.view.trailingAnchor)
        ])
    }
}
