//
//  ReposViewController.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/14/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit
import SnapKit

class ReposViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView = UITableView()
    
    let dataManager: DataManager!
    
    init(dataManager: DataManager) {
        self.dataManager = dataManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "GitHub Repositories"
        setupTableView()
        setupViews()
        setupConstraints()
        getMoreRepoData()
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
        tableView.register(RepoTableViewCell.self, forCellReuseIdentifier: RepoTableViewCell.identifier)
    }
    
    func setupConstraints() {
        self.edgesForExtendedLayout = []
        
        tableView.snp.makeConstraints { (view) in
            view.leading.trailing.bottom.top.equalToSuperview()
        }
    }
    
    func getMoreRepoData() {
        dataManager.getMoreRepoData() {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.repos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RepoTableViewCell.identifier, for: indexPath) as! RepoTableViewCell
        return configureCell(cell, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == dataManager.repos.count - 1 {
            getMoreRepoData()
        }
    }
    
    func configureCell(_ cell: RepoTableViewCell, for indexPath: IndexPath) -> RepoTableViewCell {
        let repo = dataManager.repos[indexPath.row]
        cell.profileImageView.image = nil
        cell.repoNameLabel.text = repo.fullName
        cell.descriptionLabel.text = repo.description
        
        let veryLightGray = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        cell.backgroundColor = indexPath.row % 2 == 0 ? veryLightGray : .white
        
        APIManager.shared.getData(endpoint: repo.owner.avatarURL) { (data, _) in
            DispatchQueue.main.async {
                if self.tableView.cellForRow(at: indexPath) == cell {
                    cell.profileImageView.image = UIImage(data: data)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? RepoTableViewCell {
            let descriptionLabelHeight = cell.descriptionLabel.frame.height
            
            let detailVC = RepoDetailViewController(dataManager: dataManager, repo: dataManager.repos[indexPath.row], descriptionLabelHeight: descriptionLabelHeight)
            if let navVC = navigationController {
                navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
                navVC.pushViewController(detailVC, animated: true)
            }
            
        }
    }

}
