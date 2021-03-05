//
//  BaseService.swift
//  FnB
//
//  Created by Tran Manh Tuan on 8/23/17.
//  Copyright © 2017 Citigo. All rights reserved.
//

import Foundation
import Alamofire

public typealias JSONDictionary = [String: Any]
typealias APIParams = [String : Any]?

protocol APIConfiguration {
    var method: Alamofire.HTTPMethod { get }
    var path: String { get }
    var parameters: APIParams { get }
    var encoding: Alamofire.ParameterEncoding? { get }
    var timeoutInterval: TimeInterval? { get }
}

class BaseService: URLRequestConvertible, APIConfiguration {
    
    init() {}
    
    var method: Alamofire.HTTPMethod {
        fatalError("[\(Mirror(reflecting: self).subjectType) - \(#function))] Must be overridden in subclass")
    }
    
    var path: String {
        fatalError("[\(Mirror(reflecting: self).subjectType) - \(#function))] Must be overridden in subclass")
    }
    
    var parameters: APIParams {
        fatalError("[\(Mirror(reflecting: self).subjectType) - \(#function))] Must be overridden in subclass")
    }
    
    var encoding: ParameterEncoding? {
        fatalError("[\(Mirror(reflecting: self).subjectType) - \(#function))] Must be overridden in subclass")
    }
    
    var header: APIParams {
        get {
            return nil
        }
    }
    
    var apiEndpoint: String {
        get {
            return ""
        }
    }
    
    var timeoutInterval: TimeInterval? {
           get {
               return nil
           }
       }
    
    func asURLRequest() throws -> URLRequest {
        let baseURL = try (self.apiEndpoint.appendingPathComponent(path)).asURL()
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = method.rawValue
        
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        if let header = header {
            for field in header {
                if let value = field.value as? String {
                    urlRequest.addValue(value, forHTTPHeaderField: field.key)
                }
            }
        }
        if let encoding = encoding {
            return try encoding.encode(urlRequest, with: parameters)
        }
        if let timeoutInterval = timeoutInterval {
            urlRequest.timeoutInterval = timeoutInterval
        }
        return urlRequest
    }
}
