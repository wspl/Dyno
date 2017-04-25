//
//  Site.swift
//  Judim
//
//  Created by Plutonist on 2017/4/2.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import Foundation
import SwiftyJSON
import Hydra
import DynoCore

class Site {
    var data: Data
    var name: String
    var posts = [Post]()
    
    var reader: DynoReader?
    
    var next: String?
    var hasNext: Bool { return !DynoUtils.isNull(self.next) }

    init(fromData data: Data, name: String) {
        self.data = data
        self.name = name
    }
    
    func firstPosts() -> Promise<[Post]> {
        return async {
            self.posts.removeAll()
            let (posts, next) = try await(self.getPostBy(next: nil))
            self.next = next
            self.posts.append(contentsOf: posts)
            return self.posts
        }
    }
    
    func nextPosts() -> Promise<[Post]> {
        return async {
            let (posts, next) = try await(self.getPostBy(next: self.next))
            self.next = next
            self.posts.append(contentsOf: posts)
            return self.posts
        }
    }
    
    func getPostBy(next: String?) -> Promise<(posts: [Post], next: String?)> {
        return async {
            if self.reader == nil {
                let re = try await(Dyno.runtime())
                self.reader = re.load(readerJSC: DynoJSC(fromEncrypted: self.data))
            }
            let (result, next) = self.reader!.invokePosts(token: next)
            var posts = [Post]()
            result.arrayValue.forEach { json in
                posts.append(Post(site: self, json: json))
            }
            
            return (posts, next)
        }
    }
}
