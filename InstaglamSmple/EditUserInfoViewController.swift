//
//  EditUserInfoViewController.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/02.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NCMB
import NYXImagesKit

class EditUserInfoViewController: UIViewController,UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var userIntrodctionTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //imageViewを丸くする   bounsは大きさなどが取得できるコード widthは横幅
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        userImageView.contentMode = .scaleAspectFill
        
        userNameTextField.delegate = self
        userIdTextField.delegate = self
        userIntrodctionTextView.delegate = self
        
        
        
        //NCMB上のユーザー情報を読み込み
        if let user = NCMBUser.current() {
            userNameTextField.text = user.object(forKey: "displayName") as? String
                       userIdTextField.text = user.userName
                       userIntrodctionTextView.text = user.object(forKey: "introduction") as? String
                       self.navigationItem.title = user.userName
                
                //画像表示
                let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
                file.getDataInBackground { (data, error) in
                    if error != nil {
                 //       print(error)
                    } else {
                        if data != nil {
                            let image = UIImage(data: data!)
                            self.userImageView.image = image
                        }
                    }
                }
        }else {
            //NCMBUser.current()がnilだった時　ログアウトの処理と同じ
                       let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                                         let rootviewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
                                         UIApplication.shared.keyWindow?.rootViewController = rootviewController
                                         //ログアウト状態の保持
                                         let ud = UserDefaults.standard
                                         ud.set(false, forKey: "isLogin")
                                         ud.synchronize()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        textView.resignFirstResponder()
        return true
    }

    //画像が選ばれた時
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
        picker.delegate = self
        
        //pickerから画像を取り出す
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
               
        //画像のリサイズ byFactorは縦横比を維持しながら調節してくれる
        let resizedImage = selectedImage.scale(byFactor: 0.2)
        
               //pickerを閉じる
               picker.dismiss(animated: true, completion: nil)
        
        //uploadするためにはUIImage型ではなくdata型にしなければならないから
        let data = UIImage.pngData(resizedImage!)
        //画像の名前を整理しやすいようにwithName
        let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: data()) as! NCMBFile
        file.saveInBackground({ (error) in
            if error != nil {
          //      print(error)
            }else {
                //uploadが完了するとImageviewの中に画像が入る
                self.userImageView.image = resizedImage
            }
        }) { (progress) in
        //    print(progress)
        }
        
    }
    
    @IBAction func selectImage() {
        let actionController = UIAlertController(title: "画像の選択", message: "選択してください", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            //カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else {
          //      print("この端末ではカメラは使用できません")
            }
        }
        let albumaAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
            //アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
            } else {
        //        print("この端末ではフォトライブラリが使用できません")
            }
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        actionController.addAction(cameraAction)
        actionController.addAction(albumaAction)
        actionController.addAction(cancelAction)
        actionController.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        actionController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
            self.present(actionController, animated: true, completion: nil)
    }
    
    @IBAction func closeEditViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    //ユーザー情報を完了ボタンを押すとNCMB上に保存
    @IBAction func saveUserInfo() {
        let user = NCMBUser.current()
        user?.setObject(userNameTextField.text, forKey: "displayName")
        user?.setObject(userIdTextField.text, forKey: "userName")
        user?.setObject(userIntrodctionTextView.text, forKey: "introduction")
        user?.saveInBackground({ (error) in
            if error != nil {
          //      print(error)
            }else {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
}
