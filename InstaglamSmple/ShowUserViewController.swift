//
//  ShowUserViewController.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/06.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
//import SVProgressHUD
import PKHUD



class ShowUserViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    
    var selectedUser: NCMBUser!
    
    var followingInfo: NCMBObject?
    
    var posts = [Post]()
    
    var selectedPost: Post?
    
    var users = [User]()
    
    var comments = [Comment]()
    
    var objectIds = [String]()
    
     var sum: Int = 0
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userDisplayNameLabel: UILabel!
    
    @IBOutlet var userIntroductionTextView: UITextView!
    
    @IBOutlet var photoCollectionView: UICollectionView!
    
    @IBOutlet var postCountLabel: UILabel!
    
    @IBOutlet var followerCountLabel: UILabel!
    
    @IBOutlet var followingCountLabel: UILabel!
    
    @IBOutlet var followButton: BorderButton!
    
    @IBOutlet var lankLabel: UILabel!
    
    @IBOutlet var likeSumLabel: UILabel!
    
    @IBOutlet var rankingLabel: UILabel!
     
    @IBOutlet var allLabel: UILabel!
    
    var blockUserIdArray = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

         userIntroductionTextView.placeholder = "プロフィール紹介文"
        
        photoCollectionView.dataSource = self
        photoCollectionView.delegate = self
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.borderWidth = 0.5
        
        // ユーザー基礎情報の読み込み
        userDisplayNameLabel.text = selectedUser.object(forKey: "displayName") as? String
        userIntroductionTextView.text = selectedUser.object(forKey: "introduction") as? String
        self.navigationItem.title = selectedUser.userName
        
        // プロフィール画像の読み込み
        let file = NCMBFile.file(withName: selectedUser.objectId, data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil {
    //            print(error!.localizedDescription, "00000000000000000000000000")
            } else {
                if data != nil {
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }
        }
        
        // ユーザーの投稿した写真の読み込み
        loadPosts()
        
        loadComments()
        
         loadUsers()
        
        // フォロー状態の読み込み
        loadFollowingStatus()
        
        // フォロー数の読み込み
        loadFollowingInfo()
        
        // 枠のカラー
        userIntroductionTextView.layer.borderColor = UIColor.black.cgColor
        
        // 枠の幅
        userIntroductionTextView.layer.borderWidth = 0.5
        
        // 枠を角丸にする
        userIntroductionTextView.layer.cornerRadius = 5.0
        userIntroductionTextView.layer.masksToBounds = true
        
       followButton.layer.borderWidth = 0.5                                              // 枠線の幅
       followButton.layer.borderColor = UIColor.white.cgColor                            // 枠線の色
       followButton.layer.cornerRadius = 5.0
        
    }
    
    
    func lankUp() {
        switch likeSum()  {
        case 0..<10:
            lankLabel.text = "庶民"
            lankLabel.backgroundColor = UIColor.brown
        case 10..<20:
            lankLabel.text = "1級"
            lankLabel.backgroundColor = UIColor.gray
        case 20..<30:
            lankLabel.text = "2級"
            lankLabel.backgroundColor = UIColor.yellow
        case 30..<40:
            lankLabel.text = "3級"
            lankLabel.backgroundColor = UIColor.orange
        case 40..<50:
            lankLabel.text = "4級"
            lankLabel.backgroundColor = UIColor.systemPink
        case 50..<60:
            lankLabel.text = "5級"
            lankLabel.backgroundColor = UIColor.red
        case 60..<70:
            lankLabel.text = "6級"
            lankLabel.backgroundColor = UIColor.blue
        case 70..<80:
            lankLabel.text = "7級"
            lankLabel.backgroundColor = UIColor.magenta
        case 80..<90:
            lankLabel.text = "8級"
            lankLabel.backgroundColor = UIColor.green
        case 90..<100:
            lankLabel.text = "9級"
            lankLabel.backgroundColor = UIColor.purple
        default:
            lankLabel.text = "殿堂入り"
        }
        self.ranking()
    }
    
    func likeSum() -> Int {
        sum = 0
        for i in 0 ..< comments.count {
            
            sum += comments[i].likeCount
        }
        //        print(sum, "ddddddddddddd")
        return sum
        
    }
    
    func ranking() {
        let indexNumber = objectIds.firstIndex(of: (selectedUser.objectId as? String)!)
        if indexNumber != nil {
            //               print(indexNumber! + 1, "vvvvvvvvvvvvvvvvvvvvvvvvv")
            rankingLabel.text = String(indexNumber! + 1)
        } else {
            //              print("indexNumber = nil")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let photoImageView = cell.viewWithTag(1) as! UIImageView
        if posts[indexPath.row].imageUrl != nil {
            let photoImagePath = URL(string: posts[indexPath.row].imageUrl!)
            photoImageView.kf.setImage(with: photoImagePath)
            photoImageView.contentMode = .scaleAspectFill
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.row]
        performSegue(withIdentifier: "toComment",sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComment" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.postId = selectedPost?.objectId
            if selectedPost!.imageUrl != nil {
                commentViewController.postImageUrl = URL(string: selectedPost!.imageUrl!)
                //          print(selectedPost?.imageUrl, "99999999999999999999" )
            }
            commentViewController.postText = selectedPost?.text
        } else {
            //               print("else")
        }
    }
    
    // Screenサイズに応じたセルサイズを返す
    // UICollectionViewDelegateFlowLayoutの設定が必要
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 横方向のスペース調整
        let horizontalSpace:CGFloat = 3
        let cellSize:CGFloat = self.view.bounds.width/3 - horizontalSpace
        
        // 正方形で返すためにwidth,heightを同じにする
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func loadFollowingStatus() {
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.error, delay: 1.0)
                           }
            } else {
                for following in result as! [NCMBObject] {
                    let user = following.object(forKey: "following") as! NCMBUser
                    
                    // フォロー状態だった場合、ボタンの表示を変更
                    if self.selectedUser.objectId == user.objectId {
                        // 表示変更を高速化するためにメインスレッドで処理
                        DispatchQueue.main.async {
                            self.followButton.setTitle("フォロー解除", for: .normal)
                            self.followButton.setTitleColor(UIColor.red, for: .normal)
                            self.followButton.borderColor = UIColor.red
                        }
                        
                        // フォロー状態を管理するオブジェクトを保存
                        self.followingInfo = following
                        break
                    }
                }
            }
        })
    }
    
    func loadPosts() {
        let query = NCMBQuery(className: "Post")
        query?.order(byDescending: "createDate")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: selectedUser)
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
        //         print(self.posts, "11111111111")
                self.photoCollectionView.reloadData()
         //       print(self.lankLabel.text, "ssssssssss")
                
                // post数を表示
                self.postCountLabel.text = String(self.posts.count)
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
              query?.includeKey("user")  //コメントの呼び出しと同時にユーザーもとってくる
              query?.whereKey("user", equalTo: selectedUser)
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
                      // テーブルをリロード
                      self.likeSum()
                      self.saveLikeSum()
                       self.lankUp()
                  }
              })
          }
    
    func loadObjectIds() {
        self.objectIds = [String]()
        for user in users {
            let objectId = user.objectId
            self.objectIds.append(objectId)
        }
  //      print(self.objectIds, "ppppppppppp")
        allLabel.text = String(objectIds.count)

    }
    
    func loadUsers() {
        guard let currentUser = selectedUser else {
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
           let query = NCMBUser.query()
           //配列をlikeSumの降順にする
           query?.order(byDescending: "likeSum")
           query?.findObjectsInBackground({ (result, error) in
               if error != nil {
                   //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.error, delay: 1.0)
                           }
               } else {
                   self.users = [User]()
                   
                   for userObject in result as! [NCMBUser] {
                       // ユーザー情報をUserクラスにセット
                       let userModel = User(objectId: userObject.objectId, userName: userObject.userName)
                       userModel.displayName = userObject.object(forKey: "displayName") as? String
                       userModel.likeSum = userObject.object(forKey: "likeSum") as? Int
                       // 配列に加える
                    if self.blockUserIdArray.firstIndex(of: self.selectedUser.objectId) == nil{
                       self.users.append(userModel)
                    }
                   }
         //          print(self.users, "77777777777")
                   self.loadObjectIds()
               }
           })
       }
    
    func loadFollowingInfo() {
        // フォロー中
        let followingQuery = NCMBQuery(className: "Follow")
        followingQuery?.includeKey("user")
        followingQuery?.whereKey("user", equalTo: selectedUser)
        followingQuery?.countObjectsInBackground({ (count, error) in
            if error != nil {
               // SVProgressHUD.showError(withStatus: error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.error, delay: 1.0)
                           }
            } else {
                // 非同期通信後のUIの更新はメインスレッドで
                DispatchQueue.main.async {
                    self.followingCountLabel.text = String(count)
                }
            }
        })
        
        // フォロワー
        let followerQuery = NCMBQuery(className: "Follow")
        followerQuery?.includeKey("following")
        followerQuery?.whereKey("following", equalTo: selectedUser)
        followerQuery?.countObjectsInBackground({ (count, error) in
            if error != nil {
               // SVProgressHUD.showError(withStatus: error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.error, delay: 1.0)
                           }
            } else {
      //          print(count, "jjjjjjjjjjjjjjjjjjjjjjj")
                DispatchQueue.main.async {
                    // 非同期通信後のUIの更新はメインスレッドで
                    self.followerCountLabel.text = String(count)
                }
            }
        })
    }
    
    func saveLikeSum() {
   //     print(sum, "444444444444")
        let user = selectedUser
        user?.setObject(likeSum(), forKey: "likeSum")
        user?.saveInBackground({ (error) in
      //      print(self.likeSum(), "iiiiiiiiiR")
            self.likeSumLabel.text = String(self.likeSum())
            if error != nil {
    //            print("likeSum don't saved")
            }
        })
    }
    
    @IBAction func follow() {
        // すでにフォロー状態だった場合、フォロー解除
        if let info = followingInfo {
            info.deleteInBackground({ (error) in
                if error != nil {
                   // SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                   HUD.flash(.error, delay: 1.0)
                               }
                } else {
                    DispatchQueue.main.async {
                        self.followButton.setTitle("フォローする", for: .normal)
                        self.followButton.setTitleColor(UIColor.blue, for: .normal)
                        self.followButton.borderColor = UIColor.blue
                    }
                    
                    // フォロー状態の再読込
                    self.loadFollowingStatus()
                    
                    // フォロー数の再読込
                    self.loadFollowingInfo()
                }
            })
        } else {
            let displayName = selectedUser.object(forKey: "displayName") as? String
            let message = displayName! + "をフォローしますか？"
            let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                let object = NCMBObject(className: "Follow")
                if let currentUser = NCMBUser.current() {
                    object?.setObject(currentUser, forKey: "user")
                    object?.setObject(self.selectedUser, forKey: "following")
                    object?.saveInBackground({ (error) in
                        if error != nil {
                          //  SVProgressHUD.showError(withStatus: error!.localizedDescription)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                           HUD.flash(.error, delay: 1.0)
                                       }
                        } else {
                            self.loadFollowingStatus()
                        }
                    })
                } else {
                    // currentUserが空(nil)だったらログイン画面へ
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    // ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
            }
            let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            alert.popoverPresentationController?.sourceView = self.view
            let screenSize = UIScreen.main.bounds
            // ここで表示位置を調整
            // xは画面中央、yは画面下部になる様に指定
            alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func showMenu() {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
                      //SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.success, delay: 1.0)
                           }
                  }
           let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
               alertController.dismiss(animated: true, completion: nil)
           }

           alertController.addAction(reportAction)
           alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func getBlockUser() {

            let query = NCMBQuery(className: "Block")

            //includeKeyでBlockの子クラスである会員情報を持ってきている
            query?.includeKey("user")
            query?.whereKey("user", equalTo: NCMBUser.current())
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    //エラーの処理
                } else {
                    //ブロックされたユーザーのIDが含まれる + removeall()は初期化していて、データの重複を防いでいる
                    self.blockUserIdArray.removeAll()
                    for blockObject in result as! [NCMBObject] {
                        //この部分で①の配列にブロックユーザー情報が格納
    self.blockUserIdArray.append(blockObject.object(forKey: "blockUserId") as! String)

                    }

                }
            })
            loadUsers()
        }
    
   
    
    
