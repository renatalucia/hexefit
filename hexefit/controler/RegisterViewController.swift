//
//  RegisterViewController.swift
//  hexefit
//
//  Created by Renata Rego on 15/07/2021.
//

import UIKit
import FirebaseAuth


class RegisterViewController: UIViewController {
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func registerPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
        
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
        
              guard let user = authResult?.user, error == nil else {
                var errorMessage = "Create User Error: \(error!)"
                if let errCode = AuthErrorCode(rawValue: error!._code) {
                    
                    switch errCode {
                    case .invalidEmail:
                            errorMessage = "Please type a valid email address"
                        case .emailAlreadyInUse:
                            errorMessage = "The email address is already in use"
                        default:
                            errorMessage = "Create User Error: \(error!)"
                    }
                }
                print(errorMessage)
                let alert = UIAlertController(title: "Sign up Failed", message: errorMessage, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
              }
              print("\(user.email!) created")
       
            }
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
