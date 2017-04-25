//
//  PostPicture.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import RealmSwift
import Hydra
import SwiftSoup
import SwiftyJSON

class PostPicture {
    var post: Post
    var site: Site { return post.site }
    
    var json: JSON

    var thumbnail: String
    var src: String
    
    init(post: Post, json: JSON) {
        self.post = post
        self.json = json
        //site = post.site
        
        thumbnail = json["thumbnail"].stringValue
        src = json["src"].stringValue
    }
    
    func update() -> Promise<()> {
        return async {
            let updated = self.site.reader!.invokeUpdatePicture(picture: self.json)
            self.src = updated["src"].stringValue
            self.thumbnail = updated["thumbnail"].stringValue
        }
    }
    
}
