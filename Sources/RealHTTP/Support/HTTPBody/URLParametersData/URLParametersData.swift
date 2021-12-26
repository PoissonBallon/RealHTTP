//
//  IndomioHTTP
//
//  Created by the Mobile Team @ ImmobiliareLabs
//  Email: mobile@immobiliare.it
//  Web: http://labs.immobiliare.it
//
//  Copyright ©2021 Immobiliare.it SpA. All rights reserved.
//  Licensed under MIT License.
//

import Foundation

extension HTTPBody {
    
    internal class URLParametersData: HTTPEncodableBody {
        
        // MARK: - Public Properties
        
        /// Parameters to encode.
        public var parameters: HTTPRequestParametersDict?
        
        // MARK: - Additional Configuration
        
        /// Specify how array parameter's value are encoded into the request.
        /// By default the `withBrackets` option is used and array are encoded as `key[]=value`.
        public var arrayEncoding: ArrayEncodingStyle = .withBrackets
        
        /// Specify how boolean values are encoded into the request.
        /// The default behaviour is `asNumbers` where `true=1`, `false=0`.
        public var boolEncoding: BoolEncodingStyle = .asNumbers
        
        // MARK: - Initialization
        
        /// Initialize a new `URLParametersData` encoder with given destination.
        ///
        /// - Parameters:
        ///   - destination: destination of the url produced.
        ///   - parameters: parameters to encode.
        internal init(_ parameters: HTTPRequestParametersDict?) {
            self.parameters = parameters
        }
        
        // MARK: - Encoding
        
        public func encodedData() throws -> Data {
            guard let parameters = self.parameters, parameters.isEmpty == false else {
                return Data() // no parameters set
            }
            
            return encodeParameters(parameters).data(using: .utf8) ?? Data()
        }
        
        // MARK: - Private Functions
        
        /// Encode parameters passed and produce a final string.
        ///
        /// - Parameter parameters: parameters.
        /// - Returns: String encoded
        private func encodeParameters(_ parameters: [String: Any]) -> String {
            var components = [(String, String)]()
            
            for key in parameters.keys.sorted(by: <) {
                let value = parameters[key]!
                components += encodeKey(key, withValue: value)
            }
            
            return components.map {
                "\($0)=\($1)"
            }.joinedWithAmpersands()
        }
        
        /// Encode a single object according to settings.
        ///
        /// - Parameters:
        ///   - key: key of the object to encode.
        ///   - value: value to encode.
        /// - Returns: list of encoded components
        private func encodeKey(_ key: String, withValue value: Any) -> [(String, String)] {
            var allComponents: [(String, String)] = []
            
            switch value {
                // Encode a Dictionary
            case let dictionary as [String: Any]:
                for (innerKey, value) in dictionary {
                    allComponents += encodeKey("\(key)[\(innerKey)]", withValue: value)
                }
                
                // Encode an Array
            case let array as [Any]:
                array.forEach {
                    allComponents += encodeKey(arrayEncoding.encode(key), withValue: $0)
                }
                
                // Encode a Number
            case let number as NSNumber:
                if number.isBool {
                    allComponents += [(key.queryEscaped, boolEncoding.encode(number.boolValue).queryEscaped)]
                } else {
                    allComponents += [(key.queryEscaped, "\(number)".queryEscaped)]
                }
                
                // Encode a Boolean
            case let bool as Bool:
                allComponents += [(key.queryEscaped, boolEncoding.encode(bool).queryEscaped)]
                
            default:
                allComponents += [(key.queryEscaped, "\(value)".queryEscaped)]
                
            }
            
            return allComponents
        }
    }
    
}


// MARK: - HTTPRequestBuilder (ArrayEncoding, BoolEncoding)

extension HTTPBody.URLParametersData {
    
    /// Configure how arrays objects must be encoded in a request.
    ///
    /// - `withBrackets`: An empty set of square brackets is appended to the key for every value.
    /// - `noBrackets`: No brackets are appended. The key is encoded as is.
    public enum ArrayEncodingStyle {
        case withBrackets
        case noBrackets
        
        internal func encode(_ key: String) -> String {
            switch self {
            case .withBrackets: return "\(key)[]"
            case .noBrackets:   return key
            }
        }
    }
    
    /// Configures how `Bool` parameters are encoded in a requext.
    ///
    /// - `asNumbers`:  Encode `true` as `1`, `false` as `0`.
    /// - `asLiterals`: Encode `true`, `false` as string literals.
    public enum BoolEncodingStyle {
        case asNumbers
        case asLiterals
        
        internal func encode(_ value: Bool) -> String {
            switch self {
            case .asNumbers:    return value ? "1" : "0"
            case .asLiterals:   return value ? "true" : "false"
            }
        }
        
    }
    
}