//        if selectedUser.objectId != NCMBUser.current()?.objectId {
//            let reportButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "報告") { (action, index) -> Void in
//                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//                let reportAction = UIAlertAction(title: "報告する", style: .destructive ){ (action) in
//                  //  SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
//                    let object = NCMBObject(className: "Report") //新たにクラス作る
//                    object?.setObject(self.selectedUser.objectId, forKey: "reportId")
//                    object?.setObject(NCMBUser.current(), forKey: "user")
//                    object?.saveInBackground({ (error) in
//                        if error != nil {
//                     //       SVProgressHUD.showError(withStatus: "エラーです")
//                        } else {
//                     //       SVProgressHUD.dismiss(withDelay: 2)
//                            tableView.deselectRow(at: indexPath, animated: true)
//                        }
//                    })
//                }
//                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
//                    alertController.dismiss(animated: true, completion: nil)
//                }
//
//                alertController.addAction(reportAction)
//                alertController.addAction(cancelAction)
//                self.present(alertController, animated: true, completion: nil)
//                tableView.isEditing = false
//
//            }
//            reportButton.backgroundColor = UIColor.red
//            let blockButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "ブロック") { (action, index) -> Void in
//                //self.comments.remove(at: indexPath.row)
//                //tableView.deleteRows(at: [indexPath], with: .fade)
//                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
//                let blockAction = UIAlertAction(title: "ブロックする", style: .destructive) { (action) in
//            //        SVProgressHUD.showSuccess(withStatus: "このユーザーをブロックしました。")
//
//                    let object = NCMBObject(className: "Block") //新たにクラス作る
//                    object?.setObject(self.selectedUser.objectId, forKey: "blockUserID")
//                    object?.setObject(NCMBUser.current(), forKey: "user")
//                    object?.saveInBackground({ (error) in
//                        if error != nil {
//               //             SVProgressHUD.showError(withStatus: "エラーです")
//                        } else {
//                 //           SVProgressHUD.dismiss(withDelay: 2)
//                            tableView.deselectRow(at: indexPath, animated: true)
//
//                     //ここで③を読み込んでいる
//                    self.getBlockUser()
//                        }
//                    })
//
//                }
//                let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
//                    alertController.dismiss(animated: true, completion: nil)
//                }
//
//                alertController.addAction(blockAction)
//                alertController.addAction(cancelAction)
//                self.present(alertController, animated: true, completion: nil)
//                tableView.isEditing = false
//            }
//            blockButton.backgroundColor = UIColor.blue
//            return[blockButton,reportButton]
//        } else {
//            let deleteButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "削除") { (action, index) -> Void in
//                let query = NCMBQuery(className: "取り出したいクラスの名前")
//                query?.getObjectInBackground(withId: self.selectedUser.objectId, block: { (post, error) in
//                    if error != nil {
//                  //      SVProgressHUD.showError(withStatus: "エラーです")
//                  //      SVProgressHUD.dismiss(withDelay: 2)
//                    } else {
//                        DispatchQueue.main.async {
//                            let alertController = UIAlertController(title: "投稿を削除しますか？", message: "削除します", preferredStyle: .alert)
//                            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
//                                alertController.dismiss(animated: true, completion: nil)
//                            }
//                            let deleteAction = UIAlertAction(title: "OK", style: .default) { (acrion) in
//                                post?.deleteInBackground({ (error) in
//                                    if error != nil {
//                            //            SVProgressHUD.showError(withStatus: "エラーです")
//                            //            SVProgressHUD.dismiss(withDelay: 2)
//                                    } else {
//                                        tableView.deselectRow(at: indexPath, animated: true)
//                                        self.loadUsers()
//
//                                    }
//                                })
//                            }
//                            alertController.addAction(cancelAction)
//                            alertController.addAction(deleteAction)
//                            self.present(alertController,animated: true,completion: nil)
//                            tableView.isEditing = false
//                        }
//
//                    }
//                })
//            }
//            deleteButton.backgroundColor = UIColor.red //色変更
//
//        }
//    }
}

