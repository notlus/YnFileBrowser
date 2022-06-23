import Cocoa

class ImageViewController: NSViewController {
    @IBOutlet var imageView: NSImageView!
}

/// A container to host the view currently selected in the right split.
class DetailViewController: NSViewController {

    var viewModel: FileViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
