import UIKit
import FirebaseDatabase

class WorkoutViewController: UIViewController {
    
    let ref = Database.database(url: "https://healthy-app-9861e-default-rtdb.firebaseio.com/").reference()
    
    var workoutData = [Workout]()
    
    let userDefaults = UserDefaults.standard
    
    var totalDuration = 0
    var btnStartStatus = true


    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var workoutsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workoutsTableView.dataSource = self
        workoutsTableView.delegate = self
        workoutsTableView.separatorStyle = .none
        
        if isWorkoutScheduleUserDefaultSet() == false {
            let schedulingVC = self.storyboard?.instantiateViewController(identifier: "WorkoutSchedulingViewController") as! WorkoutSchedulingViewController
            schedulingVC.chooseWorkoutDelegate = self
            self.present(schedulingVC, animated: true, completion: nil)
        } else {
            if (UserDefaults.standard.string(forKey: "day_start") == "Monday") {
                if (Date().dayNumberOfWeek()! >= UserDefaults.standard.integer(forKey: "how_many_days")) || Date().dayNumberOfWeek() == 0 {
                    infoLabel.text = "Yeay... No Workouts for today!"
                    btnStartStatus = false
                } else {
                    self.getDataFromDatabase()
                }
            } else {
                if Date().dayNumberOfWeek()! > UserDefaults.standard.integer(forKey: "how_many_days") {
                    infoLabel.text = "Yeay... No Workouts for today!"
                    btnStartStatus = false
                } else {
                    self.getDataFromDatabase()
                }
            }
            

        }
        
    }
    
    func isWorkoutScheduleUserDefaultSet() -> Bool {
        
        if userDefaults.value(forKey: "how_many_days") == nil && userDefaults.value(forKey: "day_start") == nil {
            return false
        } else {
            return true
        }
    }

    

    
    
    //MARK: - Firebase Database
    func getDataFromDatabase() {
        ref.child("Workout").observeSingleEvent(of: .value) {
            (snapshot) in
            let workouts = snapshot.value as? [String: Any]
        
            
            guard let workout = workouts?["day\(Date().dayNumberOfWeek()!)"] as? [String: Any] else {
                self.infoLabel.text = "Error when parsing the data. Please try again."
                self.btnStartStatus = false
                self.workoutsTableView.reloadData()
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
                        self.workoutData.append(Workout(name: data["name"], duration: data["duration"], image: UIImage(data: imgData)))
                        self.totalDuration += Int(data["duration"]!)!
                        self.infoLabel.text = "\(self.totalDuration) seconds ∙ \(self.workoutData.count) workouts"
                        self.workoutsTableView.reloadData()
                    }
                    
                }).resume()
                
                
                
            }
            
        }
    }
}

extension WorkoutViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if btnStartStatus == false {
            return 0
        } else {
            return workoutData.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row < workoutData.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutTableViewCell", for: indexPath) as! WorkoutTableViewCell

            cell.data = workoutData[indexPath.row]

            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WorkoutStartBtnTableViewCell", for: indexPath) as! WorkoutStartBtnTableViewCell
            cell.startDelegate = self
            return cell
        }
        
    }
    
    
    
    
}


extension WorkoutViewController: ChooseWorkoutPreferencesDelegate {
    func didChooseWorkoutPreferences(how_many_days: Int, day_start: String) {
        userDefaults.set(how_many_days, forKey: "how_many_days")
        userDefaults.set(day_start, forKey: "day_start")
    
        
        if Date().dayNumberOfWeek()! > UserDefaults.standard.integer(forKey: "how_many_days") {
            infoLabel.text = "Yeay... No Workouts for today!"
        } else {
            self.getDataFromDatabase()
        }
    }
    
    
}

extension WorkoutViewController: StartBtnDelegate {
    func didPressStartBtn(status: Bool) {
        if status {
            let detailVC = storyboard?.instantiateViewController(identifier: "WorkoutCountdownViewController") as! WorkoutCountdownViewController
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}


extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday! - 1
        
    }
}
