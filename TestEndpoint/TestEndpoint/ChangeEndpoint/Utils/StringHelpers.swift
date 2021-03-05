//
//  StringHelpers.swift
//  TestEndpoint
//
//  Created by AnhVH on 05/03/2021.
//  Copyright © 2021 anhvh. All rights reserved.
//

import Foundation
//MARK: - NSString extensions
public extension String {
    
    /// SwifterSwift: NSString from a string.
    ///
    public var nsString: NSString {
        return NSString(string: self)
    }
    
    /// SwifterSwift: NSString lastPathComponent.
    ///
    public var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
    
    /// SwifterSwift: NSString pathExtension.
    ///
    public var pathExtension: String {
        return (self as NSString).pathExtension
    }
    
    /// SwifterSwift: NSString deletingLastPathComponent.
    ///
    public var deletingLastPathComponent: String {
        return (self as NSString).deletingLastPathComponent
    }
    
    /// SwifterSwift: NSString deletingPathExtension.
    ///
    public var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }
    
    /// SwifterSwift: NSString pathComponents.
    ///
    public var pathComponents: [String] {
        return (self as NSString).pathComponents
    }
    
    /// SwifterSwift: NSString appendingPathComponent(str: String)
    ///
    /// - Parameter str: the path component to append to the receiver.
    /// - Returns: a new string made by appending aString to the receiver, preceded if necessary by a path separator.
    public func appendingPathComponent(_ str: String) -> String {
        return (self as NSString).appendingPathComponent(str)
    }
    
    /// SwifterSwift: NSString appendingPathExtension(str: String)
    ///
    /// - Parameter str: The extension to append to the receiver.
    /// - Returns: a new string made by appending to the receiver an extension separator followed by ext (if applicable).
    public func appendingPathExtension(_ str: String) -> String? {
        return (self as NSString).appendingPathExtension(str)
    }
    
    public var length: Int {
        return characters.count
    }
    
    public func firstIndex(of string: String) -> Int? {
        return Array(characters).map({String($0)}).index(of: string)
    }
}
