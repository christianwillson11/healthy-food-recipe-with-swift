import UIKit
import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {

    @IBOutlet weak var errorMsg: UILabel!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var fullNameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private let ref = Database.database(url: "https://healthy-app-9861e-default-rtdb.firebaseio.com/").reference()
    
    @IBAction func registerBtn(_ sender: Any) {
        
        if (!usernameTextField.text!.isEmpty || !fullNameTextField.text!.isEmpty || !emailTextField.text!.isEmpty || !passwordTextField.text!.isEmpty) {

            let sanitizePassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

//            if checkPassword(pw: sanitizePassword) {

                Auth.auth().createUser(withEmail: emailTextField.text!, password: sanitizePassword) { (result, error) in

                    if error != nil {
                        if let errCode = AuthErrorCode(rawValue: error!._code) {
                            
                            self.errorMsg.isHidden = false
                            
                            switch errCode {
                            case .invalidEmail:
                                self.errorMsg.text = "Invalid Email / Bad formatted Email"
                            case .emailAlreadyInUse:
                                self.errorMsg.text = "Email already in use"
                            default:
                                self.errorMsg.text = "Oops... Something went wrong"
                                
                            }
                            
                        }
                    } else {

                        let sanitizeUsername = self.usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                        let sanitizefullName = self.fullNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)

                        self.setDataToDatabase(uid: result!.user.uid, fullName: sanitizefullName, username: sanitizeUsername)

                        let alert = UIAlertController(title: "Success", message: "Yeay! Your account has been successfully created!", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)

                        //go to main screen

                        let homeVC = self.storyboard?.instantiateViewController(identifier: Constants.Stroyboard.homeViewControllerIdentifier) as? TabBarController
                        self.view.window?.rootViewController = homeVC
                        self.view.window?.makeKeyAndVisible()

                    }

                }
            } else {

                let alert = UIAlertController(title: "Error", message: "Please make sure your password is at least 8 characters and must contains a special characters and numbers.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }

//        } else {
//            let alert = UIAlertController(title: "Error", message: "You must fill all the data", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//            return
//        }
        
        
        
    }
    
    private func checkPassword(pw: String) -> Bool {
        if pw.count >= 8 {
            //check password strengthness
            let password = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&]).{6,}$")
            return password.evaluate(with: pw)
        } else {
            return false
        }
    }
    
    private func setDataToDatabase(uid: String, fullName: String, username: String) {
        ref.child("Users").child(uid).setValue(
            ["full_name": fullName,
             "username": username
            ]
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorMsg.isHidden = true
        
    }

}
