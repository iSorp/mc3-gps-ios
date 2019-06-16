// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)
// //  https://app.quicktype.io

import Foundation

class UserStructs {
// MARK: - Welcome
struct Welcome: Codable {
    let embedded: Embedded
    let links: WelcomeLinks
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
    let firstName: String
    let lastName: JSONNull?
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

// MARK: - WelcomeLinks
struct WelcomeLinks: Codable {
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

// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
}
