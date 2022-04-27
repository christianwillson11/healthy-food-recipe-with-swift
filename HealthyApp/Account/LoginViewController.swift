import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var errorMsg: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginBtn(_ sender: UIButton) {
        
        //login
        
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    self.errorMsg.isHidden = false
                    switch errCode {
                    case .invalidEmail:
                        self.errorMsg.text = "Invalid Email"
                    case .wrongPassword:
                        self.errorMsg.text = "Wrong Password"
                    default:
                        self.errorMsg.text = "Email not registered"
                    
                    }
                }
            } else {
                UserDefaults.standard.set(true, forKey: "login")
                UserDefaults.standard.set(email, forKey: "email")
                UserDefaults.standard.set(result?.user.uid, forKey: "uid")
                
                let homeVC = self.storyboard?.instantiateViewController(identifier: Constants.Stroyboard.homeViewControllerIdentifier) as? TabBarController
                self.view.window?.rootViewController = homeVC
                self.view.window?.makeKeyAndVisible()
            }
            
        }
        
    }
    
    
    @IBAction func goToRegisterBtn(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorMsg.isHidden = true
        // Do any additional setup after loading the view.
    }

}
