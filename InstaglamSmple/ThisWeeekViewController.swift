//
//  ThisWeeekViewController.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/07/18.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher //timelinの画像をひっ同期で読み込む
//import SVProgressHUD //ロード用
import PKHUD
import SwiftDate //日時を簡単に扱える

class ThisWeekController1: UIViewController, UITableViewDelegate, UITableViewDataSource, ThisWeekTableViewCellDelegate {
    
    
    var selectedThisWeek: ThisWeek?
    
    var thisWeeks = [ThisWeek]()
    
    //var block = [Block]()
    
    var segmentFlag = 0
    
    var blockUserIdArray = [String]()
    
    var followings = [NCMBUser]()
    
    var users = [NCMBUser]()
    
    var followingUserIds = [String]()
    
    @IBOutlet var odaiImageView: UIImageView!
    
    @IBOutlet var ThisWeekTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ThisWeekTableView.delegate = self
        ThisWeekTableView.dataSource = self
        
        //UInibを使ってxibの取得　cellの再利用id
        let nib = UINib(nibName: "ThisWeekTableViewCell", bundle: Bundle.main)
        ThisWeekTableView.register(nib, forCellReuseIdentifier: "ThisWeekCell")
        //余計な線を消す
        ThisWeekTableView.tableFooterView = UIView()
        //高さ調節
    //    ThisWeekTableView.rowHeight = 163
        
