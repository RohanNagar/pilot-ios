//
//  UserManager.swift
//  pilot
//
//  Created by Nick Eckert on 9/27/17.
//  Copyright © 2017 sanction. All rights reserved.
//

import Foundation

class UserManager {

  static var sharedInstance: UserManager!

  fileprivate var authenticationEmail: String?
  fileprivate var authenticationPassword: String?

  fileprivate var pilotUser: PilotUser

  init(pilotUser: PilotUser) {
    self.pilotUser = pilotUser
    self.authenticationEmail = pilotUser.email
    self.authenticationPassword = pilotUser.password
  }

  func getEmail() -> String {
    return pilotUser.email!
  }

  func getAuthenticationEmail() -> String {
    return authenticationEmail!
  }

  func getPassword() -> String {
    return pilotUser.password!
  }

  func getAuthenticationPassword() -> String {
    return authenticationPassword!
  }

  func getFacebookAccessToken() -> String {
    return pilotUser.facebookAccessToken!
  }

  func getTwitterAccessToken() -> String {
    return pilotUser.twitterAccessToken!
  }

  func getTwitterAccessSecret() -> String {
    return pilotUser.twitterAccessSecret!
  }

  func setEmail(newEmail: String?) {
    self.pilotUser.email = newEmail
  }

  func setAuthenticationEmail(newAuthEmail: String?) {
    self.authenticationEmail = newAuthEmail
  }

  func setPassword(newPassword: String?) {
    self.pilotUser.password = newPassword
  }

  func setAuthenticationPassword(newPassword: String?) {
    self.authenticationPassword = newPassword
  }

  func setFacebookAccessToken(token: String?) {
    self.pilotUser.facebookAccessToken = token
  }

  func setTwitterAccessToken(token: String?) {
    self.pilotUser.twitterAccessToken = token
  }

  func setTwitterAccessSecret(secret: String?) {
    self.pilotUser.twitterAccessSecret = secret
  }

  func getAvailablePlatforms() -> [Platform] {
    return pilotUser.availablePlatforms
  }

  func invalidateUser() {
    UserManager.sharedInstance = nil
  }

  typealias SuccessHandler = (PilotUser) -> Void
  typealias ErrorHandler = (Error) -> Void

  func updateUser(onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
    PilotUser.upload(with: ThunderRouter.updatePilotUser(pilotUser), onSuccess: { pilotUser in
      self.pilotUser = pilotUser
      self.authenticationEmail = pilotUser.email
      self.authenticationPassword = pilotUser.password

      onSuccess(pilotUser)
    }, onError: { error in
      onError(error)
    })
  }

  func deleteUser(onSuccess: @escaping SuccessHandler, onError: @escaping ErrorHandler) {
    PilotUser.delete(with: ThunderRouter.deletePilotUser(), onSuccess: { pilotUser in
      onSuccess(pilotUser)
    }, onError: { error in
      onError(error)
    })
  }
}
