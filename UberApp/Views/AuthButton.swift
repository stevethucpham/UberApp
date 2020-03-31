//
//  AuthButton.swift
//  UberApp
//
//  Created by iOS Developer on 3/31/20.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit

class AuthButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setTitleColor(.white, for: .normal)
        backgroundColor = .mainBlueTint
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
