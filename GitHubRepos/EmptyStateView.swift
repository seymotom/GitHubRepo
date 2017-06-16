//
//  EmptyStateView.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/16/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class EmptyStateView: UIView {
    
    required convenience init(frame: CGRect, text: String) {
        self.init(frame: frame)
        textLabel.text = text
        self.setupViewHierarchy()
        self.configureConstraints()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViewHierarchy() {
        self.backgroundColor = .white
        self.addSubview(textLabel)
    }
    
    func configureConstraints() {
        textLabel.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.bottom.equalToSuperview().inset(UIScreen.main.bounds.height / 3)
        }
    }
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
}
