//
//  CommentViewController.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/05.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NCMB
//import SVProgressHUD
import PKHUD
import Kingfisher
import SwiftDate //日時を簡単に扱える

class CommentViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CommentTableViewCellDelegate {
    
    
  //  var selectedComment = Comment?
    
    var postId: String!

    var comments = [Comment]()
    
    //var block = [Block]()
    
    var posts = [Post]()
    
    var segmentFlag = 0
    
    var users = [NCMBUser]()
    
  //  var objectIds = [String]()
    
    var followings = [NCMBUser]()
    
   var followingUserIds = [String]()
    
    var postImageUrl: URL?
    
    var postText: String?
    
    var blockUserIdArray = [String]()
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var postTextView: UITextView?

    @IBOutlet var commentTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentTableView.delegate = self
        commentTableView.dataSource = self
        
        //UInibを使ってxibの取得　cellの再利用id
        let nib = UINib(nibName: "CommentTableViewCell", bundle: Bundle.main)
        commentTableView.register(nib, forCellReuseIdentifier: "CommentCell")
        
        commentTableView.tableFooterView = UIView() //余計な線を消す
        
        //commentTableView.rowHeight = 226
        
        //引っ張って更新
        setRefreshControl()

        //CommentViewController.estimateRowHeight = 80
               
        //commentTableView.rowHeight = UITableViewAutomaticDimention
        
        
        
       }
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        getBlockUser()
        loadPosts()
  //      loadUsers()
//        loadFollowingUserIds()
        if postImageUrl != nil {
        postImageView.kf.setImage(with: postImageUrl)
      //      postImageView.contentMode = .scaleAspectFill
    //    print(postImageUrl, "gggggggggggggggg")
        }else {
            postImageView.image = UIImage(named: "無題18_20200804110409.JPG")
            let screenSize: CGRect = UIScreen.main.bounds
            postImageView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 0)
        }
        postTextView!.text = postText
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
              let showUserViewController = segue.destination as! ShowUserViewController
              let selectedIndex = commentTableView.indexPathForSelectedRow!
        showUserViewController.selectedUser = users[selectedIndex.row]
          }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//           if followingUserIds.contains(users[indexPath.row].objectId) == true {
//               return 0
//           } else {
//               return 100
//           }
//       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cellの再利用
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentTableViewCell
        //cellの内容
        cell.delegate = self
        cell.tag = indexPath.row
        
        let user = comments[indexPath.row].user
        cell.userNameLabel.text = user.displayName
        
        //画像ファイルを発行したときにサーバーからURLが発行されており、そのURL
        let userImageUrl = URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + user.objectId)
      // kf(kingfisher)が画像を入れている、なかった場合は違う画像を表示してくれる
        cell.userImageView.kf.setImage(with: userImageUrl)
        
        cell.commentTextView.text = comments[indexPath.row].text
        
        // Likeによってハートの表示を変える
        if comments[indexPath.row].isLiked == true {
            cell.likeButton.setImage(UIImage(named: "icons8-ハート-48.png"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "icons8-いいね-50.png"), for: .normal)
        }
        
        // Likeの数
        cell.likeCountLabel!.text = "\(comments[indexPath.row].likeCount)件"
        
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        let dateFormatter = DateFormatter()   //DateとStringの相互変換いてくれる
        /// フォーマット設定
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // タイムゾーン設定（端末設定によらず固定にしたい場合）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        // 変換
        let creatTime = dateFormatter.string(from: comments[indexPath.row].createDate)
        
        cell.timestampLabel!.text = creatTime
        
        // Followボタンを機能させる
        cell.tag = indexPath.row
        cell.delegate = self
        
