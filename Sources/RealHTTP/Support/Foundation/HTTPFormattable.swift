//
//  File.swift
//  
//
//  Created by Daniele Margutti on 26/12/21.
//

import Foundation

public protocol HTTPFormattible {
    
    /// Produce a formatted version sendable along HTTP request.
    ///
    /// - Returns: String
    func httpFormatted() -> String
    
}

extension String: HTTPFormattible {
    
    public func httpFormatted() -> String {
        self
    }
    
}

extension Locale: HTTPFormattible {
    
    public func httpFormatted() -> String {
        identifier
    }
    
}

extension Int: HTTPFormattible {
    
    public func httpFormatted() -> String {
        String(self)
    }
    
}

extension Date: HTTPFormattible {
    
    public func httpFormatted() -> String {
        DateFormatter.http.string(from: self)
    }
    
}

extension DateFormatter {
    
    private func configured(with block: (inout DateFormatter) -> Void) -> DateFormatter {
        var copy = self
        block(&copy)
        return copy
    }

    static let http = DateFormatter().configured {
        $0.calendar = Calendar(identifier: .gregorian)
        $0.timeZone = TimeZone(secondsFromGMT: 0)
        $0.dateFormat = "EEE, dd MMM yyyy HH:mm:ss 'GMT'"
    }
    
}

