import UIKit

protocol ChooseWorkoutPreferencesDelegate {
    func didChooseWorkoutPreferences(how_many_days: Int, day_start: String)
}

class WorkoutSchedulingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    @IBOutlet weak var daysCount: UITextField!
    
    @IBOutlet weak var dayPickerView: UIPickerView!
    
    @IBAction func submitBtn(_ sender: UIButton) {
        if ((daysCount.text! as NSString).integerValue < 1 || (daysCount.text! as NSString).integerValue > 7) {
            
            let alert = UIAlertController(title: "Error", message: "Invalid Day Count", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            chooseWorkoutDelegate.didChooseWorkoutPreferences(how_many_days: 3, day_start: userDayStart ?? "Monday")
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    var chooseWorkoutDelegate: ChooseWorkoutPreferencesDelegate!
    let dayPickerData = ["Sunday", "Monday"]
    var userDayStart: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    
        dayPickerView.delegate = self
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dayPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dayPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userDayStart = dayPickerData[row]
    }

}
