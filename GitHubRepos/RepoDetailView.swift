//
//  RepoDetailView.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/16/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

protocol RepoDetailViewDelegate {
    
}

class RepoDetailView: UIView {
    
    var delegate: RepoDetailViewDelegate?
    
    private let detailMargin: CGFloat = 4.0
    
    static let standardMargin: CGFloat = 8.0
    
    static let detailHeight: CGFloat = 40
    static let profileImageWidth: CGFloat = 100
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        addSubview(profileImageView)
        addSubview(descriptionLabel)
        addSubview(issuesLabel)
        addSubview(commitsLabel)
        addSubview(pullRequestsLabel)
        addSubview(branchesLabel)
        addSubview(releasesLabel)
    }
    
    func setupConstraints() {
        
        profileImageView.snp.makeConstraints { (view) in
            view.centerX.equalToSuperview()
            view.width.height.equalTo(RepoDetailView.profileImageWidth)
            view.top.equalToSuperview().offset(RepoDetailView.standardMargin)
        }
        
        descriptionLabel.snp.makeConstraints { (view) in
            view.top.equalTo(profileImageView.snp.bottom).offset(RepoDetailView.standardMargin)
            view.leading.equalToSuperview().offset(RepoDetailView.standardMargin)
            view.trailing.equalToSuperview().offset(-RepoDetailView.standardMargin)
            view.bottom.equalTo(issuesLabel.snp.top).offset(-RepoDetailView.standardMargin)
        }
        
        let screenWidth = UIScreen.main.bounds.width
        let detailWidth = (screenWidth - (4 * detailMargin) - (2 * RepoDetailView.standardMargin)) / 5
        
        issuesLabel.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().offset(-RepoDetailView.standardMargin)
            view.leading.equalToSuperview().offset(RepoDetailView.standardMargin)
            view.width.equalTo(detailWidth)
            view.height.equalTo(RepoDetailView.detailHeight)
        }
        
        pullRequestsLabel.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().offset(-RepoDetailView.standardMargin)
            view.leading.equalTo(issuesLabel.snp.trailing).offset(detailMargin)
            view.width.equalTo(detailWidth)
            view.height.equalTo(RepoDetailView.detailHeight)
        }
        
        commitsLabel.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().offset(-RepoDetailView.standardMargin)
            view.leading.equalTo(pullRequestsLabel.snp.trailing).offset(detailMargin)
            view.width.equalTo(detailWidth)
            view.height.equalTo(RepoDetailView.detailHeight)
        }
        
        branchesLabel.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().offset(-RepoDetailView.standardMargin)
            view.leading.equalTo(commitsLabel.snp.trailing).offset(detailMargin)
            view.width.equalTo(detailWidth)
            view.height.equalTo(RepoDetailView.detailHeight)
        }
        
        releasesLabel.snp.makeConstraints { (view) in
            view.bottom.equalToSuperview().offset(-RepoDetailView.standardMargin)
            view.leading.equalTo(branchesLabel.snp.trailing).offset(detailMargin)
            view.width.equalTo(detailWidth)
            view.height.equalTo(RepoDetailView.detailHeight)
        }
    }
    
    // MARK: Lazy UI
    
    lazy var profileImageView: UIImageView = {
       let view = UIImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
       label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    
    // TODO: Refactor the repeated code
    
    lazy var issuesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }()

    lazy var commitsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }()
    
    lazy var pullRequestsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }()
    
    lazy var branchesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }()
    
    lazy var releasesLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }()
    

}
