//
//  PictureViewController.swift
//  Judim
//
//  Created by Plutonist on 2017/4/8.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import Hydra
import Kingfisher
import EVGPUImage2
import RxSwift
import RxCocoa

class PictureViewController: UIViewController {
    var index: Int
    
    var scrollView: UIScrollView!
    var pictureView: UIImageView!

    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
        
        scrollView = UIScrollView()
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        pictureView = UIImageView()
        scrollView.addSubview(pictureView)
        pictureView.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        pictureView.contentMode = .scaleAspectFit
    }
    
    
    func configure(picture: PostPicture) {
        async {
            let loader = ImageLoader(for: self.pictureView).setDownload(priority: pow(2, -(Float(self.index))) / 2)
            try await(loader.loadPlaceholder(PLURL(picture.thumbnail)))
            try await(picture.update())
            try await(loader.loadImage(PLURL(picture.src)))
        }.catch{ err in
            print(err.localizedDescription)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
