//
//  SearchViewController.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/05.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NCMB
//import SVProgressHUD
import PKHUD


class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate, SearchUserTableViewCellDelegate {

    var users = [NCMBUser]()
    
//    var comments = [Comment]()
    
//    var sum:Int = 0
    
    var followingUserIds = [String]()
    
    var searchBar: UISearchBar! //上に表示する検索バーのこと
    
    
    
    @IBOutlet var searchUserTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setSearchBar()
        
        searchUserTableView.delegate = self
        searchUserTableView.dataSource = self
        
        //カスタムセルの登録
        let nib = UINib(nibName: "SearchUserTableViewCell", bundle: Bundle.main)
        searchUserTableView.register(nib, forCellReuseIdentifier: "SearchCell")
        
        //余計な線を消す
        searchUserTableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadUsers(searchText: nil)
     //   print(users)
    }
    
    

       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           let showUserViewController = segue.destination as! ShowUserViewController
           let selectedIndex = searchUserTableView.indexPathForSelectedRow!
           showUserViewController.selectedUser = users[selectedIndex.row]
       }

       func setSearchBar() {
           // NavigationBarにSearchBarをセット
           if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
               let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
               searchBar.delegate = self
               searchBar.placeholder = "ユーザーを検索"
               searchBar.autocapitalizationType = UITextAutocapitalizationType.none
               navigationItem.titleView = searchBar
               navigationItem.titleView?.frame = searchBar.frame
               self.searchBar = searchBar
           }
       }
       
       func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
           searchBar.setShowsCancelButton(true, animated: true)
           return true
       }
       
       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           loadUsers(searchText: nil)
           searchBar.showsCancelButton = false
           searchBar.resignFirstResponder()
       }
       
       func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
           loadUsers(searchText: searchBar.text)
       }
       
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return users.count
       }
       
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if followingUserIds.contains(users[indexPath.row].objectId) == true {
            return 0
        } else {
            return 70
        }
    }
    
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchUserTableViewCell
           
        let userImageUrl = URL(string:"https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + users[indexPath.row].objectId)
        cell.userImageView.kf.setImage(with: userImageUrl)
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
        cell.userImageView.layer.masksToBounds = true
        cell.userImageView.contentMode = .scaleAspectFill
        cell.followButton.layer.borderWidth = 0.5                                              // 枠線の幅
        cell.followButton.layer.borderColor = UIColor.white.cgColor                            // 枠線の色
        cell.followButton.layer.cornerRadius = 5.0
        
        cell.userNameLabel.text = users[indexPath.row].object(forKey: "displayName") as? String
        
        
        // Followボタンを機能させる
        cell.tag = indexPath.row
        cell.delegate = self
        
        if followingUserIds.contains(users[indexPath.row].objectId) == true {
            cell.followButton.isHidden = true
        } else {
            cell.followButton.isHidden = false
        }
        
//        func lankUp() {
//            switch likeSum()  {
//                case 0..<10:
//                    cell.lankLabel.text = "庶民"
//                case 10..<20:
//                 cell.lankLabel.text = "1級"
//                case 20..<30:
//                 cell.lankLabel.text = "2級"
//                case 30..<40:
//                 cell.lankLabel.text = "3級"
//                case 40..<50:
//                 cell.lankLabel.text = "4級"
//                case 50..<60:
//                 cell.lankLabel.text = "5級"
//                case 60..<70:
//                 cell.lankLabel.text = "6級"
//                case 70..<80:
//                 cell.lankLabel.text = "7級"
//                case 80..<90:
//                 cell.lankLabel.text = "8級"
//                case 90..<100:
//                 cell.lankLabel.text = "9級"
//                default:
//                  cell.lankLabel.text = "殿堂入り"
//              }
//          }
//
//        func likeSum() -> Int {
//            sum = 0
//            for i in 0 ..< comments.count {
//
//                sum += comments[i].likeCount
//            }
//            print(sum, "ddddddddddddd")
//            return sum
//
//
//        }
        
        
        return cell
    }
    
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           self.performSegue(withIdentifier: "toUser", sender: nil)
           // 選択状態の解除
           tableView.deselectRow(at: indexPath, animated: true)
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
                       self.loadUsers(searchText: nil)
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
    
