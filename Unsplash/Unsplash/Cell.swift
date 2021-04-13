//
//  Cell.swift
//  Unsplash
//
//  Created by Leximelyano.
//  Copyright © 2021 Leximelyano. All rights reserved.
//
import UIKit

enum State {
    case image(UIImage)
    case filledColor(UIColor)
    
    var isPlaceholder: Bool {
        switch self {
        case .image:
            return false
        case .filledColor:
            return true
        }
    }
}

class Cell: UICollectionViewCell {
    
    static let identifier = "collectionCell"
    private let spinner = UIActivityIndicatorView(style: .large)
    var cellImage: UIImage?
    deinit {
        print("deinit: ",self)
    }
    // MARK: Public
    
    func configure(with state: State) {
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        
        spinner.color = .black
        spinner.startAnimating()
        imageView.addSubview(spinner)
        spinner.center = self.center
        spinner.isHidden = false
        switch state {
        case .image(let image):
            imageView.image = image
            self.cellImage = image
            spinner.isHidden = true
        case .filledColor(let color):
            imageView.backgroundColor = color
            imageView.bringSubviewToFront(spinner)
            imageView.image = nil
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        onInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        onInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
    }
    
    
    // MARK: Private
    
    private lazy var imageView = UIImageView()
    
    private func onInit() {
        contentView.addSubview(imageView)
    }
}

