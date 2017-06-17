//
//  Link.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/15/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

enum Rel: String {
    case first, last, next, prev
}

struct Link {
    let rel: Rel
    let urlString: String
    
    // returns a link struct of the requested rel type
    static func getLink(for rel: Rel, linkHeader: String) -> Link? {
        let fullLinks = linkHeader.components(separatedBy: ", ")
        for fullLink in fullLinks {
            let splitLink = fullLink.components(separatedBy: "; ")
            let thisRel = Rel(rawValue: String(splitLink[1].characters.dropLast().dropFirst(5)))!
            let urlString = String(splitLink[0].characters.dropLast().dropFirst())
            let link = Link(rel: thisRel, urlString: urlString)
            if link.rel == rel {
                return link
            }
        }
        return nil
    }
}
