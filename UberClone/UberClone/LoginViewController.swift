//
//  LoginViewController.swift
//  UberClone
//
//  Created by Marcelo Mogrovejo on 6/2/17.
//  Copyright © 2017 Marcelo Mogrovejo. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mainButton: UIButton!
    @IBOutlet weak var secondaryButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var isDriverSwitch: UISwitch!
    @IBOutlet weak var riderOrDriverStack: UIStackView!
    
    // MARK: Properties
    
    var isLogIn: Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        if isLogIn {
            riderOrDriverStack.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorLabel.textColor = UIColor.red
        errorLabel.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        redirectUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action methods
    
    @IBAction func selectedType(_ sender: Any) {
    }
    
    @IBAction func mainAction(_ sender: Any) {
        
        if let usernameText = usernameTextField.text {
            if let passwordText = passwordTextField.text {
                if usernameText != "" && passwordText != "" {
                    
                    if isLogIn {
                        print("Logging in...")

                        PFUser.logInWithUsername(inBackground: usernameText, password: passwordText, block: { (user, error) in
                            
                            if error != nil {
                                let err = error! as NSError
                                self.errorLabel.text = err.userInfo["error"]! as? String
                            } else {
                                // User logged in
                                print("User logged in successfully")
                                
                                self.redirectUser()
                            }
                            
                        })

                    } else {
                        print("Signing up...")
                        
                        let user = PFUser()
                        user["username"] = usernameText
                        user["password"] = passwordText
                        user["isDriver"] = isDriverSwitch.isOn
                        user.signUpInBackground(block: { (success, error) in
                            if error != nil {
                                let err = error! as NSError
                                self.errorLabel.text = err.userInfo["error"]! as? String
                            } else {
                                // User added
                                print("User added successfully")
                                
                                self.redirectUser()
                            }
                        })
                    }
                } else {
                    errorLabel.text = "Username and Password are required!"
                }
            }
        }
    }
    
    @IBAction func secondaryAction(_ sender: Any) {
        if isLogIn {
            // Change to SignUp
            mainButton.setTitle(NSLocalizedString("Sign Up", comment: "Main button title for sign up action"), for: [])
            secondaryButton.setTitle(NSLocalizedString("Log In", comment: "Secondary button log in title"), for: [])
            riderOrDriverStack.isHidden = false
            
            isLogIn = false
        } else {
            // Change to LogIn
            mainButton.setTitle(NSLocalizedString("Log In", comment: "Main button title for log in action"), for: [])
            secondaryButton.setTitle(NSLocalizedString("Sign Up", comment: "Secondary button sign up title"), for: [])
            riderOrDriverStack.isHidden = true

            isLogIn = true
        }
    }

    // MARK: Private methods
    
    private func redirectUser() {
        if PFUser.current() != nil {
            if let isDriver = PFUser.current()?["isDriver"] as? Bool {
                if isDriver {
                    // To Driver page
                    
                    // TODO
                    
                } else {
                    // To Raider page
                    performSegue(withIdentifier: "showMainSegue", sender: self)
                }
            }
        }
    }
    
}

// Implement the protocol for hide keyboard when tap return button on keypad

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.usernameTextField.resignFirstResponder()
        self.passwordTextField.resignFirstResponder()
        return true
    }

}

