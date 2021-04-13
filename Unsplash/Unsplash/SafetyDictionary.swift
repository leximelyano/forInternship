//
//  SafetyDictionary.swift
//  Unsplash
//
//  Created by Leximelyano.
//  Copyright © 2021 Leximelyano. All rights reserved.
//

import Foundation

class ThreadSafeDictionary<String: Hashable, Value> {
    
    private var items: [String: Value] = [:]
    
    private var queue: DispatchQueue = DispatchQueue(label: "ThreadSafeDictionaryQueue", attributes: .concurrent)
    
    public var count: Int {
        queue.sync {
            return items.count
        }
    }
    
    public subscript(key: String) -> Value? {
        
        get {
            queue.sync {
                return items[key]
            }
        }
        
        set {
            queue.async(flags: .barrier) {
                self.items[key] = newValue
            }
        }
    }
    
    public func getAllKeys() -> [String]? {
        queue.sync(flags: .barrier) {
            return items.map {$0.key}
        }
    }
    
    public func getAllValues() -> [Value]? {
        queue.sync(flags: .barrier) {
            return items.map {$0.value}
        }
    }
    
    public func removeValueForKey(key: String) {
        queue.async(flags: .barrier) {
            self.items.removeValue(forKey: key)
        }
    }
}
