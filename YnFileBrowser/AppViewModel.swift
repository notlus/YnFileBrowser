import Foundation
import YnFileBrowserShared

final class AppViewModel {
    let fileBrowser: FileBrowserClient = FileBrowserClient()
    var root: FileNode! {
        didSet {
            (splitViewController?.splitViewItems[0].viewController as? TableViewController)?.tableView.reloadData()
        }
    }

    weak var splitViewController: SplitViewController?

    init(splitViewController: SplitViewController) {
        self.splitViewController = splitViewController
        let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
        root = FileNode(url: homeDirectory)
    }
}
