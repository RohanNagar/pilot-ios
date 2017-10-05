//
//  Uploadable.swift
//  pilot
//
//  Created by Nick Eckert on 8/28/17.
//  Copyright © 2017 sanction. All rights reserved.
//


import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

// The uploadable protocol will allow an object to be uploaded to lightning as a JSON object.
// (mainly for a PilotUser object to update/create a new user)
protocol Uploadable {

}

extension Uploadable where Self: Mappable {

  typealias SuccessHandler<T> = (T) -> Void where T: Mappable
  typealias ErrorHandler = (Error) -> Void

  static func upload(with request: URLRequestConvertible,
                     onSuccess: @escaping SuccessHandler<Self>,
                     onError: @escaping ErrorHandler) {

    NetworkManager.sharedInstance.request(request).responseObject() { (response: DataResponse<Self>) in

      debugPrint(response)
      switch response.result {
      case .success:
        if let responseObject: Self = response.result.value {
          onSuccess(responseObject)
        }
      case .failure(let error):
        onError(error)
      }
    }

  }

}
