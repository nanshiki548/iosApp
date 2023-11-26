//
//  FollowTableViewCell.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/07/20.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit

protocol FollowTableViewCellDelegate {
 //   func didTapFollowButton(tableViewCell: UITableViewCell, button:UIButton)
}

class FollowTableViewCell: UITableViewCell {
    
    var delegate: FollowTableViewCellDelegate?

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
   // @IBOutlet var followButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initiaization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
//    @IBAction func follow(button: UIButton) {
//        self.delegate?.didTapFollowButton(tableViewCell: self, button: button)
//    }
    
}
