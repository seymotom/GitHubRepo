//
//  DetailSegmentedControl.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/16/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

protocol DetailSegmentedControlDelegate {
    func selectedSegmentChanged(sender: UISegmentedControl)
}

class DetailSegmentedControl: UIView {
    
    let segment = UISegmentedControl(items: ["Issues", "Pull Requests"])
    
    let standardMargin = 8.0
    
    var delegate: DetailSegmentedControlDelegate!

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupSegment()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSegment() {
        segment.selectedSegmentIndex = 0
        segment.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segment.backgroundColor = .white
        addSubview(segment)
        segment.snp.makeConstraints { (view) in
            view.leading.top.equalToSuperview().offset(standardMargin)
            view.trailing.bottom.equalToSuperview().offset(-standardMargin)
        }
    }
    
    func segmentChanged(sender: UISegmentedControl) {
        delegate.selectedSegmentChanged(sender: sender)
    }

}
