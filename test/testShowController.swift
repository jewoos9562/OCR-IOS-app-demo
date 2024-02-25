import UIKit

class testShowController: UIViewController {

    var correctedImage: UIImage?
    var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.image = correctedImage
        view.addSubview(imageView)
    }
}

