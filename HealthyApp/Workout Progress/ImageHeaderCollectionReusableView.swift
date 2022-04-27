import UIKit

class ImageHeaderCollectionReusableView: UICollectionReusableView {
        
    @IBOutlet weak var dateLabel: UILabel!
    
    var date: String! {
        didSet {
            dateLabel.text = date
        }
    }
}
