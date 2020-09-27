//
//  RegisterController.swift
//  EasyStore
//
//  Created by Oscar Garcia Vazquez on 9/25/20.
//  Copyright © 2020 Oscar Garcia Vazquez. All rights reserved.
//

import Foundation
import UIKit

class RegisterController : UIViewController {
    //MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    private var profileImage : UIImage?
    private var genderSelected = ""
    
    private let plusPhotoButton : UIButton = {
        let btn = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "LoginTFImage")
        
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self,
                      action: #selector(handleAddPhotoPressed),
                      for: .touchUpInside)
        
        return btn
    }()
    
    private let registerButton : UIButton = {
        let btn = Utilities().button(withTitle: "Register")
        btn.addTarget(self,
                      action: #selector(handleRegister),
                      for: .touchUpInside)
        
        return btn
    }()
    
    private let alreadyhaveAccountButton : UIButton = {
        let btn = Utilities().attributedButton("Already have an account?", " Login Up")
        
        btn.addTarget(self,
                      action: #selector(handleShowLogin),
                      for: .touchUpInside)
        
        return btn
    }()
    
    // Containers
    
    private lazy var emailContainer : UIView = {
        let image = #imageLiteral(resourceName: "EmailImageLogo")
        let view = Utilities().inputContainerView(withImage: image,
                                                  textField: emailTF)
        
        return view
    }()
    
    private lazy var firstNameContainer : UIView = {
        let image = #imageLiteral(resourceName: "NamesImage")
        let view = Utilities().inputContainerView(withImage: image,
                                                  textField: firstNameTF)
        return view
    }()
    
    private lazy var lastNameContainer : UIView = {
        let image = #imageLiteral(resourceName: "NamesImage")
        let view = Utilities().inputContainerView(withImage: image,
                                                  textField: lastNameTF)
        return view
    }()
    
    private lazy var dobContainer : UIView = {
        let image = #imageLiteral(resourceName: "CalanderImage")
        let view = Utilities().inputContainerView(withImage: image,
                                                  textField: dobTF)
        
        return view
    }()
    
    private lazy var genderContainer : UIView = {
        let image = #imageLiteral(resourceName: "GenderImageLogo")
        let view = Utilities().inputContainer(withPicker: image, picker: genderPicker)
        
        return view
    }()
    
    private lazy var passwordContainer : UIView = {
        let image = #imageLiteral(resourceName: "PasswordTFImage")
        let view = Utilities().inputContainerView(withImage: image,
                                                  textField: passwordTF)
        return view
    }()
    
    // TextFields
    
    private let emailTF : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Email")
        
        return tf
    }()
    
    private let firstNameTF : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "First Name")
        
        return tf
    }()
    
    
    private let lastNameTF : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Last Name")
        
        return tf
    }()
    
    private let genderPicker : UIPickerView = {
        let picker = UIPickerView()
        
        return picker
    }()
    
    private let genders = ["Prefer Not To Say", "Female", "Male", "Non-Binary"]
    
    private let dobTF : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Enter DOB")
        
        tf.keyboardType = .decimalPad
        
        return tf
    }()
    
    private let passwordTF : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Password")
        
        return tf
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        print("DEBUG: Register Controller Entered")
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        configurePickers()
        view.backgroundColor = .black
        view.addSubview(plusPhotoButton)
        plusPhotoButton.centerX(inView: view,
                                topAnchor: view.safeAreaLayoutGuide.topAnchor)
        plusPhotoButton.setDimensions(width: 150, height: 150)
        
        let stack = UIStackView(arrangedSubviews: [emailContainer,
                                                   firstNameContainer,
                                                   lastNameContainer,
                                                   dobContainer,
                                                   genderContainer,
                                                   passwordContainer,
                                                   registerButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: plusPhotoButton.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 10,
                     paddingLeft: 10,
                     paddingRight: 32)
        configureButtons()
    }
    
    func configureButtons() {
        view.addSubview(alreadyhaveAccountButton)
        alreadyhaveAccountButton.anchor(left: view.leftAnchor,
                                        bottom: view.safeAreaLayoutGuide.bottomAnchor,
                                        right: view.rightAnchor,
                                        paddingLeft: 40,
                                        paddingRight: 40)
    }
    
    func configurePickers() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderPicker.tintColor = .black
    }
    
    //MARK: - Selectore
    
    @objc func handleAddPhotoPressed() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleRegister() {
        let user = User.init(first: firstNameTF.text!,
                             dob: dobTF.text!,
                             email: emailTF.text!,
                             gender: genderSelected,
                             last: lastNameTF.text!,
                             pw: passwordTF.text!)
        
        UserService().registerUser(user: user) { user in
            UserService().uploadProfileImage(token: user.token, image: self.profileImage!)
        }
        
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - API
}

extension RegisterController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let profileImage = info[.editedImage] as? UIImage else { return }
        self.profileImage = profileImage
        
        plusPhotoButton.layer.cornerRadius = 128 / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.imageView?.contentMode = .scaleAspectFill
        plusPhotoButton.imageView?.clipsToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.white.cgColor
        plusPhotoButton.layer.borderWidth = 2
        
        self.plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal),
                                      for: .normal)
        
        dismiss(animated: true, completion: nil)
    }
}

extension RegisterController : UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let gender = genders[row]
        genderSelected = gender
    
        return gender
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: self.genders[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}
