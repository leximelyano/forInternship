//
//  UnsplashService.swift
//  Unsplash
//
//  Created by Leximelyano.
//  Copyright © 2021 Leximelyano. All rights reserved.
//

import Foundation

enum LoadingError: Error {
    case noDataFromSearchRequest
}

protocol UnsplashService {
    var isTaskActivate: Bool {get set}
    
    func searchImages(with title: String, page: Int, completion: @escaping ([ImageDescription], LoadingError?) -> Void)
    func cancelTask()
}

class UnsplashServiceImplementation: UnsplashService {
    
    var isTaskActivate = false
    var task: URLSessionDataTask?
    let clientId = "Client-ID 1bcd1dea835991d51e61f90290e097356c8a887396a5ae67c0c629a9336950e7"
    let apiUrl   = URL(string: "https://api.unsplash.com")!
    
    func searchImages(with title: String, page: Int, completion: @escaping ([ImageDescription], LoadingError?) -> Void) {
        if let searchUrl =  URL(string: "https://api.unsplash.com/search/photos?page=\(page)&query=\(title)&per_page=30") {
            isTaskActivate = true
            var request = URLRequest(url: searchUrl)
            request.httpMethod = "GET"
            request.addValue(clientId, forHTTPHeaderField: "Authorization")
            task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                guard (response as? HTTPURLResponse)?.statusCode == 200 else { return }
                if let data = data {
                    do {
                        let dataModel = try JSONDecoder().decode(CollectionDescription.self, from: data)
                        let results = dataModel.results
                        let errNoData = results.count == 0 ? LoadingError.noDataFromSearchRequest : nil
                        completion(results, errNoData)
                        self.isTaskActivate = false
                    } catch  {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        task?.resume()
    }
    
    func cancelTask() {
        task?.cancel()
        isTaskActivate = false
        task = nil
    }
}
