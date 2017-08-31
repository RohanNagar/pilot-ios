//
//  PilotConfiguration.swift
//  pilot
//
//  Created by Nick Eckert on 7/25/17.
//  Copyright © 2017 sanction. All rights reserved.
//

import Foundation

struct PilotConfiguration {
    
    struct Thunder {
        static let host = "http://thunder.sanctionco.com"
        static let userKey = "lightning"
        static let userSecret = "secret"
        static let basicCredentials = "\(userKey):\(userSecret)".data(using: String.Encoding.utf8)!.base64EncodedString(options: [])
    }
    
    struct Lightning {
        static let host = "http://lightning.sanctionco.com"
        static let userKey = "application"
        static let userSecret = "secret"
        static let basicCredentials = "\(userKey):\(userSecret)".data(using: String.Encoding.utf8)!.base64EncodedString(options: [])
    }
    
}
