//
//  RegisterViewController.swift
//  TicTacToeOnline
//
//  Created by יצחק נחמן on 28/03/2020.
//  Copyright © 2020 nahman. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var retypePasswordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        errorLabel.text = ""

        // Do any additional setup after loading the view.
        emailTextField.becomeFirstResponder()
    }
    
    @IBAction func submitAction(_ sender: UIButton) {
        
        
        guard let email = emailTextField.text, email.count > 0, isValid(email) else {
            print("invalid email adress")
            self.errorLabel.text = "invalid email adress"
            return
        }
        
        guard let nickName = nicknameTextField.text, nickName.count > 2 else {
            print("invalid nickName, nickName must contain at least 3 characters")
            self.errorLabel.text = "invalid nickName, nickName must contain at least 3 characters"
            return
        }
        
        guard let password = passwordTextField.text, password.count > 5 else {
            print("invalid password, password must contain at least 6 characters")
            self.errorLabel.text = "invalid password, password must contain at least 6 characters"
            return
        }
        
        guard let rePassword = retypePasswordTextField.text, rePassword == password else {
            
            self.errorLabel.text = "Your password and confirmation password do not match."
            return
        }
        
        
        self.errorLabel.text = ""
        
        
        
        
        //disable button
        sender.isEnabled = false
        
        //create firebase user
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                //create user failed
                
                print("create user failed with error \(error)")
                sender.isEnabled = true
                self.errorLabel.text = "create user failed check your info"

                return
            }
            
            //set nickname
            let request = result!.user.createProfileChangeRequest()
            request.displayName = nickName
            request.commitChanges { (commitError) in
                //update main UI, create user was successful
                FirebaseManager.manager.createGameUser()
                FlowController.shared.determineRoot()
            }
        }
        
        
        
        
    }
    
    func isValid(_ email: String) -> Bool {
        let emailRegEx = "(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"+"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"+"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"+"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"+"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"+"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"+"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])"
        
        let emailTest = NSPredicate(format:"SELF MATCHES[c] %@", emailRegEx)
        return emailTest.evaluate(with: email)
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
