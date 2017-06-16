//
//  Repo.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/14/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

enum RepoField: String {
    case name = "name"
    case fullName = "full_name"
    case owner = "owner"
    case description = "description"
    case issuesURL = "issues_url"
    case commitsURL = "commits_url"
    case pullRequestsURL = "pulls_url"
    case releasesURL = "releases_url"
    case branchesURL = "branches_url"
}

class Repo {
    let name: String
    let fullName: String
    let owner: User
    let description: String
    let issuesURL: String
    let commitsURL: String
    let pullRequestsURL: String
    let releasesURL: String
    let branchesURL: String
    
    init(name: String, fullName: String, owner: User, description: String,
         issuesURL: String, commitsURL: String, pullRequestsURL: String,
         releasesURL: String, branchesURL: String) {
        self.name = name
        self.fullName = fullName
        self.owner = owner
        self.description = description
        self.issuesURL = issuesURL
        self.commitsURL = commitsURL
        self.pullRequestsURL = pullRequestsURL
        self.releasesURL = releasesURL
        self.branchesURL = branchesURL
    }
    
    convenience init?(json: [String: AnyObject]) {
        guard
            let name = json[RepoField.name.rawValue] as? String,
            let fullName = json[RepoField.fullName.rawValue] as? String,
            let ownerDict = json[RepoField.owner.rawValue] as? [String: AnyObject],
            let owner = User(json: ownerDict),
            let description = json[RepoField.description.rawValue] as? String,
            let issues = json[RepoField.issuesURL.rawValue] as? String,
            let commits = json[RepoField.commitsURL.rawValue] as? String,
            let pullRequests = json[RepoField.pullRequestsURL.rawValue] as? String,
            let releases = json[RepoField.releasesURL.rawValue] as? String,
            let branches = json[RepoField.branchesURL.rawValue] as? String
            else {
                return nil
        }
        // trimming the end from the url to make it fetch all results.
        let issuesURL = String(issues.characters.dropLast(9))
        let commitsURL = String(commits.characters.dropLast(6))
        let pullRequestsURL = String(pullRequests.characters.dropLast(9))
        let releasesURL = String(releases.characters.dropLast(5))
        let branchesURL = String(branches.characters.dropLast(9))
        
        self.init(name: name, fullName: fullName, owner: owner, description: description,
                  issuesURL: issuesURL, commitsURL: commitsURL, pullRequestsURL: pullRequestsURL,
                  releasesURL: releasesURL, branchesURL: branchesURL)
    }
    
    // returns an array of Repos from data.
    static func makeRepos(from data: Data) -> [Repo]? {
        do {
            let json: Any = try JSONSerialization.jsonObject(with: data, options: [])
            guard let arr = json as? [[String: AnyObject]] else { return nil }
            var repos: [Repo] = []
            for dict in arr {
                if let repo = Repo(json: dict) {
                    repos.append(repo)
                }
            }
            return repos
        }
        catch let error as NSError {
            print("Error while parsing \(error)")
        }
        return nil
    }

}

