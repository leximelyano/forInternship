//
//  Loader.swift
//  Unsplash
//
//  Created by Leximelyano.
//  Copyright © 2021 Leximelyano. All rights reserved.

import UIKit
enum SizeEnum {
    case big, small
}

protocol ImageLoaderDelegate: AnyObject {
    func didFinishLoad(image: UIImage, with id: String, from url: URL)
}

protocol ImageLoader {
    func loadImage(with id: String, from url: URL)
    func cancel(for id: String)
}


class Loader: ImageLoader {
    
    // MARK: Public

    public weak var delegate: ImageLoaderDelegate?
    let lock = NSLock()
    public func loadImage(with id: String, from url: URL) {
        let operation = LoadOperation(imageId: id, url: url) { [weak self] (image) in
            self?.delegate?.didFinishLoad(image: image, with: id, from: url)
            self?.lock.lock()
            self?.safeOperations.removeValueForKey(key: id)
            self?.lock.unlock()
        }
        self.safeOperations[id] = operation
        queue.addOperation(operation)
    }
    
    func cancel(for id: String) {
        lock.lock()
        defer { lock.unlock() }
        safeOperations[id]?.cancel()
        safeOperations[id] = nil
    }
    
    // MARK: Private
    
     var queue: OperationQueue = {
       let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 12
        queue.qualityOfService = .default
        
        return queue
    }()
    private var safeOperations = ThreadSafeDictionary<String, Operation>()
}
