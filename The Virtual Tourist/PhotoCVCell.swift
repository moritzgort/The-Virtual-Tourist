//
//  PhotoCVCell.swift
//  The Virtual Tourist
//
//  Created by Moritz Gort on 24/03/16.
//  Copyright © 2016 Gabriele Gort. All rights reserved.
//

import UIKit

class PhotoCVCell: UICollectionViewCell, FinishedDownloadDelegate {
    
    @IBOutlet weak var imageCell: UIImageView!
    var downloadedPhoto: Image!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        print("own image is: \(self.downloadedPhoto.ownImage)")
        if self.downloadedPhoto.ownImage == nil {
            print("image is nil")
            if let downloader = ImageDownload.sharedInstance().downloading[self.downloadedPhoto.description.hashValue] as? ImageLoader {
                downloader.finishedDownloadDelegate.append(self)
                self.layoutIfNeeded()
            } else {
                imageCell.image = downloadedPhoto.ownImage
            }
        } else {
            imageCell.image = downloadedPhoto.ownImage
        }
    }
    
    func finishedLoad() {
        print("Finished - now use the photos")
        dispatch_async(dispatch_get_main_queue()) {
            self.imageCell.image = self.downloadedPhoto.ownImage
        }
    }
}
