//
//  PRDataManager.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/16/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

class PRDataManager {
    
    private var prEndpoints: [String]!
    
    var pullRequests: [PullRequest] = []
    
    init(endpoint: String) {
        self.prEndpoints = [endpoint]
    }
    
    func getMorePRData(completion: @escaping () -> Void) {
        APIManager.shared.getData(endpoint: prEndpoints.last!){ (data: Data, linkHeader: String?) in
            if let pullRequests = PullRequest.makePullRequests(from: data) {
                self.pullRequests += pullRequests
            }
            if let fullLink = linkHeader,
                let link = Link.getLink(for: .next, linkHeader: fullLink),
                link.urlString != self.prEndpoints.last! {
                self.prEndpoints.append(link.urlString)
            }
            completion()
        }
    }
}
