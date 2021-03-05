//
//  APIManager.swift
//  FnB
//
//  Created by Tran Manh Tuan on 8/24/17.
//  Copyright © 2017 Citigo. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import DeviceKit

typealias completionBlock = (JSON?, KVError?) -> Void

public class APIManager {
    
    static let shared = APIManager()
    
    let manager: SessionManager
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        
        if let info = Bundle.main.infoDictionary {
            let appVersion = info["CFBundleShortVersionString"] as? String ?? "Unknown"
            configuration.httpAdditionalHeaders?.updateValue("iOS-fnb-\(appVersion)", forKey: "App")
            
            let device = Device()
            let buildVersion = info[kCFBundleVersionKey as String] as? String ?? "Unknown"
            let deviceName = device.name.replacingOccurrences(of: "’", with: "")
            let userAgent = "iOS/fnb/\(appVersion) (build: \(buildVersion); iOS \(device.systemVersion); model: \(device.description); name: \(deviceName))"
            configuration.httpAdditionalHeaders?.updateValue(userAgent, forKey: "User-Agent")
            configuration.timeoutIntervalForRequest = 10
        }
        manager = Alamofire.SessionManager(configuration: configuration)
    }
    
    // MARK: - Methods
    
    func request(_ url: URLRequestConvertible, completion: @escaping completionBlock) -> Void {
        
        guard shouldExecuteRequest(url: url) else {
            var error = KVError()
            error.httpCode = 401
            completion(nil, error)
            return
        }
        
        let utilityQueue = DispatchQueue.global(qos: .background)
        manager.request(url).validate().responseJSON(queue: utilityQueue, options: .allowFragments) { (response) in
            self.handleResponse(response: response, completion: completion)
        }
    }
    
    func upload(_ url: URLRequestConvertible, formDataBlock: @escaping (MultipartFormData) -> Void, completion: @escaping completionBlock) {
        
        manager.upload(multipartFormData: formDataBlock, with: url, encodingCompletion: { (result) in
            switch result {
            case .success(let upload, _, _):
                upload.validate()
                upload.responseJSON { response in
                    self.handleResponse(response: response, completion: completion)
                }
            case .failure(let encodingError):
                DispatchQueue.main.async {
                    completion(nil, KVError(error: encodingError))
                }
            }
        })
    }
    
    /// Incase: response error message can not parse -> return
    private func returnUnhandleResponseError (kvError: KVError, completion: @escaping completionBlock) {
        DispatchQueue.main.async {
            completion(nil, kvError)
        }
    }
    
    /// Validating upon Http response code
    private func validatingResponseHttpCode (kvError: KVError, validData: Data, httpResponse: HTTPURLResponse, completion: @escaping completionBlock) {
        /// validating: error code
        if httpResponse.statusCode == 401 {
            //Force logout user
            cancelAllRequest()
            return
        }
        if httpResponse.statusCode == 405 {
            cancelAllRequest()
            return
        }
    }
    
    /// Validating upon: basic reponse error code
    private func validatingResponseError(err: URLError, error: KVError, completion: @escaping completionBlock) {
        var kvError = error
        switch err.code {
        case .notConnectedToInternet,
             .cannotFindHost,
             .cannotConnectToHost,
             .networkConnectionLost,
             .dnsLookupFailed,
             .timedOut,
             .appTransportSecurityRequiresSecureConnection:
            kvError.errorMessage = "Không có kết nối internet. Vui lòng thử lại sau!"
            kvError.offline = true
            kvError.errorCode = err.errorCodeString
            break
        case .httpTooManyRedirects,
             .resourceUnavailable,
             .redirectToNonExistentLocation,
             .internationalRoamingOff,
             .callIsActive,
             .dataNotAllowed,
             .secureConnectionFailed,
             .cannotLoadFromNetwork:
            kvError.errorMessage = "Có lỗi xảy ra. Vui lòng kiểm tra kết nối internet và thử lại sau!"
            kvError.offline = true
            kvError.errorCode = err.errorCodeString
            break
        default:
            kvError.errorMessage = "Có lỗi xảy ra. Vui lòng kiểm tra kết nối internet và thử lại sau!"
            kvError.errorCode = err.errorCodeString
            kvError.offline = false
            break
        }
        
        DispatchQueue.main.async {
            completion(nil, kvError)
        }
        return
    }
    
    /// Valinding upon: response error message JSON format
    private func validatingResponseErrorMessage(error: KVError, jsonObject: JSON, statusKey: String, errorKey: String, messageKey: String, completion: @escaping completionBlock) {
        var kvError = error
        if let resData = jsonObject[statusKey].dictionary {
            if let code = resData[errorKey] {
                kvError.errorCode = code.stringValue
            }
            if let msg = resData[messageKey] {
                kvError.errorMessage = msg.stringValue
            }
            self.returnUnhandleResponseError(kvError: kvError, completion: completion)
        }
    }
    
    /// Validating API Response Error Message: validate base on JSON format
    private func parseAPIResponseErrorMessage(error: KVError, validData: Data, completion: @escaping completionBlock) {
        var kvError = error
        /// validating other success response: error message but not in error formated message
        do {
            let json = try JSONSerialization.jsonObject(with: validData, options: .allowFragments)
            let jsonObject = JSON(json)
            
            //sensitive-case
            if jsonObject["responseStatus"] != JSON.null {
                self.validatingResponseErrorMessage(error: kvError,
                                                    jsonObject: jsonObject,
                                                    statusKey: "responseStatus",
                                                    errorKey: "errorCode",
                                                    messageKey: "message",
                                                    completion: completion)
                return
            }

            ////upper-case
            if jsonObject["ResponseStatus"] != JSON.null {
                self.validatingResponseErrorMessage(error: kvError,
                                                    jsonObject: jsonObject,
                                                    statusKey: "ResponseStatus",
                                                    errorKey: "ErrorCode",
                                                    messageKey: "Message",
                                                    completion: completion)
                return
            }
            
            kvError.errorCode = "Not definied!"
            kvError.errorMessage = "Not defined Error message"
            self.returnUnhandleResponseError(kvError: kvError, completion: completion)
            return
        } catch let error {
            kvError.errorSubMessage = "Could not parse JSON for response: \(error.localizedDescription)"
            self.returnUnhandleResponseError(kvError: kvError, completion: completion)
        }
    }
    
    private func handleResponse(response: DataResponse<Any>, completion: @escaping completionBlock) {
        switch response.result {
        case .success(let json):
            let jsonObject = JSON(json)
            DispatchQueue.main.async {
                completion(jsonObject, nil)
            }
            break
        case .failure(let error):
            var kvError = KVError(error: error)
            
            /// validating error
            if let err = error as? URLError {
                self.validatingResponseError(err: err, error: kvError, completion: completion)
            } else {
                /// validating response: The server's response to the URL request.
                guard let httpResponse = response.response else {
                    kvError.errorMessage = "Có lỗi xảy ra. Vui lòng kiểm tra kết nối internet và thử lại sau!"
                    kvError.errorSubMessage = "response is nil"
                    
                    DispatchQueue.main.async {
                        completion(nil, kvError)
                    }
                    return
                }
                kvError.httpCode = httpResponse.statusCode
                
                /// validating response data: The data returned by the server
                guard let validData = response.data, validData.count > 0 else {
                    kvError.errorMessage = "Có lỗi xảy ra. Vui lòng kiểm tra kết nối internet và thử lại sau!"
                    kvError.errorSubMessage = "response data is invalid: \(String(describing: response.data))"
                    self.returnUnhandleResponseError(kvError: kvError, completion: completion)
                    return
                }
                
                
                /// validating: httpResponse error code -> return
                self.validatingResponseHttpCode(kvError: kvError, validData: validData, httpResponse: httpResponse, completion: completion)
                
                /// validating other success response: error message but not in error formated message  -> return
                self.parseAPIResponseErrorMessage(error: kvError, validData: validData, completion: completion)
                
                /// else: return http status code
                kvError.httpCode = httpResponse.statusCode
                return
            }
        }
    }
    
    func cancelAllRequest() {
        manager.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
    
    func shouldExecuteRequest(url: URLRequestConvertible) -> Bool {
        
        do {
            let request = try url.asURLRequest()
            
            return true
        } catch let error {
            print(error.localizedDescription)
        }
        
        return true
    }
    
}
