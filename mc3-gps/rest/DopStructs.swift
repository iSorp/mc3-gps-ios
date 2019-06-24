// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let dops = try? newJSONDecoder().decode(Dops.self, from: jsonData)
// https://app.quicktype.io

import Foundation

class DopStructs {
    // MARK: - Dop
    struct Dop: Codable {
        let dop: Double
        let date: String
    }

    typealias Dops = [Dop]
}
