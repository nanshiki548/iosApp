//
//  TimelineTableViewCell.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/03.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit

protocol TimelineTableViewCellDelegate {
//    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)//ライクボタンが押されたことをViewControllerに知らせる
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)//メニューボタンが押されたことをViewControllerに知らせる
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) //コメントボタンが押されたことをViewContorollerに知らせる
}

class TimelineTableViewCell: UITableViewCell {

    var delegate: TimelineTableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
        
    @IBOutlet var userNameLabel: UILabel!
        
    @IBOutlet var postImageView: UIImageView!
        
    @IBOutlet var likeButton: UIButton!
        
    @IBOutlet var commentsCountLabel: UILabel!
        
    @IBOutlet var commentTextView: UITextView!
        
    @IBOutlet var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        //imageViewを丸くする   bounsは大きさなどが取得できるコード widthは横幅
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
//    @IBAction func like(button: UIButton) {
//        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
//    }

    @IBAction func openMenu(button: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }

    @IBAction func showComments(button: UIButton) {
     
        self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
    }

}
