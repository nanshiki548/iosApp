//
//  ThisWeek.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/07/18.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit

class ThisWeek: NSObject {
   var objectId: String
   var user: User
   var text: String
   var createDate: Date
   var isLiked: Bool?
   var likeCount: Int = 0
    var userImageUrl: URL?

   //Objectの初期化と同時に初期値を入れる　optional型ではないものに関してnilを許容せず必ず値が入るのでObjectが作られた時値を渡してあげる
   init(objectId: String, user: User, text: String, createDate: Date) {
       //もらってきた値を代入
       self.objectId = objectId
       self.user = user
       self.text = text
       self.createDate = createDate
    }
}
