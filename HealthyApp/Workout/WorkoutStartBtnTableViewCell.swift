import UIKit

protocol StartBtnDelegate {
    func didPressStartBtn(status: Bool)
}

class WorkoutStartBtnTableViewCell: UITableViewCell {
    
    var startDelegate: StartBtnDelegate!

    @IBAction func startBtn(_ sender: UIButton) {
        startDelegate.didPressStartBtn(status: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
