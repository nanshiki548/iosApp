//
//  User.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/06/03.
//  Copyright © 2020 松田竜弥. All rights reserved.
//
//誰が投稿したのかのデータをまとめたもの
//複雑なデータを毎回NCMBUserから持ってくるのは面倒

import UIKit

class User: NSObject {
    var objectId: String
    var userName: String
    var displayName: String?
    var introduction: String?
    var likeSum: Int?
    

    init(objectId: String, userName: String) {
        self.objectId = objectId
        self.userName = userName
    }
}
