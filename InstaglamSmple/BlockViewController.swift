////
////  BlockViewController.swift
////  InstaglamSmple
////
////  Created by 松田竜弥 on 2020/07/30.
////  Copyright © 2020 松田竜弥. All rights reserved.
////
//
//import UIKit
//import NCMB
////import SVProgressHUD
//
//
//class BlockViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BlockTableViewCellDelegate {
//
//    var blockUsers = [String]()
//
//    @IBOutlet var blockTableView: UITableView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        blockTableView.delegate = self
//        blockTableView.dataSource = self
//
//        //カスタムセルの登録
//        let nib = UINib(nibName: "BlockTableViewCell", bundle: Bundle.main)
//        blockTableView.register(nib, forCellReuseIdentifier: "BlockCell")
//
//        //余計な線を消す
//        blockTableView.tableFooterView = UIView()
//
//        setRefreshControl()
//
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        blockUsers.removeAll()
//        loadBlockUsers()
//        print(blockUsers, "aaaaaaaaaaaaaaaaaaaaa")
//
//        if let user = NCMBUser.current() {
//            self.navigationItem.title = user.userName
//        }
//
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let showUserViewController = segue.destination as! ShowUserViewController
//        let selectedIndex = blockTableView.indexPathForSelectedRow!
//        showUserViewController.selectedUser = blockUsers[selectedIndex.row] as! NCMBUser
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return blockUsers.count
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//
//        return 70
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "BlockCell") as! BlockTableViewCell
//
//        let userImageUrl = URL(string:"https://mbaas.api.nifcloud.com/2013-09-01/applications/ap7X98gCxMAq0jwj/publicFiles/" + NCMBUser(className: blockUsers[indexPath.row]).objectId)
//        cell.userImageView.kf.setImage(with: userImageUrl)
//        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
//        cell.userImageView.layer.masksToBounds = true
//        cell.userImageView.contentMode = .scaleAspectFill
//        cell.userNameLabel.text = NCMBUser(className: blockUsers[indexPath.row]).object(forKey: "displayName") as? String
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        self.performSegue(withIdentifier: "toUser4", sender: nil)
//        // 選択状態の解除
//        tableView.deselectRow(at: indexPath, animated: true)
//    }
//
//    @objc func reload(refreshControl: UIRefreshControl) {
//        refreshControl.beginRefreshing()
//        loadBlockUsers()
//        // 更新が早すぎるので2秒遅延させる
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//            refreshControl.endRefreshing()
//        }
//    }
//
//    func setRefreshControl() {
//        let refreshControl = UIRefreshControl()
//        refreshControl.addTarget(self, action: #selector(reload(refreshControl:)), for: .valueChanged)
//        blockTableView.addSubview(refreshControl)
//    }
//
//            func didTapBlockButton(tableViewCell: UITableViewCell, button: UIButton) {
//                let displayName = NCMBUser(className: blockUsers[tableViewCell.tag]).object(forKey: "displayName") as? String
//                let message = displayName! + "のブロックを解除しますか？"
//                let alert = UIAlertController(title: "解除", message: message, preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
// //                  self.block(selectedUser: self.blockUsers[tableViewCell.tag])
//                }
//                let cancelAction = UIAlertAction(title: "キャンセル", style: .default) { (action) in
//                    alert.dismiss(animated: true, completion: nil)
//                }
//                alert.addAction(okAction)
//                alert.addAction(cancelAction)
//                self.present(alert, animated: true, completion: nil)
//            }
//
////    func block(selectedUser: NCMBUser) {
////        //SVProgressHUD.show()
////                   let query = NCMBQuery(className: "Block")
////        query?.getObjectInBackground(withId: self.blockUsers[tableViewCell.tag].objectId, block: { (blocUser, error) in
////                       if error != nil {
////                           // SVProgressHUD.showError(withStatus: error!.localizedDescription)
////                       } else {
////                           // 取得した投稿オブジェクトを削除
////                           blockUser?.deleteInBackground({ (error) in
////                               if error != nil {
////                                   // SVProgressHUD.showError(withStatus: error!.localizedDescription)
////                               } else {
////                                   // 再読込
////                                loadBlockUsers()
////                                   // SVProgressHUD.dismiss()
////                               }
////                           })
////                       }
////                   })
////    }
////
//
//    func loadBlockUsers() {
//        // フォロー中の人だけ持ってくる
//        let query = NCMBQuery(className: "Block")
//        query?.includeKey("user")
//        query?.findObjectsInBackground({ (result, error) in
//            if error != nil {
//                //SVProgressHUD.showError(withStatus: error!.localizedDescription)
//            } else {
//                self.blockUsers = [String]()
//                for blockUser in result as! [NCMBUser] {
//                    self.blockUsers.append(blockUser.object(forKey: "BlockUserID") as! String )
//                }
//                print(result)
//
//                print(self.blockUsers, "44444444444444444")
//
//                self.blockTableView.reloadData()
//            }
//        })
//    }
//    @IBAction func back() {
//        blockUsers.removeAll()
//        blockUsers = [String]()
//        navigationController?.popViewController(animated: true)
//
//    }
//
//
//
//}
