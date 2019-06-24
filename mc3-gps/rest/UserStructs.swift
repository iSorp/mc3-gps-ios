// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let users = try? newJSONDecoder().decode(Users.self, from: jsonData)
// https://app.quicktype.io


import Foundation
class UserStructs {
    // MARK: - Users
    struct Users: Codable {
        let embedded: Embedded
        let links: UsersLinks
        let page: Page
        
        enum CodingKeys: String, CodingKey {
            case embedded = "_embedded"
            case links = "_links"
            case page
        }
    }

    // MARK: - Embedded
    struct Embedded: Codable {
        let users: [User]
    }

    // MARK: - User
    struct User: Codable {
        let firstName, lastName: String?
        let links: UserLinks
        
        enum CodingKeys: String, CodingKey {
            case firstName, lastName
            case links = "_links"
        }
    }

    // MARK: - UserLinks
    struct UserLinks: Codable {
        let linksSelf, user: Profile
        
        enum CodingKeys: String, CodingKey {
            case linksSelf = "self"
            case user
        }
    }

    // MARK: - Profile
    struct Profile: Codable {
        let href: String
    }

    // MARK: - UsersLinks
    struct UsersLinks: Codable {
        let linksSelf: SelfClass
        let profile: Profile
        
        enum CodingKeys: String, CodingKey {
            case linksSelf = "self"
            case profile
        }
    }

    // MARK: - SelfClass
    struct SelfClass: Codable {
        let href: String
        let templated: Bool
    }

    // MARK: - Page
    struct Page: Codable {
        let size, totalElements, totalPages, number: Int
    }
}
