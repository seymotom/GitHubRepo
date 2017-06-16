//
//  RepoTableViewCell.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/14/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class RepoTableViewCell: UITableViewCell {
    
    static let identifier = "RepoCellIdentifier"
    
    let profileWidth: CGFloat = 30
    let margin: CGFloat = 8
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(profileImageView)
        addSubview(repoNameLabel)
        addSubview(descriptionLabel)
    }
    
    func setupConstraints() {
        profileImageView.snp.makeConstraints { (view) in
            view.trailing.equalToSuperview().inset(margin)
            view.width.height.equalTo(profileWidth)
            view.top.equalToSuperview().offset(margin)
        }
        
        repoNameLabel.snp.makeConstraints { (view) in
            view.leading.top.equalToSuperview().offset(margin)
            view.trailing.equalTo(profileImageView.snp.leading).offset(-margin)
        }
        
        descriptionLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(repoNameLabel)
            view.top.equalTo(profileImageView.snp.bottom).offset(margin)
            view.bottom.equalToSuperview().inset(margin)
        }
    }
    
    
    lazy var repoNameLabel: UILabel = {
       let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIView().tintColor
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    var profileImageView: UIImageView = {
        let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 4
        return view
    }()


}
