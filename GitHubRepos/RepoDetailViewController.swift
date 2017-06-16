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
    
    var repoDisplayType: RepoDisplayType = .issues
    
    let tableViewHeaderHeight: CGFloat!
    let segmentedControlHeight: CGFloat = 50
    
    let segmentedControl = DetailSegmentedControl()
    
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
    
    
    func testCalls() {
        
        issueDataManager.getMoreIssueData {
            print("\n list of issues...")
            dump(self.issueDataManager.issues)
        }
        
        prDataManager.getMorePRData {
            print("\n list of pull requests...")
            dump(self.prDataManager.pullRequests)
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
            return issueDataManager.issues.count
        case .pullRequests:
            return prDataManager.pullRequests.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PRIssueTableViewCell.identifier, for: indexPath) as! PRIssueTableViewCell
        return configureCell(cell, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        switch repoDisplayType {
        case .issues:
            if indexPath.row == issueDataManager.issues.count - 1 {
                print("GET MORE DATA")
            }
        case .pullRequests:
            if indexPath.row == prDataManager.pullRequests.count - 1 {
                print("GET MORE DATA")
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
            
            let veryLightGray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            cell.backgroundColor = indexPath.row % 2 == 0 ? veryLightGray : .white
            
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
            
            let veryLightGray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
            cell.backgroundColor = indexPath.row % 2 == 0 ? veryLightGray : .white
            
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

    
}

