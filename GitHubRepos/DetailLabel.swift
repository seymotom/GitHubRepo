//
//  DetailLabel.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/17/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class DetailLabel: UILabel {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    private func setup() {
        self.numberOfLines = 2
        self.font = UIFont.systemFont(ofSize: 12)
        self.textAlignment = .center
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 3
        self.clipsToBounds = true
    }
}
