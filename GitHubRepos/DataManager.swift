//
//  DataManager.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/14/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation


class DataManager {
    
    var repos: [Repo] = []
    
    private var repoEndpoints: [String] = ["https://api.github.com/repositories"]

    func getMoreRepoData(completion: @escaping () -> Void) {
        APIManager.shared.getData(endpoint: repoEndpoints.last!){ (data: Data, linkHeader: String?) in
            if let repos = Repo.makeRepos(from: data) {
                    self.repos += repos
            }
            if let fullLink = linkHeader,
                let link = Link.getLink(for: .next, linkHeader: fullLink),
                link.urlString != self.repoEndpoints.last! {
                self.repoEndpoints.append(link.urlString)
            }
            completion()
        }
    }

    
    // counts the total number of results from a paginated url
    func countResults(urlString: String, field: RepoField, completion: @escaping (Int) -> Void) {
        
        APIManager.shared.getData(endpoint: urlString) { (data: Data, linkHeader: String?) in
//            print("link: \(String(describing: linkHeader))")
            
            guard let numberOnFirstPage = self.countObjects(in: data) else { return }
            
            guard let fullLink = linkHeader else {
//                print("counting \(field.rawValue), there is only one page and it has \(numberOnFirstPage) entries")
                completion(numberOnFirstPage)
                return
            }
            
            if let lastLink = Link.getLink(for: .last, linkHeader: fullLink),
                let pagesString = lastLink.urlString.components(separatedBy: "=").last,
                let numberOfPages = Int(pagesString) {
                
//                print("counting \(field.rawValue), there are \(numberOfPages) pages")
                let numberOfIssuesExceptLastPage = (numberOfPages - 1) * numberOnFirstPage
//                print("counting \(field.rawValue), except the last page there are \(numberOfIssuesExceptLastPage) entries")
                
                APIManager.shared.getData(endpoint: lastLink.urlString, completion: { (data: Data, linkHeader: String?) in
                    guard let numberOnLastPage = self.countObjects(in: data) else {
//                        print("counting \(field.rawValue), fucked up on last page")
                        return
                    }
                    let totalIssues = numberOfIssuesExceptLastPage + numberOnLastPage
//                    print("counting \(field.rawValue), there is a total number of \(totalIssues) entries")
                    completion(totalIssues)
                })
            }
        }
    }

    private func countObjects(in data: Data) -> Int? {
        do {
            let json: Any = try JSONSerialization.jsonObject(with: data, options: [])
            guard let arr = json as? [[String: AnyObject]] else { return nil }
            return arr.count
        }
        catch let error as NSError {
            print("Error while parsing \(error)")
        }
        return nil
    }
    
    
    
}
