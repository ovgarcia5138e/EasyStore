//
//  LoginController.swift
//  EasyStore
//
//  Created by Oscar Garcia Vazquez on 9/25/20.
//  Copyright © 2020 Oscar Garcia Vazquez. All rights reserved.
//

import Foundation
import UIKit
import GoogleSignIn

struct KeychainConfiguration {
  static let serviceName = "TouchMeIn"
  static let accessGroup: String? = nil
}

class LoginController : UIViewController {
    //MARK: - Properties
    
    var passwordItems: [KeychainPasswordItem] = []
    let createLoginButtonTag = 0
    let loginButtonTag = 1
    let touchMe = BiometricIDAuth()
    
    private let LogoImageView : UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "StorageLogo")
        
        return iv
    }()
    
    // Containers
    
    private lazy var passwordContainerView : UIView = {
        let image = #imageLiteral(resourceName: "PasswordTFImage")
        let view = Utilities().inputContainerView(withImage: image, textField: passwordTF)
        
        return view
    }()
    
    private lazy var usernameContainerView : UIView = {
        let image = #imageLiteral(resourceName: "LoginTFImage")
        let view = Utilities().inputContainerView(withImage: image, textField: usernameTF)
        
        return view
    }()
    
    // TextFields
    private let usernameTF : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Login")
        
        return tf
    }()
    
    private let passwordTF : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password")
        
        return tf
    }()
    
    // Buttons
    
    private let loginButton : UIButton = {
        let btn = Utilities().button(withTitle: "Login")
        btn.addTarget(self,
                      action: #selector(handleLogin),
                      for: .touchUpInside)
        
        return btn
    }()
    
    private let GoogleLoginButton : GIDSignInButton = {
        let btn = GIDSignInButton()
        
        return btn
    }()
    
    private let touchIDButton : UIButton = {
        let btn = Utilities().button(withTitle: "Face ID")
        btn.addTarget(self,
                      action: #selector(handleTouchIDPressed),
                      for: .touchUpInside)
        btn.backgroundColor = .white
        return btn
    }()
    
    private let dontHaveAccountBtn : UIButton = {
        let button = Utilities().attributedButton("Don't have an account?", " Sign Up")
        
        button.addTarget(self,
                         action: #selector(handleShowSignUp),
                         for: .touchUpInside)
        
        return button
    }()
    
    //MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .black
        
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        
        addLogoImageView()
        addTextFields()
        addButtons()
    }
    
    func addLogoImageView() {
        view.addSubview(LogoImageView)
        LogoImageView.centerX(inView: view,
                              topAnchor: view.safeAreaLayoutGuide.topAnchor)
        LogoImageView.setDimensions(width: 250, height: 250)
    }
    
    func addTextFields() {
        let tfStack = UIStackView(arrangedSubviews: [usernameContainerView,
                                                     passwordContainerView,
                                                     loginButton])
        tfStack.axis = .vertical
        tfStack.spacing = 10
        tfStack.distribution = .fillEqually
        view.addSubview(tfStack)
        tfStack.anchor(top:LogoImageView.bottomAnchor,
                       left: view.leftAnchor,
                       right: view.rightAnchor,
                       paddingLeft: 32, paddingRight: 32)
        
        let thirdParthAuthStack = UIStackView(arrangedSubviews: [GoogleLoginButton, touchIDButton])
        
        thirdParthAuthStack.axis = .horizontal
        thirdParthAuthStack.spacing = 10
        thirdParthAuthStack.distribution = .fillEqually
        
        view.addSubview(thirdParthAuthStack)
        thirdParthAuthStack.anchor(top: tfStack.bottomAnchor,
                       left: view.leftAnchor,
                       right: view.rightAnchor,
                       paddingLeft: 60,
                       paddingRight: 60)
        
        
    }
    
    func addButtons() {
        view.addSubview(dontHaveAccountBtn)
        dontHaveAccountBtn.anchor(left: view.leftAnchor,
                                  bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                  right: view.rightAnchor,
                                  paddingLeft: 40, paddingRight: 40)
    }
    
    func configureFaceLogin() {
        switch touchMe.biometricType() {
        case .faceID:
          touchIDButton.setImage(UIImage(named: "FaceIcon"),  for: .normal)
        default:
          touchIDButton.setImage(UIImage(named: "Touch-icon-lg"),  for: .normal)
        }
    }
    
    func configureLoginButton() {
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
            
        // 2
        if hasLogin {
          loginButton.setTitle("Login", for: .normal)
          loginButton.tag = loginButtonTag
          //createInfoLabel.isHidden = true
        } else {
          loginButton.setTitle("Create", for: .normal)
          loginButton.tag = createLoginButtonTag
          //createInfoLabel.isHidden = false
        }
            
        // 3
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
          usernameTF.text = storedUsername
        }
    }
    
    func checkTF(username : String, token : String) -> Bool {
        guard username == UserDefaults.standard.value(forKey: "username") as? String else {
          return false
        }
          
        do {
          let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                  account: username,
                                                  accessGroup: KeychainConfiguration.accessGroup)
          let keychainPassword = try passwordItem.readPassword()
          return token == keychainPassword
        } catch {
          fatalError("Error reading password from keychain - \(error)")
        }
    }
    
    func checkLogin(token : String?){
        guard let newAccountName = usernameTF.text, let newPassword = token, !newAccountName.isEmpty, !newPassword.isEmpty else {
            showFailedLogin()
            return
        }
        
        usernameTF.resignFirstResponder()
        passwordTF.resignFirstResponder()
        
        if createLoginButtonTag == 0 {
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey && usernameTF.hasText {
                UserDefaults.standard.set(usernameTF.text, forKey: "username")
            }
            
            do {
                let tokenItem = KeychainPasswordItem(service : KeychainConfiguration.serviceName, account: newAccountName, accessGroup: KeychainConfiguration.accessGroup)
                try tokenItem.savePassword(newPassword)
            } catch let err {
                print("Error updating token \(err)")
            }
            
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            
            if checkTF(username: newAccountName, token: newPassword) {
                print("DEBUG: home screen")
            } else {
                showFailedLogin()
            }
        }
    }
    
    func homeScreenNavigation() {
        guard let window = UIApplication.shared.windows.first(where: {$0.isKeyWindow}) else {
            return
        }
        guard let tab = window.rootViewController as? MainTabController else { return }
        tab.authenticateUserAndConfigureUI()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func showFailedLogin() {
        let alertView = UIAlertController(title: "Login Proglem", message: "Wrong username or password.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
    
    //MARK: - Selectors
    
    @objc func handleTouchIDPressed() {
        touchMe.authenticateUser { message in
            
        }
    }
    
    @objc func handleLogin() {
        print(usernameTF.text!)
        print(passwordTF.text!)
        
        UserService().loginUser(email: usernameTF.text!, password: passwordTF.text!) { bool in
            
            bool ? self.homeScreenNavigation() : self.showFailedLogin()
            
        }
    }
    
    @objc func handleShowSignUp() {
        print("DEBUG: Handle Show Sign Up pressed - LoginController")
        let controller = RegisterController()
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    //MARK: - API
}
