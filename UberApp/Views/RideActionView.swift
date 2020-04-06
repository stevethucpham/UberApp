//
//  RideActionView.swift
//  UberApp
//
//  Created by iOS Developer on 4/4/20.
//  Copyright © 2020 iOS Developer. All rights reserved.
//

import UIKit
import MapKit

protocol RideActionViewDelegate: class {
    func uploadTrip(destination: MKPlacemark)
}

class RideActionView: UIView {
    
    // MARK: - Properties
    
    var destination: MKPlacemark? {
        didSet {
            titleLabel.text = destination?.name
            addressLabel.text = destination?.address
        }
    }
    
    weak var delegate: RideActionViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Boston Coffee"
        return label
    }()
    
    private let addressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        label.text = "2101 St , NSW , WA"
        return label
    }()
    
    private lazy var logoView: UIView = {
        let logoView = UIView()
        
        let logo = UIView()
        logo.setDimension(height: 60, width: 60)
        logo.layer.cornerRadius = 60/2
        logo.clipsToBounds = true
        logo.backgroundColor = .black
        
        let logoText = UILabel()
        logoText.font = UIFont.systemFont(ofSize: 30)
        logoText.text = "X"
        logoText.textColor = .white
        
        logo.addSubview(logoText)
        logoText.centerY(inView: logo)
        logoText.centerX(inView: logo)
        
        
        let logoTitle = UILabel()
        logoTitle.text = "Uber X"
        logoTitle.font = UIFont.systemFont(ofSize: 18)
        logoTitle.textAlignment = .center
        
        let stackView = UIStackView(arrangedSubviews: [logo, logoTitle])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        
        logoView.addSubview(stackView)
        stackView.centerX(inView: logoView)
        stackView.centerY(inView: logoView)
        
        return logoView
    }()
    
    
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("CONFIRM UBERX", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
        return button
    }()
    
    private let seperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()

    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        addShadow()
        backgroundColor = .white
        
        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, addressLabel])
        titleStackView.axis = .vertical
        titleStackView.alignment = .center
        titleStackView.spacing = 4
        titleStackView.distribution = .fillEqually
        
        addSubview(titleStackView)
        addSubview(logoView)
        addSubview(seperatorView)
        addSubview(confirmButton)
        
        titleStackView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 12)
        
        logoView.anchor(top: titleStackView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 16, height: 95)
        
        seperatorView.anchor(top: logoView.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 5, height: 0.75)
        
        confirmButton.anchor(
                             left: leftAnchor,
                             bottom: safeAreaLayoutGuide.bottomAnchor,
                             right: rightAnchor,
                             paddingLeft: 12,
                             paddingBottom: 24,
                             paddingRight: 12,
                             height: 50)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Selectors
    @objc private func confirmButtonAction() {
        guard let delegate = delegate else { return }
        guard let destination = self.destination else { return }
        delegate.uploadTrip(destination: destination)
    }

    
    // MARK: - Helper functions
}
