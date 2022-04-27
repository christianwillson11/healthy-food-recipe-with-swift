import UIKit
import FirebaseDatabase

class WorkoutCountdownViewController: UIViewController {
    
    let ref = Database.database(url: "https://healthy-app-9861e-default-rtdb.firebaseio.com/").reference()
    
    var timeArray: [Int] = [5]
    var imageArray = [UIImage]()
    private var index = 0
    private var time: Int = 30
    private var timer = Timer()
    
    
    
    @IBOutlet weak var workoutImageView: UIImageView!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var pauseBtnOutlet: UIButton!
    
    @IBAction func pauseBtn(_ sender: UIButton) {
        if sender.titleLabel?.text == "Pause" {
            timer.invalidate()
            pauseBtnOutlet.setTitle("Resume", for: .normal)
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(counter), userInfo: nil, repeats: true)
            pauseBtnOutlet.setTitle("Pause", for: .normal)
        }
        
    }
    
    @IBAction func finishBtn(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDataFromDatabase()
        
        self.time = self.timeArray[self.index]

        let (_, m, s) = self.secondsToHoursMinutesSeconds(seconds: self.time)
        
        self.timerLabel.text = self.convertToString(minutes: m, seconds: s)
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.counter), userInfo: nil, repeats: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Change `2.0` to the desired number of seconds.
            
            self.workoutImageView.image = self.imageArray[self.index]
        }
        
    }
    
    @objc func counter() {
        //time in seconds
        time -= 1
        let (_, m, s) = secondsToHoursMinutesSeconds(seconds: time)
        timerLabel.text = convertToString(minutes: m, seconds: s)
        if time == 0 {
            if index != timeArray.count {
                index += 1
                time = timeArray[index]
            } else {
                timer.invalidate()
                workoutImageView.image = imageArray[index]
            }
            
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func convertToString (minutes: Int, seconds: Int) -> String {
        var result: String
        var new_minutes = String(minutes)
        var new_seconds = String(seconds)
        
        if minutes < 10 {
            new_minutes = "0\(minutes)"
        }
        if seconds < 10 {
            new_seconds = "0\(seconds)"
        }
        
        result = "\(new_minutes) : \(new_seconds)"
        
        
        return result
        
    }
    
    func getDataFromDatabase() {
        ref.child("Workout").observeSingleEvent(of: .value) {
            (snapshot) in
            let workouts = snapshot.value as? [String: Any]
        
            
            guard let workout = workouts?["day\(Date().dayNumberOfWeek()!)"] as? [String: Any] else {
                return
            }
            
            for (_, a) in workout {
                
                guard let data = a as? [String: String] else {
                    print("error")
                    return
                }
                
                let url = URL(string: data["image"] ?? "")!
                
                URLSession.shared.dataTask(with: url, completionHandler: { img_data, _, error in
                    guard let imgData = img_data, error == nil else {
                        return
                    }
                
                    DispatchQueue.main.async {
                        self.timeArray.append(30)
                        //TODO = Change UIImage salad to 'none'
                        self.imageArray.append(UIImage(data: imgData) ?? UIImage(named: "salad")!)
                        
                    }
                    
                }).resume()
                
                
                
            }
            
        }
    }

}
