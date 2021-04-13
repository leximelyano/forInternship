//
//  LoadOperation.swift
//  Unsplash
//
//  Created by Leximelyano.
//  Copyright © 2021 Leximelyano. All rights reserved.
//

import UIKit

class LoadOperation: AsyncOperation {
    deinit {
        if url.description == "https://images.unsplash.com/photo-1511649475669-e288648b2339?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&w=200&fit=max&ixid=eyJhcHBfaWQiOjEwNzc4NX0" {
            
            print("deinit for " , url)
        }
    }
    
    var url: URL
    var imageId: String
    
    private var completion: (UIImage) -> Void
    
    init(imageId: String, url: URL, completion: @escaping (UIImage) -> Void) {
        self.url = url
        self.imageId = imageId
        self.completion = completion
        super.init()
    }
    
    weak var task: URLSessionDataTask?
    
    override func main() {
        task = URLSession(configuration: .default).dataTask(with: url, completionHandler: { (data, responce, error) in
            if let data = data {
                if let image = UIImage(data: data) {
                    self.completion(image)
                }
            }
            self.state = .finished
        })
        task?.resume()
    }
    
    override func cancel() {
        super.cancel()
        if isExecuting {
            task = nil
            state = .finished
        }
    }
}