//    func loadComments() {
//
//        guard let currentUser = NCMBUser.current() else {
//                   //ログインに戻る
//                   let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
//                   let rootviewController = storyboard.instantiateViewController(identifier: "RootNavigationController")
//                   UIApplication.shared.keyWindow?.rootViewController = rootviewController
//                   //ログアウト状態の保持
//                   let ud = UserDefaults.standard
//                   ud.set(false, forKey: "isLogin")
//                   ud.synchronize()
//                   return
//               }
//
//        let query = NCMBQuery(className: "Comment")
//        // createDateの降順(投稿された順番)
//        query?.order(byDescending: "createDate")
//        query?.includeKey("user")  //コメントの呼び出しと同時にユーザーもとってくる
//        query?.whereKey("user", equalTo: NCMBUser.current())
//        query?.findObjectsInBackground({ (result, error) in
//            if error != nil {
//                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                self.comments = [Comment]()
//                for commentObject in result as! [NCMBObject] {
//                    // コメントをしたユーザーの情報を取得
//                    let user = commentObject.object(forKey: "user") as! NCMBUser
//                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
//                    if user.object(forKey: "active") as? Bool != false {
//                        // 投稿したユーザーの情報をUserモデルにまとめる
//                        let userModel = User(objectId: user.objectId, userName: user.userName)
//                        userModel.displayName = user.object(forKey: "displayName") as? String
//                        userModel.likeSum = user.object(forKey: "likeSum") as? Int
//
//
//                        // コメントの文字を取得
//                        let text = commentObject.object(forKey: "text") as! String
//
//                        let userImageUrl = URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + user.objectId)
//
//                        // Commentクラスに格納
//                     let comment = Comment(objectId: commentObject.objectId, user: userModel, text: text, createDate: commentObject.createDate)
//                        comment.postImageUrl = userImageUrl
//                    // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
//                    let likeUsers = commentObject.object(forKey: "likeUser") as? [String]
//                    if likeUsers?.contains(currentUser.objectId) == true {
//                        comment.isLiked = true
//                    } else {
//                        comment.isLiked = false
//                    }
//
//                    // いいねの件数
//                    if let likes = likeUsers {
//                        comment.likeCount = likes.count
//                    }
//
//                    self.comments.append(comment)
//                    }
//                }
//                // テーブルをリロード
////                self.likeSum()
////                self.lankUp()
//            }
//        })
//    }
       
       func loadUsers(searchText: String?) {
           let query = NCMBUser.query()
           // 自分を除外
           query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
           
           // 退会済みアカウントを除外
           query?.whereKey("active", notEqualTo: false)
           
           // 検索ワードがある場合
           if let text = searchText {
        //       print(text)
               query?.whereKey("displayName", equalTo: text)
           }
           
           // 新着ユーザー50人だけ拾う
           query?.limit = 50
           query?.order(byDescending: "createDate")
           
           query?.findObjectsInBackground({ (result, error) in
               if error != nil {
                   //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.error, delay: 1.0)
                           }
               } else {
                   // 取得した新着50件のユーザーを格納
                   self.users = result as! [NCMBUser]
                   
                   self.loadFollowingUserIds()
               }
           })
       }
       
       func loadFollowingUserIds() {
           let query = NCMBQuery(className: "Follow")
           query?.includeKey("user")
           query?.includeKey("following")
           query?.whereKey("user", equalTo: NCMBUser.current())
           
           query?.findObjectsInBackground({ (result, error) in
               if error != nil {
                  // SVProgressHUD.showError(withStatus: error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.error, delay: 1.0)
                           }
               } else {
                   self.followingUserIds = [String]()
                   for following in result as! [NCMBObject] {
                       let user = following.object(forKey: "following") as! NCMBUser
                       self.followingUserIds.append(user.objectId)
                   }
                   
                   self.searchUserTableView.reloadData()
               }
           })
        self.searchUserTableView.reloadData()

}
}
