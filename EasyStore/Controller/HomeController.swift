//
//  HomeController.swift
//  EasyStore
//
//  Created by Oscar Garcia Vazquez on 9/26/20.
//  Copyright © 2020 Oscar Garcia Vazquez. All rights reserved.
//

import UIKit
import MapKit

private let reuseIdentifier = "AddressCell"

class HomeController : UIViewController {
    //MARK: - Properties
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults = [MKLocalSearchCompletion]()
    
    var pickerData = [[Int]]()
    private var condition = 0
    
    private lazy var demesnionsContainer : UIView = {
        let image = #imageLiteral(resourceName: "DemensionsLogo")
        let view = Utilities().inputContainer(withPicker: image, picker: demensionsPicker)
        
        return view
    }()
    
    private lazy var priceContainer : UIView = {
        let image = #imageLiteral(resourceName: "PriceLogo")
        let view = Utilities().inputContainerView(withImage: image, textField: priceTF)
        
        return view
    }()
    
    private lazy var daysContainer : UIView = {
        let image = #imageLiteral(resourceName: "CalanderImage")
        let view = Utilities().inputContainerView(withImage: image, textField: daysTF)
        
        return view
    }()
    
    private lazy var renterQuantityContainer : UIView = {
        let image = #imageLiteral(resourceName: "LoginTFImage")
        let view = Utilities().inputContainerView(withImage: image, textField: renterQuantity)
        
        return view
    }()
    
    private let addressTV : UITableView = {
        let table = UITableView()
        
        table.layer.borderWidth = 3
        table.layer.cornerRadius = 10
        table.setDimensions(width: UIScreen.main.bounds.width, height: 180)
        
        return table
    }()
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private var filteredAddresses = [String]() {
        didSet { addressTV.reloadData() }
    }
    
    private let demensionsPicker : UIPickerView = {
        let picker = UIPickerView()
        
        return picker
    }()
    
    private let priceTF : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Price")
        tf.keyboardType = .decimalPad
        
