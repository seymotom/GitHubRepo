//
//  APIManager.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/14/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

class APIManager {
        
    static let shared = APIManager()
    private init() {}
    
    func getData(endpoint: String, completion: @escaping (Data, String?) -> Void) {
        guard let myURL = URL(string: endpoint) else { return }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: myURL) { (data: Data?, response: URLResponse?, error: Error?) in
            if error != nil {
                print("Error durring session: \(String(describing: error))")
            }
            
            guard let validData = data else { return }
            
            if let resp = response as? HTTPURLResponse {
                let link: String? = resp.allHeaderFields["Link"] as? String
                completion(validData, link)
            } else {
                completion(validData, nil)
            }
            
            }.resume()
    }
}
