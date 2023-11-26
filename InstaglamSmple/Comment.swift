//
//  Comment.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/03.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit

class Comment: NSObject {
    
    var objectId: String
    var postId: String? //PosaID
    var user: User //誰が投稿したか
    var text: String //text
    var createDate: Date //いつ投稿したか
    var isLiked: Bool?
    var likeCount: Int =  0
    var postImageUrl: URL?

    //初期化するときに初期値の設定
    init(objectId: String, user: User, text: String, createDate: Date) {
    
        self.objectId = objectId
        self.user = user
        self.text = text
        self.createDate = createDate
    }
    
}
