import Foundation
import YnFileBrowserShared

final class AppViewModel {
    var root: FileNode!
    var selectedFileNode: FileNode? {
        didSet {
            if let selectedFileNode = selectedFileNode,
               let detailViewController = splitViewController?.children[1] as? DetailViewController {
                detailViewController.viewModel = FileViewModel(
                    detailViewController: detailViewController,
                    fileNode: selectedFileNode)
            }
        }
    }

    weak var splitViewController: SplitViewController?

    var fileName: String {
        root.url.lastPathComponent
    }

    init(splitViewController: SplitViewController) {
        self.splitViewController = splitViewController
        let url = NSURL(string: "file:///Users")!
        let c3 = FileNode(url: NSURL(string: "file:///Users/jeffrey_sulton/dev")!, children: [])
        let c2 = FileNode(url: NSURL(string: "file:///Users/Shared")!, children: [])
        let c4 = FileNode(url: NSURL(string: "file:///Users/jeffrey_sulton/Desktop/sample.png")!, children: [])
        let c5 = FileNode(url: NSURL(string: "file:///Users/jeffrey_sulton/Desktop/notluS.json")!, children: [])
        let c1 = FileNode(url: NSURL(string: "file:///Users/jeffrey_sulton")!, children: [c3, c4, c5])
        root = FileNode(url: url, children: [c1, c2, c4, c5])
    }
}

final class FileViewModel {
    let detailViewController: DetailViewController
    let fileNode: FileNode

    var fileName: String {
        fileNode.url.lastPathComponent
    }

    var children: [FileNode] {
        fileNode.children
    }

    init(detailViewController: DetailViewController, fileNode: FileNode) {
        self.detailViewController = detailViewController
        self.fileNode = fileNode
    }
}