        return tf
    }()
    
    private let daysTF : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Minum Number of Days")
        tf.keyboardType = .decimalPad
        
        return tf
    }()
    
    private let renterQuantity : UITextField = {
        let tf = Utilities().textField(withPlaceholder: "Maximum amout of Renters at once")
        
        return tf
    }()
    
    private let InsideButton : UIButton = {
        let btn = Utilities().button(withTitle: "Inside")
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2
        btn.addTarget(self,
                      action: #selector(handleIndoorsPressed),
                      for: .touchUpInside)
        
        return btn
    }()
    
    private let outsideButtton : UIButton = {
        let btn = Utilities().button(withTitle: "Outside")
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2
        btn.addTarget(self,
                      action: #selector(handleOutdoorsPressed),
                      for: .touchUpInside)
        
        return btn
    }()
    
    private let storageTypeLabel : UILabel = {
        let label = UILabel()
        label.alpha = 0
        
        return label
    }()
    
    private let storageTypeTrue : UIButton = {
        let btn = Utilities().button(withTitle: "Yes")
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2
        btn.alpha = 0
        
        btn.addTarget(self,
                      action: #selector(handleYes),
                      for: .touchUpInside)
        
        return btn
    }()
    
    private let storageTypeFalse : UIButton = {
        let btn = Utilities().button(withTitle: "No")
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2
        btn.alpha = 0
        
        btn.addTarget(self,
                      action: #selector(handleNo),
                      for: .touchUpInside)
        
        return btn
    }()
    
    private let registerSpaceBtn : UIButton = {
        let btn = Utilities().button(withTitle: "Register")
        btn.addTarget(self, action: #selector(handleRegisterPressed), for: .touchUpInside)
        
        return btn
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        print("DEBUG: Testing debug console")
        searchCompleter.delegate = self
        addressTV.delegate = self
        addressTV.dataSource = self
        configureTableView()
        
        super.viewDidLoad()
        demensionsData()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: - Helper
    
    func demensionsData() {
        var demension = [Int]()
        for _ in 0...3 {
            for j in 1...100 {
                demension.append(j)
            }
            pickerData.append(demension)
            demension.removeAll()
        }
    }
    
    func configureUI() {
        setUpPickerView()
        view.backgroundColor = .black
        addContainers { stack in
            self.addButtons(fields: stack) { btns in
                self.addConditions(buttons: btns) { conditions in
                    self.addRegisterBtn(btns: conditions)
                }
            }
        }
    }
    
    func addContainers(completion : @escaping(UIView) -> Void) {
        let stack = UIStackView(arrangedSubviews: [addressTV,
                                                   demesnionsContainer,
                                                   priceContainer,
                                                   daysContainer,
                                                   renterQuantityContainer])
        stack.axis = .vertical
        stack.spacing = 5
        stack.distribution = .fill
        view.addSubview(stack)
        stack.anchor(top: view.topAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 85,
                     paddingLeft: 0, paddingRight: 0)
        completion(stack)
    }
    
    func configureTableView() {
        addressTV.rowHeight = 35
        addressTV.separatorStyle = .singleLine
        
        configureSearchController()
    }
    
    func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.hidesNavigationBarDuringPresentation = true
        addressTV.tableHeaderView = searchController.searchBar
        searchController.searchBar.placeholder = "Search For an Address"
    }
    
    func addButtons(fields : UIView, completion : @escaping(UIView) -> Void) {
        let btnStack = UIStackView(arrangedSubviews: [InsideButton,
                                                      outsideButtton])
        btnStack.axis = .horizontal
        btnStack.spacing = 30
        btnStack.distribution = .fillEqually
        
        view.addSubview(btnStack)
        btnStack.anchor(top: fields.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 20,
                     paddingLeft: 50, paddingRight: 50)
        completion(btnStack)
    }
    
    func addConditions(buttons : UIView, completion : @escaping(UIView) -> Void) {
        view.addSubview(storageTypeLabel)
        storageTypeLabel.centerX(inView: view)
        storageTypeLabel.anchor(top: buttons.bottomAnchor,
                                paddingTop: 20)
        
        let stack = UIStackView(arrangedSubviews: [storageTypeTrue,
                                                   storageTypeFalse])
        stack.axis = .horizontal
        stack.spacing = 30
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: storageTypeLabel.bottomAnchor,
                     left: view.leftAnchor,
                     right: view.rightAnchor,
                     paddingTop: 25,
                     paddingLeft: 50, paddingRight: 50)
        completion(stack)
    }
    
    func addRegisterBtn(btns : UIView) {
        view.addSubview(registerSpaceBtn)
        registerSpaceBtn.anchor(top: btns.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 90, paddingRight: 90)
    }
    
    func setUpPickerView() {
        demensionsPicker.delegate = self
        demensionsPicker.dataSource = self
    }
    
    func conditions(condition : Int) {
        switch condition {
        case 0:
            storageTypeFalse.alpha = 1
            storageTypeTrue.alpha = 1
            storageTypeLabel.alpha = 1
            storageTypeLabel.text = "Is it Air Conditioned?"
            storageTypeLabel.textColor = .twitterBlue
        case 1:
            storageTypeFalse.alpha = 1
            storageTypeTrue.alpha = 1
            storageTypeLabel.alpha = 1
            storageTypeLabel.text = "Is it Covered?"
            storageTypeLabel.textColor = .twitterBlue
        default:
            print("huh")
        }
    }
    
    //MARK: - Selector
    
    @objc func handleIndoorsPressed() {
        conditions(condition: 0)
        condition = 2
    }
    
    @objc func handleOutdoorsPressed() {
        conditions(condition: 1)
        condition = 0
    }
    
    @objc func handleYes() {
        if condition == 0 {
            condition = 1
        } else {
            condition = 3
        }
    }
    
    @objc func handleNo() {
        if condition == 0 {
            condition = 0
        } else {
            condition = 2
        }
    }
    
    
    @objc func handleRegisterPressed() {
        let address = "\(searchResults[addressTV.indexPathForSelectedRow!.row].title) \(searchResults[addressTV.indexPathForSelectedRow!.row].subtitle)"
        
        let space = storageSpace.init(address: address, maxRenters: Int(renterQuantity.text!) ?? 0, location: condition, width: Int(demensionsPicker.selectedRow(inComponent: 0)) , height: Int(demensionsPicker.selectedRow(inComponent: 0)) , length: Int(demensionsPicker.selectedRow(inComponent: 0)) , dailyRate: Int(daysTF.text!) ?? 0)
        
        SpaceServices.shared.uploadSpace(token: (currentUser.user?.token!)!, space: space)
    }
   
    //MARK: - API
}

extension HomeController : UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(pickerData[component][row])
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: String(self.pickerData[component][row]), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
    }
}

extension HomeController : MKLocalSearchCompleterDelegate {
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        addressTV.reloadData()
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
}

extension HomeController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
    
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(searchResults[indexPath.row].title) \(searchResults[indexPath.row].subtitle)")
    }
}

extension HomeController : UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            searchCompleter.queryFragment = searchText
            print(searchResults)
        }
}
