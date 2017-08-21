//
//  LoginViewController.swift
//  pilot
//
//  Created by Nick Eckert on 7/24/17.
//  Copyright © 2017 sanction. All rights reserved.
//

import UIKit
import SwiftHash

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorField: UILabel!
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    let pilotUserService = PilotUserService() // TODO: Injection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.becomeFirstResponder()
        
        // TEMPORARY for faster login
        self.login(email: "Testy@gmail.com", password: "password")
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
            pilotUserService.getPilotUser(email, password: hashedPassword, completion: { [weak self] pilotUser in
                let homeStoryBoard = UIStoryboard.init(name: "HomeView", bundle: nil)
                let destinationNavigationController = homeStoryBoard.instantiateViewController(withIdentifier: "HomeNavigationController") as! UINavigationController
                
                // Create a new file service and initialize it with the fetched `PilotUser`
                let uploadService = UploadService(pilotUser: pilotUser)
                
                let homeViewController = destinationNavigationController.topViewController as! HomeViewController
                homeViewController.uploadService = uploadService
                homeViewController.availablePlatforms = pilotUser.loadPlatforms()
                
                DispatchQueue.main.async {
                    self?.activitySpinner.stopAnimating()
                    self?.present(destinationNavigationController, animated: true, completion: nil)
                }
            }, failure: { [weak self] httpStatusCode in
                DispatchQueue.main.async { [weak self] in
                    self?.activitySpinner.stopAnimating()
                    self?.errorField.text = httpStatusCode.description
                }
            })
        }
    }
    
    /// Validates that a user email and password are not empty or of invalid format
    ///
    /// - Parameters:
    ///   - email: email associated with a user account
    ///   - password: password associated with a user account
    /// - Returns: wether or not the email or password are valid
    fileprivate func validate(email: String, password: String) -> Bool {
        
        if email.isEmpty || password.isEmpty {
            errorField.text = "Cannot have empty email or password fields"
            
            return false
        }
        
        return true
    }
    
}
