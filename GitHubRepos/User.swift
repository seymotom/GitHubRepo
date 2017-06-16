//
//  User.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/14/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

enum UserFields: String {
    case userName = "login"
    case id = "id"
    case avatarURL = "avatar_url"
}

class User {
    let userName: String
    let id: Int
    let avatarURL: String
    
    init(userName: String, id: Int, avatarURL: String) {
        self.userName = userName
        self.id = id
        self.avatarURL = avatarURL
    }
    
    convenience init?(json: [String: AnyObject]) {
        guard
            let userName = json[UserFields.userName.rawValue] as? String,
            let id = json[UserFields.id.rawValue] as? Int,
            let avatarURL = json[UserFields.avatarURL.rawValue] as? String
            else {
                return nil
        }
        self.init(userName: userName, id: id, avatarURL: avatarURL)
    }
}
