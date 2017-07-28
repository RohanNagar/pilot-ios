//
//  FileService.swift
//  pilot
//
//  Created by Nick Eckert on 7/26/17.
//  Copyright © 2017 sanction. All rights reserved.
//

import Foundation
import Alamofire

protocol FileService {
    var pilotUser: PilotUser! { get set }
    var basicCredentials: String { get }
    
    init(pilotUser: PilotUser)
}

extension FileService {
    
    func upload(_ files: [URL], to url: String) {
        for file in files {
            upload(file, to: url)
        }
    }
    
    func upload(_ file: URL, to url: String) {
        // Build the authorization headers for the request
        let headers = ["Authorization": "Basic \(basicCredentials)",
            "password": "\(pilotUser.password)"]
        
        // TODO: get type from file
        let type = "photo"
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(file, withName: "file")
        },
            to: "\(url)?email=\(pilotUser.email)&type=\(type)",
            headers: headers,
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseString { response in
                        debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }
    
}
