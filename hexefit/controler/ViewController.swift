//
//  ViewController.swift
//  Fitilitc
//
//  Created by Renata Rego on 14/07/2021.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    var userId: String?
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //Looks for single or multiple taps.
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
    
    @IBAction func SigninPressed(_ sender: UIButton) {
        
        
        
        if let email = emailTextField.text,
           let password = passwordTextField.text{
            Auth.auth().signIn(withEmail: email, password: password) {
                 authResult, error in
      
                    if error != nil{
                        print("Error sigining in: \(error!)")
                        return
                    }
                    
          
                print("Signed in successfully")
                self.userId = (Auth.auth().currentUser?.uid)!
                print("Current user ID is" + self.userId!)
                //self.performSegue(withIdentifier: "toHistory", sender: self)
                
            }
        }
        
//        if self.userId != nil{
//
//
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue,
                 sender: Any?){
        if let vc = segue.destination as? HistoryViewController, let safeUserId = userId {
                vc.userId = safeUserId
            }
    }
    
}

