//
//  Post.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import Hydra
import SwiftyJSON
import SwiftSoup
import DynoCore

class Post {
    var site: Site
    
    var json: JSON
    
    var title: String
    var cover: String
    var by: String
    var date: String
    var pictures = [PostPicture]()

    var next: String?
    var hasNext: Bool { return !DynoUtils.isNull(self.next) }

    init(site: Site, json: JSON) {
        self.site = site
        self.json = json
        
        title = json["title"].stringValue
        cover = json["cover"].stringValue
        by = json["by"].stringValue
        date = json["date"].stringValue
    }
    
    func firstPictures() -> Promise<[PostPicture]> {
        return async {
            self.pictures.removeAll()
            let (pictures, next) = try await(self.getPicturesBy(next: nil))
            self.next = next
            self.pictures.append(contentsOf: pictures)
            return self.pictures
        }
    }
    
    func nextPictures() -> Promise<[PostPicture]> {
        return async {
            let (pictures, next) = try await(self.getPicturesBy(next: self.next))
            self.next = next
            self.pictures.append(contentsOf: pictures)
            return self.pictures
        }
    }

    func getPicturesBy(next: String?) -> Promise<(posts: [PostPicture], next: String?)> {
        return async {
            let (result, next) = self.site.reader!.invokePictures(post: self.json, token: next)
            var pictures = [PostPicture]()
            result.arrayValue.forEach { json in
                pictures.append(PostPicture(post: self, json: json))
            }
            return (pictures, next)
        }
    }
}
