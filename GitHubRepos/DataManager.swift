//
//  DataManager.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/14/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

enum ParseError: Error {
    case countObjectError
    case fetchingReposError
    case fetchingPRIssue
}

class DataManager {
    
    var repos: [Repo] = []
    
    private var repoEndpoints: [String] = ["https://api.github.com/repositories"]
    
    func getImageData(endpoint: String, completion: @escaping (Data) -> Void) {
        APIManager.shared.getData(endpoint: endpoint) { (data, _) in
            completion(data)
        }
    }

    func getMoreRepoData(completion: @escaping () -> Void) {
        APIManager.shared.getData(endpoint: repoEndpoints.last!) { (data: Data, linkHeader: String?) in
            if let repos = Repo.makeRepos(from: data) {
                    self.repos += repos
            }
            // get the next url frm the link header and append it to the array of endpoints
            if let fullLink = linkHeader,
                let link = Link.getLink(for: .next, linkHeader: fullLink),
                link.urlString != self.repoEndpoints.last! {
                self.repoEndpoints.append(link.urlString)
            }
            completion()
        }
    }
    
    func countAllResults(urls: [String], completion: @escaping ([(String, Int)]) -> Void) {
        var results: [(url: String, count: Int)] = [] {
            didSet {
                // wait for all results to come back before completion
                if results.count == urls.count {
                    completion(results)
                }
            }
        }
        for url in urls {
            countResults(urlString: url) { (url, count) in
                results.append((url, count))
            }
        }
    }
 
    // counts the total number of results from a paginated url
    private func countResults(urlString: String, completion: @escaping ((String, Int)) -> Void) {
        
        APIManager.shared.getData(endpoint: urlString) { (data: Data, linkHeader: String?) in
            // count number of results on the first page
            guard let numberOnFirstPage = self.countObjects(in: data) else { return }
            // if there is no link header just completion the first page count
            guard let fullLink = linkHeader else {
                completion(urlString, numberOnFirstPage)
                return
            }
            // gets the link for the last page
            if let lastLink = Link.getLink(for: .last, linkHeader: fullLink),
                let pagesString = lastLink.urlString.components(separatedBy: "=").last,
                let numberOfPages = Int(pagesString) {
                
                let numberOfIssuesExceptLastPage = (numberOfPages - 1) * numberOnFirstPage
                // gets the last page and count those results
                APIManager.shared.getData(endpoint: lastLink.urlString, completion: { (data: Data, linkHeader: String?) in
                    guard let numberOnLastPage = self.countObjects(in: data) else {
                        return
                    }
                    let totalIssues = numberOfIssuesExceptLastPage + numberOnLastPage
                    completion(urlString, totalIssues)
                })
            }
        }
    }

    private func countObjects(in data: Data) -> Int? {
        do {
            let json: Any = try JSONSerialization.jsonObject(with: data, options: [])
            guard let arr = json as? [[String: AnyObject]] else {
                throw ParseError.countObjectError
            }
            return arr.count
        }
        catch ParseError.countObjectError {
            print("Error occured while counting objects.")
        }
        catch let error as NSError {
            print("Error while parsing \(error)")
        }
        return nil
    }
}
