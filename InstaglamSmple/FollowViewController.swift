//
//  FollowViewController.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/07/20.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NCMB
//import SVProgressHUD
import PKHUD


class FollowViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FollowTableViewCellDelegate {
    
    //  var users = [NCMBUser]()
    
    var followings = [NCMBUser]()
    
    var followingUserIds = [String]()
    
    var segmentFlag = 0
    
    @IBOutlet var followTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        followTableView.delegate = self
        followTableView.dataSource = self
        
        //カスタムセルの登録
        let nib = UINib(nibName: "FollowTableViewCell", bundle: Bundle.main)
        followTableView.register(nib, forCellReuseIdentifier: "FollowCell")
        
        //余計な線を消す
        followTableView.tableFooterView = UIView()
        
        setRefreshControl()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        followings.removeAll()
        loadTableView()
    //    print(followings, "aaaaaaaaaaaaaaaaaaaaa")
        
        if let user = NCMBUser.current() {
            self.navigationItem.title = user.userName
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let showUserViewController = segue.destination as! ShowUserViewController
        let selectedIndex = followTableView.indexPathForSelectedRow!
        showUserViewController.selectedUser = followings[selectedIndex.row]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followings.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell") as! FollowTableViewCell
        
        let userImageUrl = URL(string:"https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + followings[indexPath.row].objectId)
        cell.userImageView.kf.setImage(with: userImageUrl)
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
        cell.userImageView.layer.masksToBounds = true
        cell.userImageView.contentMode = .scaleAspectFill
        cell.userNameLabel.text = followings[indexPath.row].object(forKey: "displayName") as? String
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toUser4", sender: nil)
        // 選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @objc func reload(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        loadTableView()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reload(refreshControl:)), for: .valueChanged)
        followTableView.addSubview(refreshControl)
    }
    
    //        func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton) {
    //            let displayName = followings[tableViewCell.tag].object(forKey: "displayName") as? String
    //            let message = displayName! + "をフォローしますか？"
    //            let alert = UIAlertController(title: "フォロー", message: message, preferredStyle: .alert)
    //            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
    //                self.follow(selectedUser: self.followings[tableViewCell.tag])
    //            }
    //            let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
    //                alert.dismiss(animated: true, completion: nil)
    //            }
    //            alert.addAction(okAction)
    //            alert.addAction(cancelAction)
    //            self.present(alert, animated: true, completion: nil)
    //        }
    
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
                    //  self.loadFollowingUsers()
                    //  self.loadFollowerUsers()
                    self.loadTableView()
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
    
    //      func loadFollowingUsers() {
    //          let query = NCMBUser.query()
    // 自分を除外
    //          query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
    
    // 退会済みアカウントを除外
    //          query?.whereKey("active", notEqualTo: false)
    
    // フォロー中の人 + 自分の投稿だけ持ってくる
    //          query?.whereKey("user", containedIn: followings)
    
    
    
    
    // query?.order(byDescending: "createDate")
    
    //        query?.findObjectsInBackground({ (result, error) in
    //          if error != nil {
    //SVProgressHUD.showError(withStatus: error!.localizedDescription)
    //           } else {
    // 取得した新着50件のユーザーを格納
    //               self.users = result as! [NCMBUser]
    //               print(self.users, "????????????")
    
    //               self.loadFollowingUserIds1()
    //           }
    //       })
    // }
    
    
    //  func loadFollowerUsers() {
    //       loadFollowing()
    //           let query = NCMBUser.query()
    //           // 自分を除外
    //           query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
    //
    //           // 退会済みアカウントを除外
    //           query?.whereKey("active", notEqualTo: false)
    
    //           // フォロワーの人 + 自分の投稿だけ持ってくる
    //           query?.whereKey("following", containedIn: followings)
    
    //   query?.order(byDescending: "createDate")
    
    //          query?.findObjectsInBackground({ (result, error) in
    //              if error != nil {
    //SVProgressHUD.showError(withStatus: error!.localizedDescription)
    //              } else {
    // 取得した新着50件のユーザーを格納
    //                  self.users = result as! [NCMBUser]
    //                  print(result, "99999999999999999")
    //                  print(self.users, "!!!!!!!!!!!!!!!!")
    
    //                  self.loadFollowingUserIds2()
    //              }
    //          })
    //  }
    
    //    func loadFollowingUserIds1() {
    //        loadFollower()
    //        let query = NCMBQuery(className: "Follow")
    //        query?.includeKey("user")
    //        query?.includeKey("following")
    //        query?.whereKey("user", equalTo: NCMBUser.current())
    //
    //        query?.findObjectsInBackground({ (result, error) in
    //            if error != nil {
    //                // SVProgressHUD.showError(withStatus: error!.localizedDescription)
    //            } else {
    //                self.followingUserIds = [String]()
    //                for following in result as! [NCMBObject] {
    //                    let user = following.object(forKey: "following") as! NCMBUser
    //                    self.followingUserIds.append(user.objectId)
    //                }
    //
    //                self.followTableView.reloadData()
    //            }
    //        })
    //        self.followTableView.reloadData()
    //
    //    }
    //
    //    func loadFollowingUserIds2() {
    //        loadFollower()
    //        let query = NCMBQuery(className: "Follow")
    //        query?.includeKey("user")
    //        query?.includeKey("following")
    //        query?.whereKey("follow", equalTo: NCMBUser.current())
    //
    //        query?.findObjectsInBackground({ (result, error) in
    //            if error != nil {
    //                // SVProgressHUD.showError(withStatus: error!.localizedDescription)
    //            } else {
    //                self.followingUserIds = [String]()
    //                for following in result as! [NCMBObject] {
    //                    let user = following.object(forKey: "following") as! NCMBUser
    //                    self.followingUserIds.append(user.objectId)
    //                }
    //
    //                self.followTableView.reloadData()
    //            }
    //        })
    //        self.followTableView.reloadData()
    //
    //    }
    
    
    
    //    func loadFollowingInfo() {
    //           // フォロー中
    //           let followingQuery = NCMBQuery(className: "Follow")
    //           followingQuery?.includeKey("user")
    //        followingQuery?.whereKey("user", notEqualTo: NCMBUser.current())
    //           followingQuery?.countObjectsInBackground({ (count, error) in
    //               if error != nil {
    //                  // SVProgressHUD.showError(withStatus: error!.localizedDescription)
    //               } else {
    //                   // 非同期通信後のUIの更新はメインスレッドで
    //                   DispatchQueue.main.async {
    //                   //    self.followingCountLabel.text = String(count)
    //                   }
    //               }
    //           })
    //    }
    //func loadFollowerInfo() {
    // フォロワー
    //       let followerQuery = NCMBQuery(className: "Follow")
    //       followerQuery?.includeKey("following")
    //    followerQuery?.whereKey("following", equalTo: NCMBUser.current())
    //       followerQuery?.countObjectsInBackground({ (count, error) in
    //           if error != nil {
    // SVProgressHUD.showError(withStatus: error!.localizedDescription)
    //           } else {
    //                   print(count, "jjjjjjjjjjjjjjjjjjjjjjj")
    //                   DispatchQueue.main.async {
    //                       // 非同期通信後のUIの更新はメインスレッドで
    //                 //      self.followerCountLabel.text = String(count)
    //                   }
    //               }
    //           })
    //       }
    func loadTableView() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch self.segmentFlag {
            case 0:
                self.loadFollower()
            case 1:
                self.loadFollowing()
            default:
                self.loadFollower()
            }
        }
    }
    
    
    func loadFollowing() {
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
      //          print(result)
                
    //            print(self.followings, "44444444444444444")
                
                //                 self.loadFollowerInfo()
                
                self.followTableView.reloadData()
            }
        })
    }
    
    func loadFollower() {
        // フォロワーの人だけ持ってくる
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("following")
        query?.includeKey("user")
        query?.whereKey("following", equalTo: NCMBUser.current())
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.error, delay: 1.0)
                           }
            } else {
                self.followings = [NCMBUser]()
                for following in result as! [NCMBObject] {
                    
                    self.followings.append(following.object(forKey: "user") as! NCMBUser)
                }
      //          print(result, "vvvvvvvvvvvvvvvvvvv")
                
       //         print(self.followings, "8888888888")
                
                //                   self.loadFollowingInfo()
                
                self.followTableView.reloadData()
            }
        })
    }
    
    @IBAction func segmentButton(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:followings.removeAll()
        self.segmentFlag = 0
        self.loadTableView()
            
        case 1:followings.removeAll()
        self.segmentFlag = 1
        self.loadTableView()
            
        default:break
        }
        followTableView.reloadData()
    }
    
    @IBAction func back() {
        followings.removeAll()
        followings = [NCMBUser]()
        navigationController?.popViewController(animated: true)
        
    }
    
    
    
}
