//
//  IssueDataManager.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/16/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

class IssueDataManager {
    
    private var issueEndpoints: [String]!
    
    var issues: [Issue] = []
    
    init(endpoint: String) {
        self.issueEndpoints = [endpoint]
    }
    
    func getMoreIssueData(completion: @escaping () -> Void) {
        APIManager.shared.getData(endpoint: issueEndpoints.last!){ (data: Data, linkHeader: String?) in
            if let issues = Issue.makeIssues(from: data) {
                self.issues += issues
            }
            if let fullLink = linkHeader,
                let link = Link.getLink(for: .next, linkHeader: fullLink),
                link.urlString != self.issueEndpoints.last! {
                self.issueEndpoints.append(link.urlString)
            }
            completion()
        }
    }
}
