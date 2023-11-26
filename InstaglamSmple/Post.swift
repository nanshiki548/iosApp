//
//  Post.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/03.
//  Copyright © 2020 松田竜弥. All rights reserved.
//
//投稿したもののデータをまとめたもの
//複雑なデータを毎回NCMBObjectから持ってくるのは面倒

import UIKit

class Post {
    var objectId: String
    var user: User
    var imageUrl: String?
    var text: String?
    var createDate: Date 
    var isLiked: Bool?
    var comments: [Comment]?
    var commentsCount: Int = 0

    //Objectの初期化と同時に初期値を入れる　optional型ではないものに関してnilを許容せず必ず値が入るのでObjectが作られた時値を渡してあげる
    init(objectId: String, user: User, createDate: Date) {
        //もらってきた値を代入
        self.objectId = objectId
        self.user = user
        self.createDate = createDate
    }
}
