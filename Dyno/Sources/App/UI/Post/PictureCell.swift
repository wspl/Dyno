//
//  PictureCell.swift
//  Judim
//
//  Created by Plutonist on 2017/4/7.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import Kingfisher
import Regex
//import DynoCore

class PictureCell: BaseCollectionViewCell {
    
    var picture: PostPicture!
    
    var pictureView: UIImageView!
    var loader: ImageLoader!
    
    override func render(root: PLUi<UIView>) {
        pictureView = root.put(UIImageView()) { node, this in
            this.backgroundColor = THEME_PLACEHOLDER_COLOR
            this.contentMode = .scaleAspectFit
            this.snp.makeConstraints { make in
                make.edges.equalTo(this.superview!)
            }
        }
    }
    
    override func prepareForReuse() {
        pictureView.image = nil
        
        loader.clearDownloadTask()
    }
    
    func configure(picture: PostPicture) {
        renderView()
        
        self.picture = picture

        self.loader = ImageLoader(for: self.pictureView)
            .load(PLURL(picture.thumbnail))
    }
    
    
}
