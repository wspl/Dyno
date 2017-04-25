//
//  SiteViewModel.swift
//  Judim
//
//  Created by Plutonist on 2017/4/3.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Hydra

struct SiteViewModel {
    var site: Site

    var posts = Variable<[Post]>([])

    var loadPublisher = PublishSubject<PLLoadEvent>()

    init() {
        let rule = try! await(PLRequest.get("http://127.0.0.1:3000/example.rule.jsc").data())
        site = Site(fromData: rule, name: "EH")
    }
    
    func reload() {
        async {
            self.posts.value = try await(self.site.firstPosts())
            self.loadPublisher.onNext(.refreshFinished)
        }.catch { err in
            self.loadPublisher.onNext(.refreshFailed)
            self.loadPublisher.onError(err)
        }
    }
    
    func more() {
        async {
            self.posts.value = try await(self.site.nextPosts())
            self.loadPublisher.onNext(.loadMoreFinished)
        }.catch { err in
            self.loadPublisher.onNext(.loadMoreFailed)
            self.loadPublisher.onError(err)
        }
    }
}
