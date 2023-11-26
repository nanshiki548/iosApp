//
//  CommentTableViewCell.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/07/17.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit

protocol CommentTableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)//ライクボタンが押されたことをViewControllerに知らせる
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)//メニューボタンが押されたことをViewControllerに知らせる
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton)
  
}

class CommentTableViewCell: UITableViewCell {

    var delegate: CommentTableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
        
    @IBOutlet var userNameLabel: UILabel!
        
    @IBOutlet var likeButton: UIButton!
        
    @IBOutlet var likeCountLabel: UILabel!
        
    @IBOutlet var commentTextView: UITextView!
        
    @IBOutlet var timestampLabel: UILabel!
    
    @IBOutlet var followButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //imageViewを丸くする   bounsは大きさなどが取得できるコード widthは横幅
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.clipsToBounds = true
        userImageView.contentMode = .scaleAspectFill
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    @IBAction func like(button: UIButton) {
        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
    }
    
    @IBAction func openMenu(button: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }
    
    @IBAction func follow(button: UIButton) {
        self.delegate?.didTapFollowButton(tableViewCell: self, button: button)
    }

    
}
