//
//  PostTag.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import RealmSwift

class PostTag: Object {
    var post: Post?
    var site: Site?
    
    dynamic var url: String = ""
    dynamic var name: String = ""
}