//       if followingUserIds.contains(users[indexPath.row].objectId) == true {
//            cell.followButton.isHidden = true
//        } else {
//            cell.followButton.isHidden = false
//        }
        
        return cell
    }
    
   
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toUser2", sender: nil)
              // 選択状態の解除
              tableView.deselectRow(at: indexPath, animated: true)
          }
    
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton) {
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
           
           if comments[tableViewCell.tag].isLiked == false || comments[tableViewCell.tag].isLiked == nil {
               let query = NCMBQuery(className: "Comment")
               query?.getObjectInBackground(withId: comments[tableViewCell.tag].objectId, block: { (comment, error) in
                   //自分というオブジェクトがlikeUserにあるか確認
                   //なかった場合はaddUniqueObject自分というオブジェクトが１個だけ追加
                   comment?.addUniqueObject(currentUser.objectId, forKey: "likeUser")
                   comment?.saveEventually({ (rror) in
                       if error != nil {
                           // SVProgressHUD.show(withStatus: error!.localizedDescription)
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        HUD.flash(.error, delay: 1.0)
                    }
                       } else {
                           self.getBlockUser()
                       
                       }
                   })
               })
           } else {
               //メニューボタンを押すとアラートシートを出す
               let query = NCMBQuery(className: "Comment")
               query?.getObjectInBackground(withId: comments[tableViewCell.tag].objectId, block: { (comment, error) in
                   if error != nil {
                       //SVProgressHUD.show(withStatus: error!.localizedDescription)
         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                       HUD.flash(.error, delay: 1.0)
                   }
                   } else {
                       //自分のオブジェクトがあった場合は、removeObject前のものを削除していれる
                       comment?.removeObjects(in: [NCMBUser.current()?.objectId], forKey: "likeUser")
                       comment?.saveEventually({ (error) in
                           if error != nil {
                               // SVProgressHUD.show(withStatus: error?.localizedDescription)
       DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                      HUD.flash(.error, delay: 1.0)
                  }
                           } else {
                               self.getBlockUser()
                           }
                       })
                   }
               })
           }
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
                       self.blockUserIdArray.append(blockObject.object(forKey: "blockUserID") as! String)
                   }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                       switch self.segmentFlag {
                       case 0:
                        self.loadComments()
                       case 1:
                        self.loadComments2()
                       default:
                        self.loadComments()
                       }
                   }
               }
           })
       }
    
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
           let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
           let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
               //SVProgressHUD.show()
           DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
             //  HUD.show(.progress)
            }
               let query = NCMBQuery(className: "Comment")
               query?.getObjectInBackground(withId: self.comments[tableViewCell.tag].objectId, block: { (comment, error) in
                   if error != nil {
                       // SVProgressHUD.showError(withStatus: error!.localizedDescription)
       DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                     HUD.flash(.error, delay: 1.0)
                 }
                   } else {
                       // 取得した投稿オブジェクトを削除
                       comment?.deleteInBackground({ (error) in
                           if error != nil {
                               // SVProgressHUD.showError(withStatus: error!.localizedDescription)
      DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    HUD.flash(.error, delay: 1.0)
                }
                           } else {
                               // 再読込
                               self.getBlockUser()
                               // SVProgressHUD.dismiss()
        
                           }
                       })
                   }
               })
           }
           let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
               //SVProgressHUD.showSuccess(withStatus: "この投稿を報告しました。ご協力ありがとうございました。")
  DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                 HUD.flash(.success, delay: 1.0)
             }
            let object = NCMBObject(className: "Report") //新たにクラス作る
            object?.setObject(self.comments[tableViewCell.tag].user.objectId, forKey: "reportId")
            object?.setObject(NCMBUser.current(), forKey: "user")
            object?.saveInBackground({ (error) in
                if error != nil {
                    //  SVProgressHUD.showError(withStatus: "エラーです")
     DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                   HUD.flash(.error, delay: 1.0)
               }
                } else {
                    //   SVProgressHUD.dismiss(withDelay: 2)
 
                    //     tableView.deselectRow(at: indexPath, animated: true)
                }
            })
           }
        
          let blockAction = UIAlertAction(title: "ブロックする", style: .destructive) { (action) in
          //    SVProgressHUD.showSuccess(withStatus: "このユーザーをブロックしました。")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                  HUD.flash(.success, delay: 1.0)
              }
        //    block(selectedUser: NCMBUser)
          let object = NCMBObject(className: "Block") //新たにクラス作る
          object?.setObject(self.comments[tableViewCell.tag].user.objectId, forKey: "blockUserID")
          object?.setObject(NCMBUser.current(), forKey: "user")
          object?.saveInBackground({ (error) in
              if error != nil {
                  //    SVProgressHUD.showError(withStatus: "エラーです")
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                   HUD.flash(.error, delay: 1.0)
               }
              } else {
                  //          SVProgressHUD.dismiss(withDelay: 2)
  
                  //          tableView.deselectRow(at: indexPath, animated: true)
                  
                  //ここで③を読み込んでいる
                  self.getBlockUser()
              }
              }
          )}
        
           let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
               alertController.dismiss(animated: true, completion: nil)
           }
           if comments[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
               // 自分の投稿なので、削除ボタンを出す
               alertController.addAction(deleteAction)
           } else {
               // 他人の投稿なので、報告ボタンを出す
               alertController.addAction(reportAction)
            alertController.addAction(blockAction)
           }
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alertController.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        self.present(alertController, animated: true, completion: nil)
    }
    
