//
//  PostViewController.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/04.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NYXImagesKit
import NCMB
import UITextView_Placeholder
//import SVProgressHUD
import PKHUD
import ActiveLabel
import TinyConstraints


class PostViewController:UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
//    lazy var label: ActiveLabel = {
//        var label = ActiveLabel()
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.text = """
//        This is a post with
//        a #hashtag and a @mention.
//        """
//        label.textColor = .black
//        label.hashtagColor = .blue
//        label.mentionColor = .red
//
//        label.enabledTypes = [.mention, .hashtag]
//
//        label.handleHashtagTap { (hashtag) in
//            print("Tapped on '\(hashtag)'hashtag")
//
//            label.handleMentionTap { (mention) in
//                print("Tapped on '\(mention)'mention")
//            }
//        }
//
//        return label
//    }()
    
    let placeholderImage = UIImage(named: "背景.PNG")
    
    var resizedImage: UIImage!
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet  var postButton: UIBarButtonItem!
    
    @IBOutlet var postTextView: UITextView!
    
    @IBOutlet var selectButton: UIButton!
    
    
    var posts = [Post]()
    
    var comments = [Comment]()
    
    var sum: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        view.addSubview(label)
//        label.centerInSuperview()
 
        postImageView.image = placeholderImage
        
        postButton.isEnabled = false
        postTextView.placeholder = "内容を書く"
        postTextView.delegate = self
        
        selectButton.layer.borderWidth = 0.5                                              // 枠線の幅
        selectButton.layer.borderColor = UIColor.white.cgColor                            // 枠線の色
        selectButton.layer.cornerRadius = 5.0
        postImageView.layer.cornerRadius = 5.0
        // 角丸のサイズ
        selectButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        
    }
    override func viewWillAppear(_ animated: Bool) {
        loadPosts()
        loadComments()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
         let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        
        
        if selectedImage != nil {
        
        resizedImage = selectedImage.scale(byFactor: 0.4)
        
        postImageView.image = resizedImage
        
        picker.dismiss(animated: true, completion: nil)
        
        confirmContent()
        } 
    }
    
    func textViewDidChange(_ textView: UITextView) {
     //   confirmContent()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    func
     Context() -> Bool{
      //  print(postImageView.image)
        if postImageView.image != nil || likeSum() >= 0 {
            postButton.isEnabled = true
            return true
        }else{
            postButton.isEnabled = false
      //      print("ボタンを押せません")
            return false
        }
    }
    
    @IBAction func selectImage() {
        let alertController = UIAlertController(title: "画像選択", message: "シェアする画像を選択して下さい。", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            // カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
          //      print("この機種ではカメラが使用出来ません。")
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
        
        alertController.addAction(cameraAction)
        alertController.addAction(albumaAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func canPost() {
        if likeSum() >= 0 {
            postButton.isEnabled = true
        }else{
            postButton.isEnabled = false
            let alert = UIAlertController(title: "段位に到達していません", message: "2級以上で投稿できます", preferredStyle: .alert)
             let alertAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                self.performSegue(withIdentifier: "toTimeline", sender: nil)
                  })
            alert.addAction(alertAction)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func likeSum() -> Int {
        sum = 0
        for i in 0 ..< comments.count {
                
            sum += comments[i].likeCount
            }
    //    print(sum)
        return sum
    }
    
   
        
   
    
    @IBAction func sharePhoto() {
        
        canPost()
        
        //SVProgressHUD.show()
      // Now some long running task starts...
       DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          HUD.flash(.success, delay: 1.0)
       }
        if postImageView.image != placeholderImage {
        // 撮影した画像をデータ化したときに右に90度回転してしまう問題の解消
        UIGraphicsBeginImageContext(resizedImage.size)
        let rect = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
        resizedImage.draw(in: rect)
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let data = resizedImage.pngData()
        // ここを変更（ファイル名無いので）
        let file = NCMBFile.file(with: data) as! NCMBFile
        file.saveInBackground({ (error) in
            
            if error != nil {
                // SVProgressHUD.dismiss()
               
                let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                // 画像アップロードが成功
                let postObject = NCMBObject(className: "Post")
                
//                if self.postTextView.text.count == 0 {
//                  print("入力されていません")
//                    return
//                }
                postObject?.setObject(self.postTextView.text!, forKey: "text")
                postObject?.setObject(NCMBUser.current(), forKey: "user")
                let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + file.name
                postObject?.setObject(url, forKey: "imageUrl")
                postObject?.saveInBackground({ (error) in
                    if error != nil {
                        //    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                           HUD.flash(.error, delay: 1.0)
                        }
                    } else {
                        //    SVProgressHUD.dismiss()
    
                        self.postImageView.image = nil
                        self.postImageView.image = UIImage(named: "背景.PNG")
                        self.postTextView.text = nil
                        self.tabBarController?.selectedIndex = 0
                    }
                })
            }
        }) { (progress) in
    //        print(progress)
            }
        } else {
            let postObject = NCMBObject(className: "Post")
            
//            if self.postTextView.text.count == 0 {
//                print("入力されていません")
//                return
//            }
            postObject?.setObject(self.postTextView.text!, forKey: "text")
            postObject?.setObject(NCMBUser.current(), forKey: "user")
            postObject?.saveInBackground({ (error) in
                if error != nil {
                    //    SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        HUD.flash(.error, delay: 1.0)
                    }
                } else {
                    //    SVProgressHUD.dismiss()
                    
                    self.postTextView.text = nil
                    self.tabBarController?.selectedIndex = 0
                }
                }
            )}
    }
    
    func confirmContent() {
        if postTextView.text.count > 0 || postImageView.image != placeholderImage {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
    }
    
    @IBAction func cancel() {
        if postTextView.isFirstResponder == true {
            postTextView.resignFirstResponder()
        }
        
        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.postTextView.text = nil
            self.postImageView.image = UIImage(named: "背景.PNG")
       //     self.confirmContent()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        alert.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        self.present(alert, animated: true, completion: nil)
     
    }
    
    
    func loadPosts() {
        guard let currentUser = NCMBUser.current() else {
            //ログインに戻る
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
            //UIWindowにアクセス
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            //ログインしない保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            return
        }
        
        let query = NCMBQuery(className: "Post")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: NCMBUser.current())
       
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
               DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                  HUD.flash(.error, delay: 1.0)
               }
              
            } else {
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    userModel.likeSum = user.object(forKey: "likeSum") as? Int
                    
                    // 投稿の情報を取得
                    let imageUrl = postObject.object(forKey: "imageUrl") as? String
                    let text = postObject.object(forKey: "text") as! String
                    
                    // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                    let post = Post(objectId: postObject.objectId, user: userModel, createDate: postObject.createDate)
                    post.imageUrl = postObject.object(forKey: "imageUrl") as? String
                    post.text = postObject.object(forKey: "text") as? String
                    
                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                    let likeUser = postObject.object(forKey: "likeUser") as? [String]
                    if likeUser?.contains(NCMBUser.current().objectId) == true {
                        post.isLiked = true
                    } else {
                        post.isLiked = false
                    }
//                    if let likes = likeUser {
//                        post.likeCount = likes.count
//                    }
                    // 配列に加える
                    self.posts.append(post)
                }
             
            }
        })
    }

    
    func loadComments() {
        
        guard let currentUser = NCMBUser.current() else {
                   //ログインに戻る
                   let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                   let rootviewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
                   UIApplication.shared.keyWindow?.rootViewController = rootviewController
                   //ログアウト状態の保持
                   let ud = UserDefaults.standard
                   ud.set(false, forKey: "isLogin")
                   ud.synchronize()
                   return
               }
        
        let query = NCMBQuery(className: "Comment")
        // createDateの降順(投稿された順番)
        query?.order(byDescending: "createDate")
        query?.whereKey("user", equalTo: NCMBUser.current())
        query?.includeKey("user")  //コメントの呼び出しと同時にユーザーもとってくる
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    HUD.flash(.error, delay: 1.0)
                }
            } else {
                self.comments = [Comment]()
                for commentObject in result as! [NCMBObject] {
                    // コメントをしたユーザーの情報を取得
                    let user = commentObject.object(forKey: "user") as! NCMBUser
                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool != false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        userModel.likeSum = user.object(forKey: "likeSum") as? Int
                        

                        // コメントの文字を取得
                        let text = commentObject.object(forKey: "text") as! String
                        
                        let userImageUrl = URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + user.objectId)
                        
                        // Commentクラスに格納
                        let comment = Comment(objectId: commentObject.objectId, user: userModel, text: text, createDate: commentObject.createDate)
                        comment.postImageUrl = userImageUrl
                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                    let likeUsers = commentObject.object(forKey: "likeUser") as? [String]
                    if likeUsers?.contains(currentUser.objectId) == true {
                        comment.isLiked = true
                    } else {
                        comment.isLiked = false
                    }
                    
                    // いいねの件数
                    if let likes = likeUsers {
                        comment.likeCount = likes.count
                    }
                    
                    self.comments.append(comment)
                    }
                }
                 self.canPost()
            }
        })
    }
    
}





