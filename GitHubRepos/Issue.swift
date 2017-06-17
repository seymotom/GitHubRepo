//
//  Issue.swift
//  GitHubRepos
//
//  Created by Tom Seymour on 6/16/17.
//  Copyright © 2017 seymotom. All rights reserved.
//

import Foundation

enum PRIssueField: String {
    case websiteURL = "html_url"
    case title = "title"
    case user = "user"
    case number = "number"
    case body = "body"
    case createdDate = "created_at"
    case state = "state"
}

class PRIssue {
    let title: String
    let body: String
    let number: Int
    let user: User
    let websiteURL: String
    let createdDate: Date
    let state: String
    
    var createdDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return "Created at: " + formatter.string(from: self.createdDate)
    }
    
    init(title: String, body: String, number: Int, user: User, websiteURL: String, createdDate: Date, state: String) {
        self.title = title
        self.body = body
        self.number = number
        self.user = user
        self.websiteURL = websiteURL
        self.createdDate = createdDate
        self.state = state
    }
    
    convenience init?(json: [String: AnyObject]) {
        guard
            let title = json[PRIssueField.title.rawValue] as? String,
            let fullBody = json[PRIssueField.body.rawValue] as? String,
            let number = json[PRIssueField.number.rawValue] as? Int,
            let websiteURL = json[PRIssueField.websiteURL.rawValue] as? String,
            let state = json[PRIssueField.state.rawValue] as? String,
            let userDict = json[PRIssueField.user.rawValue] as? [String: AnyObject],
            let user = User(json: userDict),
            let created = json[PRIssueField.createdDate.rawValue] as? String,
            let createdDate = created.dateFromISO8601
        else {
             return nil
        }
        // the body of an issue or pr can be very long. Limit it to 200 charactes.
        let body = fullBody.characters.count > 200 ? String(fullBody.characters.dropLast(fullBody.characters.count - 200)) + "..." : fullBody
        self.init(title: title, body: body, number: number, user: user,
                  websiteURL: websiteURL, createdDate: createdDate, state: state)
    }
    
    // returns an array of Repos from data.
    static func makePRIssues(from data: Data) -> [PRIssue]? {
        do {
            let json: Any = try JSONSerialization.jsonObject(with: data, options: [])
            guard let arr = json as? [[String: AnyObject]] else {
                throw ParseError.fetchingPRIssue
            }
            var prIssues: [PRIssue] = []
            for dict in arr {
                if let prIssue = PRIssue(json: dict) {
                    prIssues.append(prIssue)
                }
            }
            return prIssues
        }
        catch ParseError.fetchingPRIssue {
            print("Error occured while fetching PRIssues")
        }
        catch let error as NSError {
            print("Error while parsing \(error)")
        }
        return nil
    }
    
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return formatter
    }()
}
extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}

extension String {
    var dateFromISO8601: Date? {
        return Formatter.iso8601.date(from: self)
    }
}


