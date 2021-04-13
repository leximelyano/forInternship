//
//  CollectionDescription.swift
//  Unsplash
//
//  Created by Leximelyano.
//  Copyright © 2021 Leximelyano. All rights reserved.
//

import Foundation

struct CollectionDescription: Codable {
    let total: Int
    let total_pages: Int
    let results: [ImageDescription]
}

struct ImageDescription: Codable {
    let id: String
    let color: String
    let urls: [String: String]
}
