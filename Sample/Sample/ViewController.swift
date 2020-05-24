//
//  ViewController.swift
//  Sample
//
//  Created by XYS on 2020/5/24.
//  Copyright © 2020 KongBaiX. All rights reserved.
//

import UIKit
import KXPageController

class ViewController: UIViewController, KXPageDelegate {
    
    let pageController: KXPageController = {
        let controller = KXPageController()
        controller.bounces = true
        return controller
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        loadSubviews()
        addChild(pageController)
        pageController.delegate = self
        let controller = KXPreviewController()
        controller.image = #imageLiteral(resourceName: "smaple_001")
        pageController.setController(controller)
    }
    
    func loadSubviews() {
        view.addSubview(pageController.view)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func pageControllerDidLoadLeftController(_ currentController: UIViewController) -> UIViewController? {
        let controller = KXPreviewController()
        controller.image = #imageLiteral(resourceName: "smaple_001")
        return controller
    }
    
    
    func pageControllerDidLoadRightController(_ currentController: UIViewController) -> UIViewController? {
        let controller = KXPreviewController()
        controller.image = #imageLiteral(resourceName: "smaple_001")
        return controller
    }
}

