//
//  ViewController1.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/03.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher //timelinの画像をひっ同期で読み込む
//import SVProgressHUD //ロード用
import PKHUD
import SwiftDate //日時を簡単に扱える



class ViewController1: UIViewController, UITableViewDelegate, UITableViewDataSource, TimelineTableViewCellDelegate {
    
    var selectedPost: Post?
    
    //var block = [Block]()
    
    var posts = [Post]()
    
    var segmentFlag = 0
    
    var comments = [Comment]()
    
    var followings = [NCMBUser]()
    
    var users = [NCMBUser]()
    
    var postId = String?.self
    
    var blockUserIdArray = [String]()
    
    @IBOutlet var timelineTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        getBlockUser()
       // loadComments()
        //UInibを使ってxibの取得　cellの再利用id
        let nib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.main)
        timelineTableView.register(nib, forCellReuseIdentifier: "Cell")
        //余計な線を消す
        timelineTableView.tableFooterView = UIView()
        //引っ張って更新
        setRefreshControl()
        // フォロー中のユーザーを取得する。その後にフォロー中のユーザーの投稿のみ読み込み
        loadFollowingUsers()
        
        let button = UIButton()
        button.setTitle(" Top", for: .normal)
        button.titleLabel?.text = "大喜る"
        button.frame.size = CGSize(width: 60, height: 30)
        button.setImage(UIImage(named: "無題18_20200804110409.JPG"), for: UIControl.State.normal)
        button.addTarget(self, action: #selector(ViewController1.tapEvent(_:)), for: .touchUpInside)
        let titleView = UIView()
        titleView.backgroundColor = UIColor.systemBackground
        titleView.layer.cornerRadius = 0.5
        //十分な大きさを確保
        titleView.frame.size = CGSize(width: 120, height: 44)
        titleView.addSubview(button)
        button.frame.origin = CGPoint(x: titleView.frame.size.width * 0.5 - button.frame.size.width * 0.5,
                                      y: titleView.frame.size.height * 0.5 - button.frame.size.height * 0.5)
        self.navigationItem.titleView = titleView
    }
    
    @objc func tapEvent(_ tap: UITapGestureRecognizer) {
   //     print("タップ")
        timelineTableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBlockUser()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            let commentViewController = segue.destination as! CommentViewController
            commentViewController.postId = selectedPost?.objectId
            if selectedPost!.imageUrl != nil {
                commentViewController.postImageUrl = URL(string: selectedPost!.imageUrl!)
                //   print(selectedPost?.imageUrl, "99999999999999999999" )
            }
            commentViewController.postText = selectedPost?.text
        } else {
            //    print("else")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if posts[indexPath.row].imageUrl != nil && posts[indexPath.row].text != nil {
            return 551
        } else if posts[indexPath.row].imageUrl == nil && posts[indexPath.row].text != nil {
            return 213
        } else if posts[indexPath.row].imageUrl != nil && posts[indexPath.row].text!.count == 0 {
            return 350
        }
        return 551
    }
    
    func scrollToTop() {
        let indexPath = IndexPath(row: 0, section: 0)
        timelineTableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cellの再利用
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! TimelineTableViewCell
        //cellの内容
        cell.delegate = self
        cell.tag = indexPath.row
        
        let user = posts[indexPath.row].user
        cell.userNameLabel.text = user.displayName
        
        //画像ファイルを発行したときにサーバーからURLが発行されており、そのURL
        let userImageUrl = URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + user.objectId)
        //kf(kingfisher)が画像を入れている、なかった場合は違う画像を表示してくれる
        cell.userImageView.kf.setImage(with: userImageUrl)
        
        if posts[indexPath.row].text != nil {
            let text = String(posts[indexPath.row].text!)
            cell.commentTextView.text = posts[indexPath.row].text
        } else {
            cell.textLabel?.isHidden = true
        }
        
        if  posts[indexPath.row].imageUrl != nil {
            let imageUrl = URL(string:( posts[indexPath.row].imageUrl)!)
            //    print(imageUrl, "NNNNNNNNN")
            //userの画像をkfで表示してる
            cell.postImageView.kf.setImage(with: imageUrl)
        } else {
            cell.postImageView.isHidden = true
        }
        
        // commentsの数
        cell.commentsCountLabel.text = "\(posts[indexPath.row].commentsCount)件"
        
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        let dateFormatter = DateFormatter()   //DateとStringの相互変換いてくれる
        /// フォーマット設定
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        
        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        // タイムゾーン設定（端末設定によらず固定にしたい場合）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")
        
        // 変換
        let creatTime = dateFormatter.string(from: posts[indexPath.row].createDate)
        
        cell.timestampLabel.text = creatTime
        
        return cell
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
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    switch self.segmentFlag {
                    case 0:
                        self.loadTimeline2()
                    case 1:
                        self.loadTimeline()
                    default:
                        self.loadTimeline()
                    }
                }
            }
        })
    }
    
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
           DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
          //    HUD.show(.progress)
           }
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    // SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                   HUD.flash(.error, delay: 1.0)
                               }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                   HUD.flash(.error, delay: 1.0)
                               }
                } else {
                    // 取得した投稿オブジェクトを削除
                    post?.deleteInBackground({ (error) in
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
            object?.setObject(self.posts[tableViewCell.tag].user.objectId, forKey: "reportId")
            object?.setObject(NCMBUser.current(), forKey: "user")
            object?.saveInBackground({ (error) in
                if error != nil {
                    //  SVProgressHUD.showError(withStatus: "エラーです")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                   HUD.flash(.error, delay: 1.0)
                               }
                } else {
                   
                    //     tableView.deselectRow(at: indexPath, animated: true)
                }
            })
        }
        let blockAction = UIAlertAction(title: "ブロックする", style: .destructive) { (action) in
                   //    SVProgressHUD.showSuccess(withStatus: "このユーザーをブロックしました。")
                   DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                       HUD.flash(.success, delay: 1.0)
                   }
                   
                   let object = NCMBObject(className: "Block") //新たにクラス作る
                   object?.setObject(self.posts[tableViewCell.tag].user.objectId, forKey: "blockUserID")
               object?.setObject(NCMBUser.current(), forKey: "user")
               object?.saveInBackground({ (error) in
                   if error != nil {
                       //    SVProgressHUD.showError(withStatus: "エラーです")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                           HUD.flash(.error, delay: 1.0)
                       }
                   } else {
                       //          SVProgressHUD.dismiss(withDelay: 2)
            //
                       //          tableView.deselectRow(at: indexPath, animated: true)
                       
                       //ここで③を読み込んでいる
                       self.getBlockUser()
                   }
                   }
               )}