//    func block(selectedUser: NCMBUser) {
//                    let object = NCMBObject(className: "Block")
//                    if let currentUser = NCMBUser.current() {
//                        object?.setObject(currentUser, forKey: "user")
//                        object?.setObject(selectedUser, forKey: "blockUser")
//                        object?.saveInBackground({ (error) in
//                            if error != nil {
//                                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
//                            } else {
//                                self.loadUsers()
//                            }
//                        })
//                    } else {
//                        // currentUserが空(nil)だったらログイン画面へ
//                        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
//                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
//                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
//
//                        // ログイン状態の保持
//                        let ud = UserDefaults.standard
//                        ud.set(false, forKey: "isLogin")
//                        ud.synchronize()
//                    }
//                }
    
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
//                      if let likes = likeUser {
//                          post.likeCount = likes.count
//                      }
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
        query?.whereKey("postId", equalTo: postId)
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
                     if self.blockUserIdArray.firstIndex(of: comment.user.objectId) == nil{
                         self.comments.append(comment)
                        self.users.append(user)
                     }
                    }
                }
                // テーブルをリロード
                self.commentTableView.reloadData()
            }
        })
    }
    
    func loadComments2() {
           
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
           query?.order(byDescending: "likeUser")
           query?.whereKey("postId", equalTo: postId)
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
                       if self.blockUserIdArray.firstIndex(of: comment.user.objectId) == nil{
                           self.comments.append(comment)
                        self.users.append(user)
                       }
                      
                       }
                   }
                // テーブルをリロード
                self.commentTableView.reloadData()
            }
           })
       }
    
     func setRefreshControl() {
           let refreshControl = UIRefreshControl()
           refreshControl.addTarget(self, action: #selector(reloadComment(refreshControl:)), for: .valueChanged)
           commentTableView.addSubview(refreshControl)
       }
       
       @objc func reloadComment(refreshControl: UIRefreshControl) {
           refreshControl.beginRefreshing()
       //    self.loadFollowingUsers()
           // 更新が早すぎるので2秒遅延させる
           DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
               refreshControl.endRefreshing()
           }
       }
    
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
              let displayName = users[tableViewCell.tag].object(forKey: "displayName") as? String
              let message = displayName! + "をフォローしますか？"
              let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
              let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                  self.follow(selectedUser: self.users[tableViewCell.tag])
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
    
    func follow(selectedUser: NCMBUser) {
        let object = NCMBObject(className: "Follow")
        if let currentUser = NCMBUser.current() {
            object?.setObject(currentUser, forKey: "user")
            object?.setObject(selectedUser, forKey: "following")
            object?.saveInBackground({ (error) in
                if error != nil {
                    //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        HUD.flash(.error, delay: 1.0)
                    }
                    
                } else {
                //    self.loadUsers()
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
    
//    func loadUsers() {
//        let query = NCMBUser.query()
//        // 自分を除外
//        query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
//
//        // 退会済みアカウントを除外
//        query?.whereKey("active", notEqualTo: false)
//
//        query?.findObjectsInBackground({ (result, error) in
//            if error != nil {
//                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                    HUD.flash(.error, delay: 1.0)
//                }
//            } else {
//                // 取得したユーザーを格納
//                self.users = result as! [NCMBUser]
//
//                //           self.loadFollowingUserIds()
//            }
//        })
//    }
    
    
    
//    func loadFollowingUserIds() {
//        let query = NCMBQuery(className: "Follow")
//        query?.includeKey("user")
//        query?.includeKey("following")
//        query?.whereKey("user", equalTo: NCMBUser.current())

//        query?.findObjectsInBackground({ (result, error) in
//            if error != nil {
                // SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                self.followingUserIds = [String]()
//               for following in result as! [NCMBObject] {
//                  let user = following.object(forKey: "following") as! NCMBUser
//                    print(self.followingUserIds, "fffffffffffffff")
//                    self.followingUserIds.append(user.objectId)
//                }
                
//                self.commentTableView.reloadData()
//            }
//        })
//        self.commentTableView.reloadData()
        
//    }
    
//     func loadFollowingUsers() {
//        // フォロー中の人だけ持ってくる
//       let query = NCMBQuery(className: "Follow")
//      query?.includeKey("user")
//     query?.includeKey("following")
//     query?.whereKey("user", equalTo: NCMBUser.current())
//    query?.findObjectsInBackground({ (result, error) in
//       if error != nil {
//         //SVProgressHUD.showError(withStatus: error!.localizedDescription)
//    } else {
//      self.followings = [NCMBUser]()
//    for following in result as! [NCMBObject] {
//      self.followings.append(following.object(forKey: "following") as! NCMBUser)
//    }
//    print(result)
//    self.followings.append(NCMBUser.current())
    
//     self.loadComments()
//    }
//    })
//    }
    
    @IBAction func addComment() {
        let alert = UIAlertController(title: "大喜る", message: "お答えください", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            alert.dismiss(animated: true, completion: nil)
           DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
             //  HUD.show(.progress)
            }
            let object = NCMBObject(className: "Comment")
            object?.setObject(self.postId, forKey: "postId")
            object?.setObject(NCMBUser.current(), forKey: "user")
            object?.setObject(alert.textFields?.first?.text, forKey: "text")
            object?.saveInBackground({ (error) in
                if error != nil {
                   // SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                   HUD.flash(.error, delay: 1.0)
                               }
                } else {
                   // SVProgressHUD.dismiss()
                    self.getBlockUser()
                  
                }
            })
        }

        alert.addAction(cancelAction)
        alert.addAction(okAction)
        alert.addTextField { (textField) in
            textField.placeholder = "ここにコメントを入力"
        }
        alert.popoverPresentationController?.sourceView = self.view
        let screenSize = UIScreen.main.bounds
        // ここで表示位置を調整
        // xは画面中央、yは画面下部になる様に指定
        alert.popoverPresentationController?.sourceRect = CGRect(x: screenSize.size.width/2, y: screenSize.size.height, width: 0, height: 0)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:comments.removeAll()
        self.segmentFlag = 0
        self.getBlockUser()
            
        case 1:comments.removeAll()
        self.segmentFlag = 1
        self.getBlockUser()
        default:break
        }
        commentTableView.reloadData()
    }
    
}