        //引っ張って更新
        setRefreshControl()
        // フォロー中のユーザーを取得する。その後にフォロー中のユーザーの投稿のみ読み込み
//        loadFollowingUsers()
//
     //画像表示
        let file = NCMBFile.file(withName: "odai.png", data: nil) as! NCMBFile
                           file.getDataInBackground { (data, error) in
                               if error != nil {
                            //       print(error)
                               } else {
                                   if data != nil {
                                       let image = UIImage(data: data!)
                                       self.odaiImageView.image = image
                                   }
                               }
                           }
               
    }
    override func viewWillAppear(_ animated: Bool) {
        getBlockUser() //コメントを読み込む
    //    loadUsers()
        // loadFollowingUserIds()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let showUserViewController = segue.destination as! ShowUserViewController
        let selectedIndex = ThisWeekTableView.indexPathForSelectedRow!
        showUserViewController.selectedUser = users[selectedIndex.row]
    }
    
   //   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
   //          if followingUserIds.contains(users[indexPath.row].objectId) == true {
   //              return 0
   //          } else {
   //              return 100
   //          }
   //      }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return thisWeeks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cellの再利用
        let cell = tableView.dequeueReusableCell(withIdentifier: "ThisWeekCell") as! ThisWeekTableViewCell
        //cellの内容
        cell.delegate = self
        cell.tag = indexPath.row
        
        let user = thisWeeks[indexPath.row].user
        cell.userNameLabel.text = user.displayName
        
        //画像ファイルを発行したときにサーバーからURLが発行されており、そのURL
        let userImageUrl = URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + user.objectId)
        //kf(kingfisher)が画像を入れている、なかった場合は違う画像を表示してくれる
        cell.userImageView.kf.setImage(with: userImageUrl)
        
        cell.commentTextView.text = thisWeeks[indexPath.row].text
        
        // Likeによってハートの表示を変える
        if thisWeeks[indexPath.row].isLiked == true {
            cell.likeButton.setImage(UIImage(named: "icons8-ハート-48.png"), for: .normal)
        } else {
            cell.likeButton.setImage(UIImage(named: "icons8-いいね-50.png"), for: .normal)
        }
        
        // Likeの数
        cell.likeCountLabel.text = "\(thisWeeks[indexPath.row].likeCount)件"
        
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        let dateFormatter = DateFormatter()   //DateとStringの相互変換いてくれる
        /// フォーマット設定
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"

        // ロケール設定（端末の暦設定に引きづられないようにする）
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        // タイムゾーン設定（端末設定によらず固定にしたい場合）
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Tokyo")

        // 変換
        let creatTime = dateFormatter.string(from: thisWeeks[indexPath.row].createDate)

        cell.timestampLabel.text = creatTime
        
        // Followボタンを機能させる
        cell.tag = indexPath.row
        cell.delegate = self
        
        //        if followingUserIds.contains(users[indexPath.row].objectId) == true {
        //          cell.followButton.isHidden = true
        //    } else {
        //      cell.followButton.isHidden = false
        //   }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           self.performSegue(withIdentifier: "toUser3", sender: nil)
                 // 選択状態の解除
                 tableView.deselectRow(at: indexPath, animated: true)
             }
    
    
    //ライクボタンが押されたときにどのcell,buttonが押されたのか
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
        
        if thisWeeks[tableViewCell.tag].isLiked == false || thisWeeks[tableViewCell.tag].isLiked == nil {
            let query = NCMBQuery(className: "ThisWeek")
            query?.getObjectInBackground(withId: thisWeeks[tableViewCell.tag].objectId, block: { (thisWeek, error) in
                //自分というオブジェクトがlikeUserにあるか確認
                //なかった場合はaddUniqueObject自分というオブジェクトが１個だけ追加
                thisWeek?.addUniqueObject(currentUser.objectId, forKey: "likeUser")
                thisWeek?.saveEventually({ (rror) in
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
            let query = NCMBQuery(className: "ThisWeek")
            query?.getObjectInBackground(withId: thisWeeks[tableViewCell.tag].objectId, block: { (thisWeek, error) in
                if error != nil {
                    //SVProgressHUD.show(withStatus: error!.localizedDescription)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                HUD.flash(.error, delay: 1.0)
             }
                } else {
                    //自分のオブジェクトがあった場合は、removeObject前のものを削除していれる
                    thisWeek?.removeObjects(in: [NCMBUser.current()?.objectId], forKey: "likeUser")
                    thisWeek?.saveEventually({ (error) in
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
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                          switch self.segmentFlag {
                          case 0:
                            self.loadThisWeek()
                          case 1:
                            self.loadThisWeek2()
                          default:
                            self.loadThisWeek()
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
            
            let query = NCMBQuery(className: "ThisWeek")
            query?.getObjectInBackground(withId: self.thisWeeks[tableViewCell.tag].objectId, block: { (thisWeek, error) in
                if error != nil {
                    // SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        HUD.flash(.error, delay: 1.0)
                    }
                } else {
                    // 取得した投稿オブジェクトを削除
                    thisWeek?.deleteInBackground({ (error) in
                        if error != nil {
                            // SVProgressHUD.showError(withStatus: error!.localizedDescription)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                               HUD.flash(.error, delay: 1.0)
                            }
                        } else {
                            // 再読込
                            self.getBlockUser()
                            // SVProgressHUD.dismiss()
    //
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
            object?.setObject(self.thisWeeks[tableViewCell.tag].user.objectId, forKey: "reportId")
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
            
            let object = NCMBObject(className: "Block") //新たにクラス作る
            object?.setObject(self.thisWeeks[tableViewCell.tag].user.objectId, forKey: "blockUserID")
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
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        if thisWeeks[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
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
    
   
    
    
    
    
    
    func loadThisWeek() {
        
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
        
        let query = NCMBQuery(className: "ThisWeek")
        
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
                self.thisWeeks = [ThisWeek]()
                
                for thisWeekObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = thisWeekObject.object(forKey: "user") as! NCMBUser
                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool != false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        // 投稿の情報を取得
                        let text = thisWeekObject.object(forKey: "text") as! String
                        let userImageUrl = URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + user.objectId)
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてThisWeekクラスにセット
                        let thisWeek = ThisWeek(objectId: thisWeekObject.objectId, user: userModel, text: text, createDate: thisWeekObject.createDate)
                        thisWeek.userImageUrl = userImageUrl
                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                        let likeUsers = thisWeekObject.object(forKey: "likeUser") as? [String]
                        if likeUsers?.contains(currentUser.objectId) == true {
                            thisWeek.isLiked = true
                        } else {
                            thisWeek.isLiked = false
                        }
                        
                        // いいねの件数
                        if let likes = likeUsers {
                            thisWeek.likeCount = likes.count
                        }
                        
                        // 配列に加える
                        if self.blockUserIdArray.firstIndex(of: thisWeek.user.objectId) == nil{
                            self.thisWeeks.append(thisWeek)
                            self.users.append(user)
                        }
                    }
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.ThisWeekTableView.reloadData()
            }
        })
    }
    
    func loadThisWeek2() {
        
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
        
        let query = NCMBQuery(className: "ThisWeek")
        
        // (いいね順)
        query?.order(byDescending: "likeUser")
        
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
                self.thisWeeks = [ThisWeek]()
                
                for thisWeekObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = thisWeekObject.object(forKey: "user") as! NCMBUser
                    // 退会済みユーザーの投稿を避けるため、activeがfalse以外のモノだけを表示
                    if user.object(forKey: "active") as? Bool != false {
                        // 投稿したユーザーの情報をUserモデルにまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        // 投稿の情報を取得
                        let text = thisWeekObject.object(forKey: "text") as! String
                        let userImageUrl = URL(string: "https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + user.objectId)
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてThisWeekクラスにセット
                        let thisWeek = ThisWeek(objectId: thisWeekObject.objectId, user: userModel, text: text, createDate: thisWeekObject.createDate)
                        thisWeek.userImageUrl = userImageUrl
                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                        let likeUsers = thisWeekObject.object(forKey: "likeUser") as? [String]
                        if likeUsers?.contains(currentUser.objectId) == true {
                            thisWeek.isLiked = true
                        } else {
                            thisWeek.isLiked = false
                        }
                        
                        // いいねの件数
                        if let likes = likeUsers {
                            thisWeek.likeCount = likes.count
                        }
                        
                        // 配列に加える
                        if self.blockUserIdArray.firstIndex(of: thisWeek.user.objectId) == nil{
                            self.thisWeeks.append(thisWeek)
                            self.users.append(user)
                        }
                    }
                }
                
                // 投稿のデータが揃ったらTableViewをリロード
                self.ThisWeekTableView.reloadData()
            }
        })
    }
    
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadThisWeek(refreshControl:)), for: .valueChanged)
        ThisWeekTableView.addSubview(refreshControl)
    }
    
    @objc func reloadThisWeek(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
//        self.loadFollowingUsers()
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
                      //       self.loadUsers()
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
//                 let query = NCMBUser.query()
//                 // 自分を除外
//                 query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
//
//                 // 退会済みアカウントを除外
//                 query?.whereKey("active", notEqualTo: false)
//
//                 query?.findObjectsInBackground({ (result, error) in
//                     if error != nil {
//                         //SVProgressHUD.showError(withStatus: error!.localizedDescription)
//         DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                       HUD.flash(.error, delay: 1.0)
//                   }
//                     } else {
//                         // 取得したユーザーを格納
//                         self.users = result as! [NCMBUser]
//
//    //                     self.loadFollowingUserIds()
//                     }
//                 })
//             }
    
//    func loadFollowingUsers() {
//        // フォロー中の人だけ持ってくる
//        let query = NCMBQuery(className: "Follow")
//        query?.includeKey("user")
//        query?.includeKey("following")
//        query?.whereKey("user", equalTo: NCMBUser.current())
//        query?.findObjectsInBackground({ (result, error) in
//            if error != nil {
                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                self.followings = [NCMBUser]()
//                for following in result as! [NCMBObject] {
//                    self.followings.append(following.object(forKey: "following") as! NCMBUser)
//                }
//                print(result)
//                self.followings.append(NCMBUser.current())
                
//                self.loadThisWeek()
//            }
//        })
//    }
    
    @IBAction func addThisWeek() {
           let alert = UIAlertController(title: "大喜る", message: "お答えください", preferredStyle: .alert)
           let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
               alert.dismiss(animated: true, completion: nil)
           }
           let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
               alert.dismiss(animated: true, completion: nil)
               //SVProgressHUD.show()
           DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
             //  HUD.show(.progress)
            }
               let object = NCMBObject(className: "ThisWeek")
         //      object?.setObject(self.postId, forKey: "postId")
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
        case 0:thisWeeks.removeAll()
        self.segmentFlag = 0
        self.getBlockUser()
            
            
        case 1:thisWeeks.removeAll()
        self.segmentFlag = 1
        self.getBlockUser()
        default:break
        }
        ThisWeekTableView.reloadData()
    }
    
    
}
