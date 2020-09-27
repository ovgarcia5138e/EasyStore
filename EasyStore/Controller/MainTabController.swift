//
//  MainTabController.swift
//  EasyStore
//
//  Created by Oscar Garcia Vazquez on 9/25/20.
//  Copyright © 2020 Oscar Garcia Vazquez. All rights reserved.
//

import UIKit

class MainTabController : UITabBarController {
    // MARK: - Properties
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
        authenticateUserAndConfigureUI()
    }
    
    // MARK: - Helpers
    
    func authenticateUserAndConfigureUI() {
        if currentUser.user?.token == nil {
            DispatchQueue.main.async {
                let nav = UINavigationController(rootViewController: LoginController())
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        } else {
            configureUI()
        }
    }
    
    func configureUI() {
        view.backgroundColor = .blue
        print("DEBUG: Made it")
        configureControllers()
    }
    
    func configureControllers() {
        let feed = HomeController()
        let nav1 = templateNavigationController(name: "Create",
                                                rootViewController: feed)
        
        let search = SearchController()
        let nav2 = templateNavigationController(name: "Search", rootViewController: search)
        
        let chat = ChatController()
        let nav3 = templateNavigationController(name: "Request",
                                                rootViewController: chat)
        
        viewControllers = [nav1, nav2, nav3]
    }
    
    func templateNavigationController(name : String, rootViewController : UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        
        nav.tabBarItem.title = name
        nav.navigationBar.barTintColor = .black
        
        return nav
    }
    
    // MARK: - Selectors
    
    // MARK: - API
}
