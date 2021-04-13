//
//  FullImageViewController.swift
//  Unsplash
//
//  Created by Leximelyano.
//  Copyright © 2021 Leximelyano. All rights reserved.
//

import UIKit

class FullImageViewController: UIViewController, UIScrollViewDelegate {
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.prepareScrollView()

        self.recentreImage()
        self.setZoomScale(for: self.scrollView.bounds.size)
        self.scrollView.zoomScale = self.scrollView.minimumZoomScale
        self.imageView.reloadInputViews()
    }
    
    
    func prepareScrollView() {
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.backgroundColor = .white
        scrollView.contentSize = imageView.bounds.size
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.rightAnchor)])
    }
    
    func setZoomScale(for scrollViewSize: CGSize)  {
        let imageSize = imageView.bounds.size
        let widthScale = scrollViewSize.width / imageSize.width
        let heightScale = scrollViewSize.height / imageSize.height
        let minimumScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minimumScale
        scrollView.maximumZoomScale = 2.0
    }
    
    func recentreImage() {
        let scrollViewSize = scrollView.bounds.size
        let imageViewSize = imageView.frame.size
        let horizontal = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        let vertical = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top: vertical - (navigationController?.navigationBar.bounds.size.height)!,
                                               left: horizontal,
                                               bottom: vertical,
                                               right: horizontal)
    }
}

extension FullImageViewController {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        recentreImage()
    }
}
