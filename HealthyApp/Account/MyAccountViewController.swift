import UIKit
import FirebaseAuth
import CoreData

class MyAccountViewController: UIViewController {
    
    let userDefaults = UserDefaults.standard
    
    @IBAction func resetWorkoutScheduleBtn(_ sender: UIButton) {
        userDefaults.removeObject(forKey: "how_many_days")
        userDefaults.removeObject(forKey: "day_start")
    }
    
    @IBAction func logoutBtn(_ sender: UIButton) {
        
        
        let alertController = UIAlertController(title: "Warning", message: "Are you sure want to logout?", preferredStyle: .alert)
        
        let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
            
            
            UserDefaults.standard.removeObject(forKey: "login")
            UserDefaults.standard.removeObject(forKey: "email")
            UserDefaults.standard.removeObject(forKey: "uid")
            
            do
            {
                try Auth.auth().signOut()
                let firstVC = self.storyboard?.instantiateViewController(identifier: Constants.Stroyboard.loginRegisterViewControllerIndentifier) as? FirstNavigationController
                self.view.window?.rootViewController = firstVC
                self.view.window?.makeKeyAndVisible()
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
            
        }
        alertController.addAction(OKAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
            
        }
        alertController.addAction(cancelAction)
        
        // Present Dialog message
        self.present(alertController, animated: true, completion:nil)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

}
