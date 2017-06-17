//
//  IssueDataManager.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/16/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

class PRIssueDataManager {
    
    private var endpoints: [String]!
    
    var objects: [PRIssue] = []
    
    init(endpoint: String) {
        self.endpoints = [endpoint]
    }
    
    func getMoreData(completion: @escaping () -> Void) {
        APIManager.shared.getData(endpoint: endpoints.last!){ (data: Data, linkHeader: String?) in
            if let prIssues = PRIssue.makePRIssues(from: data) {
                self.objects += prIssues
            }
            if let fullLink = linkHeader,
                let link = Link.getLink(for: .next, linkHeader: fullLink),
                link.urlString != self.endpoints.last! {
                self.endpoints.append(link.urlString)
            }
            completion()
        }
    }
}
