//
//  KXPreviewController.swift
//  Sample
//
//  Created by XYS on 2020/5/24.
//  Copyright © 2020 KongBaiX. All rights reserved.
//

import UIKit

class KXPreviewController: UIViewController {
    
    let imageView: UIImageView = {
        let imageView = UIImageView(frame: UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override func loadView() {
        view = imageView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
}
