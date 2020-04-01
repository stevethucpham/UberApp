//
//  LocationInputActivationView.swift
//  UberApp
//
//  Created by iOS Developer on 4/1/20.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit

class LocationInputActivationView: UIView {
    
    // MARK: - Properties
    
    private let indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    
    private let placeholderLabel: UIView = {
        let label = UILabel()
        label.text = "Where to?"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .darkGray
        return label
    }()
    
    var presentInputView: (() -> ())?
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        addShadow()
            
        addSubview(indicatorView)
        indicatorView.centerY(inView: self, leftAnchor: leftAnchor, paddingLeft: 16)
        indicatorView.setDimension(height: 6, width: 6)
        
        addSubview(placeholderLabel)
        placeholderLabel.centerY(inView: self, leftAnchor: indicatorView.rightAnchor, paddingLeft: 20)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(presentLocationInputView))
        addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  Selectors
    @objc private func presentLocationInputView() {
        guard let inputView = presentInputView else { return }
        inputView()
    }

}
