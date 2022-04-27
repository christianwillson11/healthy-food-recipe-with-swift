import UIKit

class WorkoutTableViewCell: UITableViewCell {

    @IBOutlet weak var poseImage: UIImageView!
    @IBOutlet weak var poseNameLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    
    var data: Workout! {
        
        didSet {
            poseImage.image = data.image
            poseNameLabel.text = data.name
            durationLabel.text = (data.duration)! + " seconds"
        }
        
    }
    

}
