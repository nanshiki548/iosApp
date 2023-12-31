//
//  SignInViewController.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/02.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NCMB

class SignInViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.view.backgroundColor = UIColor.init(red: 116/255, green: 76/255, blue: 60/255, alpha: 0.1)
      
       
        userIdTextField.delegate = self
        passwordTextField.delegate = self
        signInButton.layer.cornerRadius = 5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signIn() {
        
        if (userIdTextField.text?.count)! > 0 &&
            (userIdTextField.text?.count)! > 0 {
            
            NCMBUser.logInWithUsername(inBackground: userIdTextField.text!
            , password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    print(error)
                } else {
                    //ログイン成功
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    //ログイン状態の保持
                                   let ud = UserDefaults.standard
                                   ud.set(true, forKey: "isLogin")
                                   ud.synchronize()
                }
            }
        }
        
    }
    
    @IBAction func forgetPassword() {
        //置いておく
    }

}


