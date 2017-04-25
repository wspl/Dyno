//
//  ImageLoader.swift
//  Dyno
//
//  Created by Plutonist on 2017/4/23.
//  Copyright © 2017年 Plutonist. All rights reserved.
//

import UIKit
import Kingfisher
import Hydra
import EVGPUImage2

class ImageLoader {
    weak var imageView: UIImageView?
    weak var blurImageView: UIImageView?
    
    private var placeholderURL: PLURL?
    private var imageURL: PLURL?
    
    init(for imageView: UIImageView) {
        self.imageView = imageView
    }
    
    func placeholder(_ url: PLURL) -> ImageLoader {
        placeholderURL = url
        return self
    }
    
    func bindBlur(_ imageView: UIImageView) -> ImageLoader {
        blurImageView = imageView
        return self
    }

    func crop(image: Image, params: String) -> UIImage {
        let params = params.characters.split{$0 == ","}.map(String.init)
        
        
        let image = image.cgImage?.cropping(to: CGRect(
            x: -CGFloat(Float(params[0])!),
            y: -CGFloat(Float(params[1])!),
            width: CGFloat(Float(params[2])!),
            height: CGFloat(Float(params[3])!)))
        
        let uiImage = UIImage(cgImage: image!)
        return uiImage
    }
    
    func blur(image: Image, params: String) -> UIImage {
        let processor = BlurImageProcessor(blurRadius: CGFloat(Float(params)!))
        return processor.process(item: ImageProcessItem.image(image), options: [])!
    }
    
    func processedImage(of image: UIImage, by url: PLURL) -> UIImage {
        var processed: UIImage?
        switch url.fun {
        case "crop":
            processed = self.crop(image: image, params: url.params)
        case "blur":
            processed = self.blur(image: image, params: url.params)
        case "processed":
            ImageCache.default.store(processed!, forKey: url.raw)
        default:
            processed = image
        }
        return processed!
    }

    private func set(_ url: PLURL, view: UIImageView) -> Promise<UIImage> {
        return async {
            var image = try await(self.retrieve(forKey: url.raw))
            if image == nil {
                if let srcImage = try await(self.retrieve(forKey: url.urlString)) {
                    image = self.processedImage(of: srcImage, by: url)
                } else {
                    image = try await(self.download(url))
                    image = self.processedImage(of: image!, by: url)
                }
                self.cache(url, image: image!)
            }
            DispatchQueue.main.sync {
                view.image = image
            }
            
            return image!
        }
    }
    
    
    var downloadTasks = [RetrieveImageDownloadTask]()
    private func download(_ url: PLURL) -> Promise<UIImage> {
        return Promise { resolve, reject in
            print("download:", url.raw)
            self.downloadTasks.append(ImageDownloader.default.downloadImage(with: url.url, options: self.downloadOptions)
                    { image, error, url, data in
                if error == nil {
                    resolve(image!)
                } else {
                    reject(error!)
                }
            }!)
        }
    }
    
    func clearDownloadTask() {
        self.downloadTasks.forEach { task in
            task.cancel()
        }
        self.downloadTasks.removeAll()
    }
    
    var downloadOptions = [KingfisherOptionsInfoItem]()
    func setDownload(priority: Float?) -> ImageLoader {
        if priority != nil {
            downloadOptions.append(.downloadPriority(priority!))
        }
        
        return self
    }
    
    private func cache(_ url: PLURL, image: Image) {
        ImageCache.default.store(image, forKey: url.raw)
    }
    
    private func retrieve(forKey key: String) -> Promise<UIImage?> {
        return Promise { resolve, reject in
            ImageCache.default.retrieveImage(forKey: key, options: nil) { image, cacheType in
                resolve(image)
            }
        }
    }
    
    var waitBetween: Promise<()>?
    func wait(between: Promise<()>) -> ImageLoader {
        self.waitBetween = between
        return self
    }
    
//    func loadPlaceholder(_ url: PLURL) -> Promise<UIImage> {
//        return self.set(url, view: self.imageView!)
//    }
//    
//    func loadImage(_ url: PLURL) -> Promise<UIImage> {
//        return async {
//            self.imageURL = url
//            let image = try await(self.set(url, view: self.imageView!))
//            
//            if self.blurImageView != nil {
//                try await(self.set(url.produce(fun: "blur", params: "20"), view: self.blurImageView!))
//            }
//            
//            return image
//        }
//    }
    
    //func setImageWith
    
    func loadPlaceholder(_ url: PLURL) -> Promise<UIImage> {
        return Promise { resolve, reject in
            self.imageView!.kf.setImage(with: url.url, options: [.processor(<#T##ImageProcessor#>)])
        }
    }

    func loadImage(_ url: PLURL) -> Promise<UIImage> {
        return async {
            self.imageURL = url
            let image = try await(self.set(url, view: self.imageView!))

            if self.blurImageView != nil {
                try await(self.set(url.produce(fun: "blur", params: "20"), view: self.blurImageView!))
            }

            return image
        }
    }


    
    func load(_ url: PLURL) -> ImageLoader {
        async {
            if self.placeholderURL != nil { try await(self.loadPlaceholder(self.placeholderURL!)) }
            try await(self.loadImage(url))
        }.then {}
        
        return self
    }
}
