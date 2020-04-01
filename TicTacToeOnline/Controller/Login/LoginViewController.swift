//
//  LoginViewController.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
        emailTextField.becomeFirstResponder()
        
        
        // Do any additional setup after loading the view.
    }
    
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count > 7
    }
    
    @IBAction func loginAction(_ sender: UIButton) {
        //validate content
        guard let email = emailTextField.text, email.count > 0, isValid(email) else {
            print("invalid email adress")
            self.errorLabel.text = "invalid email adress"
            return
        }
        
        guard let password = passwordTextField.text, password.count > 5 else {
            print("invalid password, password must contain at least 6 characters")
            self.errorLabel.text = "invalid password, password must contain at least 6 characters"
            return
        }
        
         self.errorLabel.text = ""
        
        //disable button
        sender.isEnabled = false
        
        //login to firebase
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("login failed with error \(error)")
                sender.isEnabled = true
                self.errorLabel.text = "login failed check your info"
                return
            }
            
           
            
            FlowController.shared.determineRoot()
        }
    }
    
    @IBAction func forgotPasswordAction(_ sender: Any) {
        
        let alert = UIAlertController(title: "Reset Password", message: nil, preferredStyle: .alert)
        let label = UILabel(frame: CGRect(x: 0, y: 40, width: 270, height:18))
        label.textAlignment = .center
        label.textColor = .red
        label.font = label.font.withSize(12)
        alert.view.addSubview(label)
        alert.addTextField {
            $0.placeholder = "Enter your email adress"
            $0.becomeFirstResponder()
        }
     
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        let createAction = UIAlertAction(title: "Send", style: .default) { (_) in
            //.. create stuff goes here
           
            guard  let email : String = alert.textFields?.first?.text, email.count > 0, self.isValid(email) == true else{
                label.text = "Invalid mail adress check your info"
                self.present(alert, animated: true, completion: nil)
                return
            }
            
           Auth.auth().sendPasswordReset(withEmail: email) { error in
               DispatchQueue.main.async {
                   if error != nil {
                    label.text = "Reset Failed"
                    print("Error: \(String(describing: error?.localizedDescription))")
                    
                       self.present(alert, animated: true, completion: nil)
                   }
                   if error == nil {
                       let resetEmailAlertSent = UIAlertController(title: "Reset Email Sent", message: "Reset email has been sent to your login email, please follow the instructions in the mail to reset your password", preferredStyle: .alert)
                       resetEmailAlertSent.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                       self.present(resetEmailAlertSent, animated: true, completion: nil)
                   }
               }
           }
        }
        alert.addAction(createAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
    
    
}


