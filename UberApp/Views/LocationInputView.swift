//
//  LocationInputView.swift
//  UberApp
//
//  Created by iOS Developer on 4/1/20.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit

class LocationInputView: UIView {
    
    // MARK: - Properties
    
    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "baseline_arrow_back_black_36dp-1").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(dismissLocationView),
                         for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Thuc Pham"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .darkGray
        return label
    }()
    
    private let startLocationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 6/2
        return view
    }()
    
    private let linkingView: UIView = {
        let view = UIView()
        view.backgroundColor = .darkGray
        return view
    }()
    
    private let destinationIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var startingLocationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Current Location"
        textField.isEnabled = false
        textField.backgroundColor = .groupTableViewBackground
        textField.font = UIFont.systemFont(ofSize: 14)
        
        let paddingView = UIView()
        paddingView.setDimension(height: 30, width: 8)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    private lazy var destinationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter a destination.."
        textField.backgroundColor = .lightGray
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.returnKeyType = .search
        
        let paddingView = UIView()
        paddingView.setDimension(height: 30, width: 8)
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        return textField
    }()
    
    
    var dismissLocationHandler: (()->())?
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addShadow()
        
        addSubview(backButton)
        backButton.anchor(top: topAnchor, left: leftAnchor, paddingTop: 44,
                          paddingLeft: 12, width: 24, height: 25)
        
        addSubview(titleLabel)
        titleLabel.centerY(inView: backButton)
        titleLabel.centerX(inView: self)
        
        addSubview(startingLocationTextField)
        startingLocationTextField.anchor(top: titleLabel.bottomAnchor,
                                         left: leftAnchor, right: rightAnchor,
                                         paddingTop: 4,
                                         paddingLeft: 40,
                                         paddingRight: 40,
                                         height: 30)
        
        addSubview(destinationTextField)
        destinationTextField.anchor(top: startingLocationTextField.bottomAnchor,
                                         left: leftAnchor, right: rightAnchor,
                                         paddingTop: 12,
                                         paddingLeft: 40,
                                         paddingRight: 40,
                                         height: 30)
        
        addSubview(startLocationIndicatorView)
        startLocationIndicatorView.centerY(inView: startingLocationTextField)
        startLocationIndicatorView.anchor(left: leftAnchor, paddingLeft: 20, width: 6, height: 6)
        
        addSubview(destinationIndicatorView)
        destinationIndicatorView.centerY(inView: destinationTextField)
        destinationIndicatorView.anchor(left: leftAnchor, paddingLeft: 20, width: 6, height: 6)
        
        addSubview(linkingView)
        linkingView.centerX(inView: startLocationIndicatorView)
        linkingView.anchor(top: startLocationIndicatorView.bottomAnchor,
                           bottom: destinationIndicatorView.topAnchor,
                           paddingTop: 4,
                           paddingBottom: 4,
                           width: 0.5)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Selectors
    @objc private func dismissLocationView() {
        guard let dismissHandler = dismissLocationHandler else {  return }
        dismissHandler()
    }
    
}
