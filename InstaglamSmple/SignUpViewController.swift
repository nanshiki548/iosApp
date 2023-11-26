//
//  SignUpViewController.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/02.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NCMB

class SignUpViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!
    @IBOutlet var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    //    self.view.backgroundColor = UIColor.init(red: 116/255, green: 76/255, blue: 60/255, alpha: 0.1)
        
        
        userIdTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        signUpButton.layer.cornerRadius = 5
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUp() {
        let user = NCMBUser()
        
        if (userIdTextField.text?.count)! < 4 {
            print("文字数が足りません")
            return
        }
        
        user.userName = userIdTextField.text!
        user.mailAddress = emailTextField.text!
        
        if passwordTextField.text == confirmTextField.text {
            user.password = passwordTextField.text!
        } else {
            print("パスワードの不一致")
        }
        
//        var error : NSError? = nil
//            NCMBUser.requestAuthenticationMail(emailTextField.text, error: &error)
//            if (error != nil) {
//             print(error)
//            }
//        //    print(“メール完了“)
//            self.dismiss(animated: true, completion: nil)
//        //    print(“dismiss完了“)
//            }

        
        user.signUpInBackground { (error) in
            if error != nil {
                //エラーがあった場合
                print(error)
            } else {
            //登録成功
//              let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
//                UIApplication.shared.keyWindow?.rootViewController = rootViewController

                self.navigationController?.popViewController(animated: true)
                
                //ログイン状態の保持
                let ud = UserDefaults.standard
                ud.set(true, forKey: "isLogin")
        }
    }
}


}



