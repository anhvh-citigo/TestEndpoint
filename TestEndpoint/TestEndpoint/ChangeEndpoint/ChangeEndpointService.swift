//
//  ChangeEndpointService.swift
//  FnB
//
//  Created by AnhVH on 05/03/2021.
//  Copyright © 2021 Citigo. All rights reserved.
//

import Foundation
import Alamofire

class ChangeEndpointService: BaseService {
    
    var dict : ToolChangeEndpointModel
    
    init(dict: ToolChangeEndpointModel) {
        self.dict = dict
    }
    
    override var apiEndpoint: String {
        return self.dict.endpoint
    }
    
    override var method: HTTPMethod {
        switch self.dict.method {
        case 1:
            return .get
        case 3:
            return .post
        case 4:
            return .put
        case 6:
            return .delete
        default:
            return .get
        }
    }
    
    override var path: String {
        return ""
    }
    
    override var encoding: ParameterEncoding? {
        return JSONEncoding.default
    }
    
    override var parameters: APIParams {
        return self.convertToDictionary(text: self.dict.payload)
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    static func createRequest(dict: ToolChangeEndpointModel, completion block: @escaping (KVError?) -> Void) {
        let router = ChangeEndpointService(dict: dict)
        
        APIManager.shared.request(router) { (json, error) in
            if error != nil {
                block(error)
            } else {
                block(nil)
            }
            return
        }
    }
}