//        let blockAction = UIAlertAction(title: "ブロックする", style: .destructive) { (action) in
//            //    SVProgressHUD.showSuccess(withStatus: "このユーザーをブロックしました。")
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                           HUD.flash(.success, delay: 1.0)
//                       }
//            self.block(selectedUser: self.users[tableViewCell.tag])
//            let object = NCMBObject(className: "Block") //新たにクラス作る
//            object?.setObject(self.posts[tableViewCell.tag].user.objectId, forKey: "blockUserID")
//            object?.setObject(NCMBUser.current(), forKey: "user")
//            object?.saveInBackground({ (error) in
//                if error != nil {
//                    //    SVProgressHUD.showError(withStatus: "エラーです")
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                   HUD.flash(.error, delay: 1.0)
//                               }
//                } else {
//
//                    //          tableView.deselectRow(at: indexPath, animated: true)
//
//                    //ここで③を読み込んでいる
//                    self.getBlockUser()
//                }
//                }
//            )}
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        if posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
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
//        let object = NCMBObject(className: "Block")
//        if let currentUser = NCMBUser.current() {
//            object?.setObject(currentUser, forKey: "user")
//            object?.setObject(selectedUser, forKey: "blockUser")
//            object?.saveInBackground({ (error) in
//                if error != nil {
//                    //SVProgressHUD.showError(withStatus: error!.localizedDescription)
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                                   HUD.flash(.error, delay: 1.0)
//                               }
//                } else {
//                }
//            })
//        } else {
//            // currentUserが空(nil)だったらログイン画面へ
//            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
//            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
//            UIApplication.shared.keyWindow?.rootViewController = rootViewController
//
//            // ログイン状態の保持
//            let ud = UserDefaults.standard
//            ud.set(false, forKey: "isLogin")
//            ud.synchronize()
//        }
//    }
    
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        // 選ばれた投稿を一時的に格納
        selectedPost = posts[tableViewCell.tag]
        
        // 遷移させる(このとき、prepareForSegue関数で値を渡す)
        
        self.performSegue(withIdentifier: "toComments", sender: nil)
        
    }
    
    
    
    
    
    
    func loadTimeline() {
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
        
        let query = NCMBQuery(className: "Post")
        
        // createDateの降順(投稿された順番)
        query?.order(byDescending: "createDate")
        
        // 投稿したユーザーの情報も同時取得
        query?.includeKey("user")
        
        
        // フォロー中の人 + 自分の投稿だけ持ってくる
        query?.whereKey("user", containedIn: followings)
        
        
        // オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.error, delay: 1.0)
                           }
                //localizedDescriptionエラー内容を地域の言葉で表示してくれる
            } else {
                // 読み込んだときに投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool != false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        // 投稿の情報を取得
                        let imageUrl = postObject.object(forKey: "imageUrl") as? String
                        let text = postObject.object(forKey: "text") as! String
                        
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = Post(objectId: postObject.objectId, user: userModel, createDate: postObject.createDate)
                        post.imageUrl = postObject.object(forKey: "imageUrl") as? String
                        post.text = postObject.object(forKey: "text") as? String
                        post.commentsCount = self.comments.count
                        
                        // 配列に加える
                        if self.blockUserIdArray.firstIndex(of: post.user.objectId) == nil{
                            self.posts.append(post)
                        }
                        
                        
                        //           print(self.posts, "111111111111111")
                    }
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.timelineTableView.reloadData()
                
            }
        })
    }
    
    func loadTimeline2() {
        
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
        
        let query = NCMBQuery(className: "Post")
        
        // createDateの降順(投稿された順番)
        query?.order(byDescending: "createDate")
        
        // 投稿したユーザーの情報も同時取得
        query?.includeKey("user")
        
        // オブジェクトの取得
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.error, delay: 1.0)
                           }
                //localizedDescriptionエラー内容を地域の言葉で表示してくれる
            } else {
                // 読み込んだときに投稿を格納しておく配列を初期化(これをしないとreload時にappendで二重に追加されてしまう)
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool != false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        // 投稿の情報を取得
                        let imageUrl = postObject.object(forKey: "imageUrl") as? String
                        let text = postObject.object(forKey: "text") as! String
                        
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = Post(objectId: postObject.objectId, user: userModel, createDate: postObject.createDate)
                        post.imageUrl = postObject.object(forKey: "imageUrl") as? String
                        post.text = postObject.object(forKey: "text") as? String
                        post.commentsCount = self.comments.count
                        
                        // 配列に加える
                        if self.blockUserIdArray.firstIndex(of: post.user.objectId) == nil{
                            self.posts.append(post)
                        }
                        
                        
                        
                        //      print(self.posts, "22222222222222222")
                    }
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.timelineTableView.reloadData()
            }
        })
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        timelineTableView.addSubview(refreshControl)
    }
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.loadFollowingUsers()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    
    func loadFollowingUsers() {
        // フォロー中の人だけ持ってくる
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
                self.followings = [NCMBUser]()
                for following in result as! [NCMBObject] {
                    self.followings.append(following.object(forKey: "following") as! NCMBUser)
                }
                //    print(result)
                self.getBlockUser()
                //                self.followings.append(NCMBUser.current())
                
                
                
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
                        
                        self.comments.append(comment)
                    }
                }
            }
        })
    }
    
    @IBAction func toThisWeek() {
        self.performSegue(withIdentifier: "toThisWeek", sender: nil)
    }
    
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:posts.removeAll()
        self.segmentFlag = 0
        self.getBlockUser()
            
        case 1:posts.removeAll()
        self.segmentFlag = 1
        self.getBlockUser()
            
        default:break
        }
        timelineTableView.reloadData()
    }
    
}
