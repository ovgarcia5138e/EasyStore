//
//  ChatController.swift
//  EasyStore
//
//  Created by Oscar Garcia Vazquez on 9/27/20.
//  Copyright © 2020 Oscar Garcia Vazquez. All rights reserved.
//

import Foundation
import UIKit

class ChatController : UIViewController {
    //MARK: - Properties
    
    private let imagePicker = UIImagePickerController()
    private var profileImage : UIImage?
    private var genderSelected = ""
    
    private let plusPhotoButton : UIButton = {
        let btn = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "DemensionsLogo")
        
        btn.layer.borderWidth = 3
        btn.layer.borderColor = UIColor.white.cgColor
        btn.setImage(image, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self,
                      action: #selector(handleAddPhotoPressed),
                      for: .touchUpInside)
        
        return btn
    }()
    
    private lazy var pickerContainer : UIView = {
        let image = #imageLiteral(resourceName: "DemensionsLogo")
        let view = Utilities().inputContainer(withPicker: image, picker: itemsPicker)
        
        return view
    }()
    
    private let spaceTypeLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "Indoor Air Conditioned Storage"
        
        return label
    }()
    
    private let priceLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "$4.00 Per Day"
        
        return label
    }()
    
    private let minimumAmountDaysLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.text = "5 Day Minimum"
        
        return label
    }()
    
    private let itemsPicker : UIPickerView = {
        let picker = UIPickerView()
        
        return picker
    }()
    
    private let items = ["Appliance", "Boat",
                         "Couch","Clothes", "Desk",
                         "Electronics", "Trailer"]
    
    private let startDateTF : UITextField  = {
        let tf = Utilities().textField(withPlaceholder: "Enter Start Date")
        
        return tf
    }()
    
    private lazy var startDateContainer : UIView = {
        let image = #imageLiteral(resourceName: "CalanderImage")
        let view = Utilities().inputContainerView(withImage: image, textField: startDateTF)
        
        return view
    }()
    
    private let endDateTF : UITextField  = {
        let tf = Utilities().textField(withPlaceholder: "Enter End Date")
        
        return tf
    }()
    
    private lazy var endDateContainer : UIView = {
        let image = #imageLiteral(resourceName: "CalanderImage")
        let view = Utilities().inputContainerView(withImage: image, textField: endDateTF)
        
        return view
    }()
    
    private let sign : UILabel = {
        let label = UILabel()
        
        label.textAlignment = .center
        label.textColor = .white
        label.text = "What will you be Storing?"
        
        return label
    }()
    
    private let estimateLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        
        return label
    }()
    
    private let requestButton : UIButton = {
        let button = Utilities().button(withTitle: "Request")
        button.addTarget(self,
                         action: #selector(handleRequestPressed),
                         for: .touchUpInside)
        
        return button
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        configureUI()
    }
    
    //MARK: - Helper
    
    func configureUI() {
        configurePicker()
        configureLabels { (stack) in
            self.configurePicture(labels: stack) { (button) in
            }
        }
        configureRequestElements()
    }
    
    func configureLabels(completion: @escaping(UIView) -> Void) {
        let stack = UIStackView(arrangedSubviews: [spaceTypeLabel,
                                                   minimumAmountDaysLabel,
                                                   priceLabel, sign,
                                                   pickerContainer])
        stack.spacing = 10
        stack.axis = .vertical
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.frame = CGRect(x:0, y: 110, width: view.frame.width, height: view.frame.height * 0.30)
        
        completion(stack)
    }
    
    func configurePicker() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        itemsPicker.delegate = self
        itemsPicker.dataSource = self
        itemsPicker.tintColor = .black
    }
    
    func configurePicture(labels : UIView, completion : @escaping(UIView) -> Void) {
        view.addSubview(plusPhotoButton)
        plusPhotoButton.frame = CGRect(x:140, y: view.frame.height * 0.46,
                                       width: view.frame.width / 3,
                                       height: view.frame.height * 0.16)
        
        completion(plusPhotoButton)
    }
    
    func configureRequestElements() {
        let stack = UIStackView(arrangedSubviews: [startDateContainer, endDateContainer,
                                                   estimateLabel, requestButton])
        stack.spacing = 5
        stack.axis = .vertical
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.frame = CGRect(x:0, y: view.frame.height * 0.60,
                             width: view.frame.width,
                             height: view.frame.height * 0.30)
    }
    
    //MARK: - Selector
    
    @objc func handleAddPhotoPressed() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func handleRequestPressed() {
        
    }
    
}

extension ChatController : UIPickerViewAccessibilityDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        print(items[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: self.items[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

extension ChatController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

