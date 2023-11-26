
//  BlockTableViewCell.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/07/30.
//  Copyright © 2020 松田竜弥. All rights reserved.


import UIKit

protocol BlockTableViewCellDelegate {
    func didTapBlockButton(tableViewCell: UITableViewCell, button:UIButton)
}

class BlockTableViewCell: UITableViewCell {
    
    var delegate: BlockTableViewCellDelegate?

    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var blockButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //Initiaization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
}
