//
//  PostsVC.swift
//  SnapCloneProgramatically
//
//  Created by James Rochabrun on 5/5/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import Foundation
import UIKit

class PostsVC: UIViewController {
    
    let photoImageView: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentMode = .scaleAspectFill
        v.backgroundColor = .blue
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(photoImageView)
        NSLayoutConstraint.activate([
            photoImageView.topAnchor.constraint(equalTo: self.view.topAnchor),
            photoImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            ])
    }
}
