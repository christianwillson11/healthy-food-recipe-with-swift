import Foundation

class Utilities {
    func checkPassword(pw: String) -> Bool {
        if pw.count >= 6 {
            let password = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&]).{6,}$")
            return password.evaluate(with: "pas$word") // True
        }
        return pw.count >= 6
    }
}
