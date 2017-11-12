//
//  LoginViewController.swift
//  pilot
//
//  Created by Nick Eckert on 7/24/17.
//  Copyright © 2017 sanction. All rights reserved.
//

import Alamofire
import HTTPStatusCodes
import SwiftHash
import UIKit

class LoginViewController: UIViewController {

  @IBOutlet weak var emailField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var errorField: UILabel!
  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
  @IBOutlet weak var loginButton: UIButton!

  override func viewDidLoad() {
    super.viewDidLoad()

    emailField.becomeFirstResponder()

    styleUI()

    // TEMPORARY for faster login
    self.emailField.text = "Testy@gmail.com"
    self.passwordField.text = "password"

    // Set a request adapter for future network calls
    NetworkManager.sharedInstance.adapter = AuthAdapter()
  }

  func styleUI() {

    // Button Style Properties
    loginButton.layer.cornerRadius = 4
    loginButton.layer.backgroundColor = UIColor.ButtonBlue.cgColor

  }

  @IBAction func signUp(_ sender: UIButton) {
    let createStoryBoard = UIStoryboard.init(name: "CreateView", bundle: nil)
    let createViewController = createStoryBoard.instantiateViewController(withIdentifier: "CreateViewController")

    self.navigationController?.pushViewController(createViewController, animated: true)
  }

  @IBAction func login(_ sender: UIButton) {
    login(email: emailField.text, password: passwordField.text)
  }

  /// Logs a user in using and email and password
  ///
  /// - Parameters:
  ///   - email: email associated with a user account
  ///   - password: password associated with a user account
  func login(email: String?, password: String?) {

    guard let email = email, let password = password else { return }

    if validate(email: email, password: password) {
      let hashedPassword = MD5(password).lowercased()

      activitySpinner.startAnimating()
      loginButton.isEnabled = false

      // Make the request
      PilotUser.fetch(with: ThunderRouter.login(email, hashedPassword), onSuccess: { pilotUser in

        UserManager.sharedInstance = UserManager(pilotUser: pilotUser)

        // Set the platform list in the PlatformManager class
        PlatformManager.sharedInstance.setPlatforms(platforms: pilotUser.availablePlatforms)
        for platform in pilotUser.availablePlatforms {
          print(platform.type.rawValue)
        }

        let homeStoryBoard = UIStoryboard.init(name: "HomeView", bundle: nil)
        if let destinationNavigationController = homeStoryBoard
          .instantiateViewController(withIdentifier: "HomeNavigationController") as? UINavigationController {

          DispatchQueue.main.async { [weak self] in
            self?.activitySpinner.stopAnimating()
            self?.loginButton.isEnabled = true
            self?.present(destinationNavigationController, animated: true, completion: nil)
          }
        }
      }, onError: { error in
        DispatchQueue.main.async { [weak self] in
          self?.activitySpinner.stopAnimating()
          self?.loginButton.isEnabled = true
          self?.errorField.text = error.localizedDescription
        }
      })

    }
  }

  /// Validates that required fields are filled
  ///
  /// - Parameters:
  ///   - email: email associated with a user account
  ///   - password: password associated with a user account
  /// - Returns: wether or not the email or password are valid
  fileprivate func validate(email: String, password: String) -> Bool {

    if email.isEmpty || password.isEmpty {
      let alert = UIAlertController(title: "Invalid Input",
                                    message: "Cannot have empty email or password fields",
                                    preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

      present(alert, animated: true, completion: nil)
      return false
    }

    return true
  }

}
