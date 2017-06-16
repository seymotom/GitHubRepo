//
//  PRIssueTableViewCell.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/16/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class PRIssueTableViewCell: UITableViewCell {

    static let identifier = "RRIssueCellIdentifier"
    
    let profileWidth: CGFloat = 40
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
        addSubview(titleLabel)
        addSubview(bodyLabel)
        addSubview(userLabel)
        addSubview(dateLabel)
    }
    
    func setupConstraints() {
        profileImageView.snp.makeConstraints { (view) in
            view.leading.equalToSuperview().offset(margin)
            view.width.height.equalTo(profileWidth)
            view.top.equalToSuperview().offset(margin)
        }
        
        userLabel.snp.makeConstraints { (view) in
            view.leading.equalTo(profileImageView.snp.trailing).offset(margin)
            view.trailing.equalToSuperview().offset(-margin)
            view.bottom.equalTo(profileImageView.snp.bottom)
        }
        
        titleLabel.snp.makeConstraints { (view) in
            view.leading.equalToSuperview().offset(margin)
            view.trailing.equalToSuperview().offset(-margin)
            view.top.equalTo(profileImageView.snp.bottom).offset(margin)
        }
        
        bodyLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(titleLabel)
            view.top.equalTo(titleLabel.snp.bottom).offset(margin)
        }
        
        dateLabel.snp.makeConstraints { (view) in
            view.leading.trailing.equalTo(titleLabel)
            view.top.equalTo(bodyLabel.snp.bottom).offset(margin)
            view.bottom.equalToSuperview().offset(-margin)
        }
    }
    
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    lazy var userLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 20)
        label.textColor = UIView().tintColor
        label.textAlignment = .left
        label.lineBreakMode = NSLineBreakMode.byTruncatingTail
        return label
    }()
    
    lazy var bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
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
