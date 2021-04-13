//
//  ImageStorage.swift
//  Unsplash
//
//  Created by Leximelyano.
//  Copyright © 2021 Leximelyano. All rights reserved.
//

import Foundation
import UIKit

enum ImageSize {
    case big, small
}

struct ImageStorage {
    let description: ImageDescription
    var bigImage: UIImage?
    var smallImage: UIImage?
    
    mutating func setImage(for size: ImageSize, image: UIImage) {
        switch size {
        case .big:
            self.bigImage = image
        case .small:
            self.smallImage = image
        }
    }
}
