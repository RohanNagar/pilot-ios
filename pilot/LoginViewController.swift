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

  let profileImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "ProfileImage")
    imageView.translatesAutoresizingMaskIntoConstraints = false
    imageView.contentMode = .scaleAspectFit
    return imageView
  }()

  let loginRegisterSegmentedControl: UISegmentedControl = {
    let segmentedControl = UISegmentedControl(items: ["Login", "Register"])
    segmentedControl.translatesAutoresizingMaskIntoConstraints = false
    segmentedControl.tintColor = UIColor.white
    segmentedControl.selectedSegmentIndex = 0

    segmentedControl.addTarget(self, action: #selector(updateLoginRegisterView), for: .valueChanged)
    return segmentedControl
  }()

  let inputsContainerView: UIView = {
    let inputsView = UIView()
    inputsView.backgroundColor = UIColor.white
    inputsView.translatesAutoresizingMaskIntoConstraints = false
    inputsView.layer.cornerRadius = 5
    inputsView.layer.masksToBounds = true
    return inputsView
  }()

  let emailTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Email"
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no

    textField.text = "n.eckert70@gmail.com"

    return textField
  }()

  let passwordTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Password"
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.isSecureTextEntry = true

    textField.text = "password"

    return textField
  }()

  let confirmPasswordTextField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Re-type Password"
    textField.translatesAutoresizingMaskIntoConstraints = false
    textField.isSecureTextEntry = true
    return textField
  }()

  let emailSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.LayoutLightGray
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let passwordSeparatorView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.LayoutLightGray
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  let loginRegisterButton: UIButton = {
    let button = UIButton(type: .system)
    button.backgroundColor = UIColor.PilotDarkBlue
    button.setTitle("Login", for: .normal)
    button.setTitleColor(UIColor.TextWhite, for: .normal)
    button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.layer.cornerRadius = 5
    button.layer.masksToBounds = true

    button.addTarget(self, action: #selector(handleButtonAction), for: .touchUpInside)
    return button
  }()

  let activitySpinner: UIActivityIndicatorView = {
    let spinner = UIActivityIndicatorView()
    spinner.translatesAutoresizingMaskIntoConstraints = false
    spinner.hidesWhenStopped = true
    return spinner
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationController?.navigationBar.isHidden = true

    view.backgroundColor = UIColor.PilotLightBlue
    view.addSubview(profileImageView)
    view.addSubview(loginRegisterSegmentedControl)
    view.addSubview(inputsContainerView)
    view.addSubview(loginRegisterButton)
    view.addSubview(activitySpinner)

    setupProfileImageView()
    setupLoginRegisterSegmentedControl()
    setupInputsContainerView()
    setupLoginRegisterButton()
    setupActivitySpinner()

    NetworkManager.sharedInstance.adapter = AuthAdapter()
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func handleButtonAction() {
    if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
      login()
    } else {
      register()
    }
  }

  private func login() {
    if let error = LoginValidationForm(email: emailTextField.text, password: passwordTextField.text).validate() {
      let alert = UIAlertController(title: "Invalid Input", message: error.errorString, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

      present(alert, animated: true, completion: nil)
      return
    }

    let hashedPassword = MD5(passwordTextField.text!).lowercased()

    self.activitySpinner.startAnimating()
    self.loginRegisterButton.isEnabled = false

    PilotUser.fetch(with: ThunderRouter.login(emailTextField.text!, hashedPassword), onSuccess: { pilotUser in
      UserManager.sharedInstance = UserManager(pilotUser: pilotUser)

      let homeTabBarController = HomeTabBarController()

      // Set the platform list in the PlatformManager class
      PlatformManager.sharedInstance.setPlatforms(platforms: pilotUser.availablePlatforms)
      DispatchQueue.main.async { [weak self] in
        self?.activitySpinner.stopAnimating()
        self?.loginRegisterButton.isEnabled = true
        self?.present(homeTabBarController, animated: true, completion: nil)
      }
    }, onError: { _ in
      DispatchQueue.main.async { [weak self] in
        self?.activitySpinner.stopAnimating()
        self?.loginRegisterButton.isEnabled = true
      }
    })
  }

  private func register() {
    if let error = RegisterValidationForm(email: emailTextField.text,
                                          password: passwordTextField.text,
                                          confirmPassword: confirmPasswordTextField.text).validate() {
      let alert = UIAlertController(title: "Invalid Input", message: error.errorString, preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

      present(alert, animated: true, completion: nil)
      return
    }

    self.activitySpinner.startAnimating()
    self.loginRegisterButton.isEnabled = false

    let pilotUser = PilotUser(email: emailTextField.text!, password: passwordTextField.text!)
    PilotUser.upload(with: ThunderRouter.createPilotUser(pilotUser), onSuccess: { _ in
      DispatchQueue.main.async { [weak self] in
        self?.activitySpinner.stopAnimating()
        self?.loginRegisterButton.isEnabled = true
      }
    }, onError: { _ in
      DispatchQueue.main.async { [weak self] in
        self?.activitySpinner.stopAnimating()
        self?.loginRegisterButton.isEnabled = true
      }
    })
  }

  @objc private func updateLoginRegisterView() {

    // Change height of inputsContainerView
    inputsContainerViewHeight?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 80 : 120

    // Change the height of the passwordSeperatorView
    passwordSeperatorViewHeight?.isActive = false
    passwordSeperatorViewHeight = passwordSeparatorView.heightAnchor
      .constraint(equalToConstant: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1)
    passwordSeperatorViewHeight?.isActive = true

    // Change height of the confirmPasswordTextField
    confirmPasswordTextFieldHeight?.isActive = false
    confirmPasswordTextFieldHeight = confirmPasswordTextField.heightAnchor
      .constraint(equalTo: inputsContainerView.heightAnchor,
                  multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
    confirmPasswordTextFieldHeight?.isActive = true

    // Change the height of the emailTextField
    emailTextFieldHeight?.isActive = false
    emailTextFieldHeight =
      emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor,
                  multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    emailTextFieldHeight?.isActive = true

    // Change the height of the passwordTextField
    passwordTextFieldHeight?.isActive = false
    passwordTextFieldHeight = passwordTextField
      .heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor,
                              multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
    passwordTextFieldHeight?.isActive = true

    // Clear the second password field
    confirmPasswordTextField.text = ""

    // Rename button to "Register"
    loginRegisterButton
      .setTitle(loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? "Login": "Register", for: .normal)

    view.layoutIfNeeded()
  }

  private func setupProfileImageView() {
    profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
    profileImageView.heightAnchor.constraint(equalTo: profileImageView.widthAnchor, multiplier: 21/50).isActive = true
    profileImageView.bottomAnchor
      .constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -50).isActive = true
  }

  private func setupLoginRegisterSegmentedControl() {
    loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor).isActive = true
    loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 36).isActive = true
    loginRegisterSegmentedControl.bottomAnchor
      .constraint(equalTo: inputsContainerView.topAnchor, constant: -12).isActive = true
  }

  var inputsContainerViewHeight: NSLayoutConstraint?
  var emailTextFieldHeight: NSLayoutConstraint?
  var passwordTextFieldHeight: NSLayoutConstraint?
  var passwordSeperatorViewHeight: NSLayoutConstraint?
  var confirmPasswordTextFieldHeight: NSLayoutConstraint?

  private func setupInputsContainerView() {

    // Add the subviews to the inputsContainerView
    inputsContainerView.addSubview(emailTextField)
    inputsContainerView.addSubview(passwordTextField)
    inputsContainerView.addSubview(confirmPasswordTextField)
    inputsContainerView.addSubview(passwordSeparatorView)
    inputsContainerView.addSubview(emailSeparatorView)

    // Add constraints to the inputsContainerView
    inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -25).isActive = true
    inputsContainerViewHeight = inputsContainerView.heightAnchor.constraint(equalToConstant: 80)
    inputsContainerViewHeight?.isActive = true

    // Add constraints to the emailTextField
    emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
    emailTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
    emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    emailTextFieldHeight =
      emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
    emailTextFieldHeight?.isActive = true

    // Add constraints to the emailSeperatorView
    emailSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
    emailSeparatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
    emailSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    emailSeparatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true

    // Add constraints to the passwordTextField
    passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
    passwordTextField.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor).isActive = true
    passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    passwordTextFieldHeight =
      passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/2)
    passwordTextFieldHeight?.isActive = true

    // Add constraints to passwordSeperatorView
    passwordSeparatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
    passwordSeparatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
    passwordSeparatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    passwordSeperatorViewHeight = passwordSeparatorView.heightAnchor.constraint(equalToConstant: 0)
    passwordSeperatorViewHeight?.isActive = true

    // Add constraints to confirmPasswordTextField
    confirmPasswordTextField
      .leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
    confirmPasswordTextField.topAnchor.constraint(equalTo: passwordSeparatorView.bottomAnchor).isActive = true
    confirmPasswordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    confirmPasswordTextFieldHeight =
      confirmPasswordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 0)
    confirmPasswordTextFieldHeight?.isActive = true
  }

  private func setupLoginRegisterButton() {
    loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 12).isActive = true
    loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
    loginRegisterButton.heightAnchor.constraint(equalToConstant: 32).isActive = true
  }

  private func setupActivitySpinner() {
    activitySpinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    activitySpinner.topAnchor.constraint(equalTo: loginRegisterButton.bottomAnchor, constant: 20).isActive = true
    activitySpinner.widthAnchor.constraint(equalToConstant: 10).isActive = true
    activitySpinner.heightAnchor.constraint(equalToConstant: 10).isActive = true
  }
}
