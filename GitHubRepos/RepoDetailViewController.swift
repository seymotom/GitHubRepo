//
//  RepoDetailViewController.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/15/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import UIKit

class RepoDetailViewController: UIViewController {
    
    var repo: Repo!
    var dataManager: DataManager!
    
    let issueDataManager: IssueDataManager!
    let prDataManager: PRDataManager!
    
    init(dataManager: DataManager, repo: Repo) {
        self.repo = repo
        self.dataManager = dataManager
        self.issueDataManager = IssueDataManager(endpoint: repo.issuesURL)
        self.prDataManager = PRDataManager(endpoint: repo.pullRequestsURL)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        dump(repo)
        
        dataManager.countResults(urlString: repo.issuesURL, field: .issuesURL) { (x) in
            print("(RESULT: \(x) issues )")
        }
        
        dataManager.countResults(urlString: repo.commitsURL, field: .commitsURL) { (x) in
            print("(RESULT: \(x) commits )")
        }
        
        dataManager.countResults(urlString: repo.pullRequestsURL, field: .pullRequestsURL) { (x) in
            print("(RESULT: \(x) pullRequests )")
        }
        
        dataManager.countResults(urlString: repo.branchesURL, field: .branchesURL) { (x) in
            print("(RESULT: \(x) branches )")
        }
        
        dataManager.countResults(urlString: repo.releasesURL, field: .releasesURL) { (x) in
            print("(RESULT: \(x) releases )")

        }
        
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
