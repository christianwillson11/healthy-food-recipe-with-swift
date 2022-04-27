import UIKit

class DetailPhotoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
    }
    
}
