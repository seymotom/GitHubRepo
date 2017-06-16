//
//  RepoDetailViewController.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/15/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

enum RepoDisplayType: String {
    case issues, pullRequests
}

class RepoDetailViewController: UIViewController {
    
    var repo: Repo!
    var dataManager: DataManager!
    
    let issueDataManager: IssueDataManager!
    let prDataManager: PRDataManager!
    
    var tableView: UITableView = UITableView()
    var repoDetailView: RepoDetailView!
    let segmentedControl = DetailSegmentedControl()
    
    var repoDisplayType: RepoDisplayType = .issues
    
    var totalIssues: Int?
    var totalPullRequests: Int?
    
    let tableViewHeaderHeight: CGFloat!
    let segmentedControlHeight: CGFloat = 50
    
    
    init(dataManager: DataManager, repo: Repo, descriptionLabelHeight: CGFloat) {
        self.repo = repo
        self.dataManager = dataManager
        self.issueDataManager = IssueDataManager(endpoint: repo.issuesURL)
        self.prDataManager = PRDataManager(endpoint: repo.pullRequestsURL)
        tableViewHeaderHeight = descriptionLabelHeight + RepoDetailView.detailHeight + RepoDetailView.profileImageWidth + (RepoDetailView.standardMargin * 4)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupViews()
        setupConstraints()
        loadIssues()
        loadPullRequests()
        loadDetails()
    }
    
    func setupViews() {
        self.view.addSubview(tableView)
    }
    
    func setupTableView() {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150
        tableView.separatorStyle = .none
        tableView.register(PRIssueTableViewCell.self, forCellReuseIdentifier: PRIssueTableViewCell.identifier)
        repoDetailView = RepoDetailView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableViewHeaderHeight))
        tableView.tableHeaderView = repoDetailView
        repoDetailView.delegate = self
        segmentedControl.delegate = self        
    }
    
    func setupConstraints() {
        self.edgesForExtendedLayout = []
        tableView.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.top.equalToSuperview()
        }
    }
    
    func loadIssues() {
        issueDataManager.getMoreIssueData {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func loadPullRequests() {
        prDataManager.getMorePRData {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func loadDetails() {
        
        navigationItem.title = repo.fullName
        
        repoDetailView.descriptionLabel.text = repo.description
        
        APIManager.shared.getData(endpoint: repo.owner.avatarURL) { (data, _) in
            DispatchQueue.main.async {
                self.repoDetailView.profileImageView.image = UIImage(data: data)
            }
        }
        
        dataManager.countResults(urlString: repo.issuesURL, field: .issuesURL) { (x) in
            DispatchQueue.main.async {
                self.totalIssues = x
                self.repoDetailView.issuesLabel.text = "Issues\n\(String(x))"
            }
        }
        
        dataManager.countResults(urlString: repo.commitsURL, field: .commitsURL) { (x) in
            DispatchQueue.main.async {
                self.repoDetailView.commitsLabel.text = "Commits\n\(String(x))"
            }
        }
        
        dataManager.countResults(urlString: repo.pullRequestsURL, field: .pullRequestsURL) { (x) in
            DispatchQueue.main.async {
                self.totalPullRequests = x
                self.repoDetailView.pullRequestsLabel.text = "Pull Req.\n\(String(x))"
            }
        }
        
        dataManager.countResults(urlString: repo.branchesURL, field: .branchesURL) { (x) in
            DispatchQueue.main.async {
                self.repoDetailView.branchesLabel.text = "Branches\n\(String(x))"
            }
        }
        
        dataManager.countResults(urlString: repo.releasesURL, field: .releasesURL) { (x) in
            DispatchQueue.main.async {
                self.repoDetailView.releasesLabel.text = "Releases\n\(String(x))"
            }
        }
    }
    
    func toggleEmptyStateView() {
        switch repoDisplayType {
        case.issues:
            if issueDataManager.issues.isEmpty {
                tableView.backgroundView = EmptyStateView(frame: tableView.frame, text: "No Results to Display")
            } else {
                tableView.backgroundView = nil
            }
        case .pullRequests:
            if prDataManager.pullRequests.isEmpty {
                tableView.backgroundView = EmptyStateView(frame: tableView.frame, text: "No Results to Display")
            } else {
                tableView.backgroundView = nil
            }
        }
    }
}

extension RepoDetailViewController: DetailSegmentedControlDelegate, RepoDetailViewDelegate {
    func selectedSegmentChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            repoDisplayType = .issues
        }
        else {
            repoDisplayType = .pullRequests
        }
        tableView.reloadData()
    }
}



extension RepoDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch repoDisplayType {
        case .issues:
            toggleEmptyStateView()
            return issueDataManager.issues.count
        case .pullRequests:
            toggleEmptyStateView()
            return prDataManager.pullRequests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PRIssueTableViewCell.identifier, for: indexPath) as! PRIssueTableViewCell
        return configureCell(cell, for: indexPath)
    }
    
    // tableView is scrolled to the bottom. Fetch more results if there are any.
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch repoDisplayType {
        case .issues:
            // if there are more issues to load, load them
            if let total = totalIssues,
                indexPath.row == issueDataManager.issues.count - 1,
                issueDataManager.issues.count < total {
                loadIssues()
            }
        case .pullRequests:
            if let total = totalPullRequests,
                indexPath.row == prDataManager.pullRequests.count - 1,
                prDataManager.pullRequests.count < total {
                loadPullRequests()
            }
        }
    }
    
    func configureCell(_ cell: PRIssueTableViewCell, for indexPath: IndexPath) -> PRIssueTableViewCell {
        switch repoDisplayType {
        case .issues:
            let object = issueDataManager.issues[indexPath.row]
            cell.profileImageView.image = nil
            cell.titleLabel.text = object.title
            cell.bodyLabel.text = object.body
            cell.dateLabel.text = object.createdDateString
            cell.userLabel.text = object.user.userName
            cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.veryLightGray() : .white
            
            APIManager.shared.getData(endpoint: object.user.avatarURL) { (data, _) in
                DispatchQueue.main.async {
                    if self.tableView.cellForRow(at: indexPath) == cell {
                        cell.profileImageView.image = UIImage(data: data)
                    }
                }
            }
            return cell
            
        case .pullRequests:
            let object = prDataManager.pullRequests[indexPath.row]
            cell.profileImageView.image = nil
            cell.titleLabel.text = object.title
            cell.bodyLabel.text = object.body
            cell.dateLabel.text = object.createdDateString
            cell.userLabel.text = object.user.userName
            cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.veryLightGray() : .white
            
            APIManager.shared.getData(endpoint: object.user.avatarURL) { (data, _) in
                DispatchQueue.main.async {
                    if self.tableView.cellForRow(at: indexPath) == cell {
                        cell.profileImageView.image = UIImage(data: data)
                    }
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return segmentedControl
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return segmentedControlHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        switch repoDisplayType {
        case .issues:
            if let url = URL(string: issueDataManager.issues[indexPath.row].websiteURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        case .pullRequests:
            if let url = URL(string: prDataManager.pullRequests[indexPath.row].websiteURL) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }

    
}

