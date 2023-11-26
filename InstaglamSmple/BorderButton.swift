//
//  BorderButton.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/11.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit

@IBDesignable

class BorderButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
