//
//  SafetyArray.swift
//  Unsplash
//
//  Created by Leximelyano.
//  Copyright © 2021 Leximelyano. All rights reserved.
//

import UIKit

class SafetyArray<T> {
    fileprivate var safeArray = [T]()
    private let lock = NSLock()
    private let accessQueue = dispatch_queue_concurrent_t(label: "SynchronizedArrayAccess", attributes: .concurrent)
    
    func addEntity(_ element: T) {
        lock.lock()
        defer {lock.unlock()}
        self.safeArray.append(element)
    }
    
    func count() -> Int {
        return safeArray.count
    }
    
    func last() -> T? {
        lock.lock()
        defer {lock.unlock()}
        return safeArray.count > 0 ? safeArray.last : nil
    }
    
    public subscript(index: Int) -> T {
        set {
            lock.lock()
            defer{lock.unlock()}
            self.safeArray[index] = newValue
            
        }
        get {
            var element: T!
            lock.lock()
            defer{lock.unlock()}
            element = self.safeArray[index]
            
            return element
        }
    }
}
