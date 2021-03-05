//
//  Utils.swift
//  TestEndpoint
//
//  Created by AnhVH on 05/03/2021.
//  Copyright © 2021 anhvh. All rights reserved.
//

import Foundation
import UIKit

class Formatter {
    
    private static var internalDateFormatter: DateFormatter?
    private static var internalHourFormatter: DateFormatter?
    private static var internalDisplayDateTimeFormatter: DateFormatter?
    private static var internalPriceFormater: NumberFormatter?
    private static var internalQuantityFormater: NumberFormatter?
    private static var internalRatioFormater: NumberFormatter?
    private static var internalICTDateTimeFormatter: DateFormatter?
    
    static var displayDateTimeFormatter: DateFormatter {
        if (internalDisplayDateTimeFormatter == nil) {
            internalDisplayDateTimeFormatter = DateFormatter()
            internalDisplayDateTimeFormatter!.dateFormat = "dd/MM/yyyy HH:mm"
        }
        return internalDisplayDateTimeFormatter!
    }
    
    static var dateFormatter: DateFormatter {
        if (internalDateFormatter == nil) {
            internalDateFormatter = DateFormatter()
            internalDateFormatter!.dateFormat = "dd/MM/yyyy"
        }
        return internalDateFormatter!
    }
    
    static var hourFormatter: DateFormatter {
        if (internalHourFormatter == nil) {
            internalHourFormatter = DateFormatter()
            internalHourFormatter!.dateFormat = "HH:mm:ss"
        }
        return internalHourFormatter!
    }
    
    static var priceFormatter: NumberFormatter {
        if internalPriceFormater == nil {
            internalPriceFormater = NumberFormatter()
            internalPriceFormater?.numberStyle = .decimal;
            internalPriceFormater!.roundingMode = .halfUp;
            internalPriceFormater!.maximumFractionDigits = 0;
            internalPriceFormater!.decimalSeparator = ".";
            internalPriceFormater!.groupingSeparator = ",";
        }
        return internalPriceFormater!;
    }
    
    static var quantiyFormatter: NumberFormatter {
        if internalQuantityFormater == nil {
            internalQuantityFormater = NumberFormatter()
            internalQuantityFormater?.numberStyle = .decimal;
            internalQuantityFormater!.roundingMode = .halfUp;
            internalQuantityFormater!.maximumFractionDigits = 3;
            internalQuantityFormater!.decimalSeparator = ".";
            internalQuantityFormater!.groupingSeparator = ",";
        }
        return internalQuantityFormater!;
    }
    
    static var ratioFormatter: NumberFormatter {
        if let formater = internalRatioFormater {
            return formater
        }
        internalRatioFormater = NumberFormatter()
        internalRatioFormater!.numberStyle = .decimal;
        internalRatioFormater!.roundingMode = .halfUp;
        internalRatioFormater!.maximumFractionDigits = 2;
        internalRatioFormater!.decimalSeparator = ".";
        internalRatioFormater!.groupingSeparator = ",";
        return internalRatioFormater!
    }
    
    static var ictDateTimeFormatter: DateFormatter {
        if (internalICTDateTimeFormatter == nil) {
            internalICTDateTimeFormatter = DateFormatter()
            internalICTDateTimeFormatter!.dateFormat = "E MMM dd yyyy HH:mm:ss 'GMT'z '(Indochina Time)'"
        }
        return internalICTDateTimeFormatter!
    }
}

extension NSNumber {
    public var priceString: String? {
        return Formatter.priceFormatter.string(from: self)
    }
    
    public var ratioString: String? {
        return Formatter.ratioFormatter.string(from: self)
    }
    
    public var quantityString: String? {
        return Formatter.quantiyFormatter.string(from: self)
    }
}


struct KVError: Error {
    let error: Error
    
    var httpCode: Int?
    var errorCode: String?
    var errorMessage: String?
    var offline = false
    var errorSubMessage: String?
    
    
    init(error: Error) {
        self.error = error
    }
    
    init() {
        let userInfo = [NSLocalizedDescriptionKey : "Unknown", NSLocalizedFailureReasonErrorKey : "Unknown"]
        self.error = NSError(domain: Constants.Error.domain, code: Constants.Error.unknownErrorCode, userInfo: userInfo)
    }
}

extension Error {
    var underlyingKVError: Error? { return (self as? KVError)?.error }
}

extension URLError {
    var errorCodeString: String {
        switch code {
        case .notConnectedToInternet : return "notConnectedToInternet"
        case .cannotFindHost: return "cannotFindHost"
        case .cannotConnectToHost: return "cannotConnectToHost"
        case .networkConnectionLost: return "networkConnectionLost"
        case .dnsLookupFailed: return "dnsLookupFailed"
        case .timedOut: return "timedOut"
        case .appTransportSecurityRequiresSecureConnection: return "appTransportSecurityRequiresSecureConnection"
            
        default:
            return "raw: \(code.rawValue) hash:\(code.hashValue)"
        }
    }
    
}

