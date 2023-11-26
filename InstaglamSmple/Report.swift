//
//  Report.swift
//  InstaglamSmple
//
//  Created by 松田竜弥 on 2020/07/23.
//  Copyright © 2020 松田竜弥. All rights reserved.
//

import UIKit

class Report: NSObject {
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
