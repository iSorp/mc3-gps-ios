// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let locations = try? newJSONDecoder().decode(Locations.self, from: jsonData)
// https://app.quicktype.io

import Foundation

class LocationStructs {
    // MARK: - Locations
    struct Locations: Codable {
        let embedded: Embedded
        let links: LocationsLinks
        let page: Page
        
        enum CodingKeys: String, CodingKey {
            case embedded = "_embedded"
            case links = "_links"
            case page
        }
    }

    // MARK: - Embedded
    struct Embedded: Codable {
        let locations: [Location]
    }

    // MARK: - Location
    struct Location: Codable {
        let longitude, latitude, altitude: Double
        let timestamp: String
        let links: LocationLinks
        
        enum CodingKeys: String, CodingKey {
            case longitude, latitude, altitude, timestamp
            case links = "_links"
        }
    }

    // MARK: - LocationLinks
    struct LocationLinks: Codable {
        let linksSelf, location, user: Profile
        
        enum CodingKeys: String, CodingKey {
            case linksSelf = "self"
            case location, user
        }
    }

    // MARK: - Profile
    struct Profile: Codable {
        let href: String
    }

    // MARK: - LocationsLinks
    struct LocationsLinks: Codable {
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
