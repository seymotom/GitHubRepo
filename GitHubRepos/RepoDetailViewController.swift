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
    
    let issueDataManager: PRIssueDataManager!
    let prDataManager: PRIssueDataManager!
    
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
        self.issueDataManager = PRIssueDataManager(endpoint: repo.issuesURL)
        self.prDataManager = PRIssueDataManager(endpoint: repo.pullRequestsURL)
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
        issueDataManager.getMoreData {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func loadPullRequests() {
        prDataManager.getMoreData {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func loadDetails() {
        
        navigationItem.title = repo.fullName
        
        repoDetailView.descriptionLabel.text = repo.description
        
        dataManager.getImageData(endpoint: repo.owner.avatarURL) { (data) in
            DispatchQueue.main.async {
                self.repoDetailView.profileImageView.image = UIImage(data: data)
            }
        }
        
        let urls = [repo.issuesURL, repo.pullRequestsURL, repo.branchesURL, repo.commitsURL, repo.releasesURL]
        dataManager.countAllResults(urls: urls) { (detailCounts) in
            DispatchQueue.main.async {
                for count in detailCounts {
                    switch count.0 {
                    case self.repo.issuesURL:
                        self.repoDetailView.issuesLabel.text = "Issues\n\(String(count.1))"
                    case self.repo.pullRequestsURL:
                        self.repoDetailView.pullRequestsLabel.text = "Pull Req.\n\(String(count.1))"
                    case self.repo.branchesURL:
                        self.repoDetailView.branchesLabel.text = "Branches\n\(String(count.1))"
                    case self.repo.commitsURL:
                        self.repoDetailView.commitsLabel.text = "Commits\n\(String(count.1))"
                    case self.repo.releasesURL:
                        self.repoDetailView.releasesLabel.text = "Releases\n\(String(count.1))"
                    default:
                        break
                    }
                }
            }
        }
    }
    
    func toggleEmptyStateView() {
        switch repoDisplayType {
        case.issues:
            if issueDataManager.objects.isEmpty {
                tableView.backgroundView = EmptyStateView(frame: tableView.frame, text: "No Results to Display")
            } else {
                tableView.backgroundView = nil
            }
        case .pullRequests:
            if prDataManager.objects.isEmpty {
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
            return issueDataManager.objects.count
        case .pullRequests:
            toggleEmptyStateView()
            return prDataManager.objects.count
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
                indexPath.row == issueDataManager.objects.count - 1,
                issueDataManager.objects.count < total {
                loadIssues()
            }
        case .pullRequests:
            if let total = totalPullRequests,
                indexPath.row == prDataManager.objects.count - 1,
                prDataManager.objects.count < total {
                loadPullRequests()
            }
        }
    }
    
    func configureCell(_ cell: PRIssueTableViewCell, for indexPath: IndexPath) -> PRIssueTableViewCell {
        let object = repoDisplayType == .issues ? issueDataManager.objects[indexPath.row] : prDataManager.objects[indexPath.row]
        cell.profileImageView.image = nil
        cell.titleLabel.text = object.title
        cell.bodyLabel.text = object.body
        cell.dateLabel.text = object.createdDateString
        cell.userLabel.text = object.user.userName
        cell.backgroundColor = indexPath.row % 2 == 0 ? UIColor.veryLightGray() : .white
        
        dataManager.getImageData(endpoint: object.user.avatarURL) { (data) in
            DispatchQueue.main.async {
                if self.tableView.cellForRow(at: indexPath) == cell {
                    cell.profileImageView.image = UIImage(data: data)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return segmentedControl
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return segmentedControlHeight
    }
    
    // open gitHub for the selected issue or pr
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        let urlString = repoDisplayType == .issues ? issueDataManager.objects[indexPath.row].websiteURL : prDataManager.objects[indexPath.row].websiteURL
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
}

