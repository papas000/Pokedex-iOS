import Foundation


//NOT NEEDED
struct Response: Codable {
    var count: Int
    var next: String?
    var previous: String?
    var results: [Pokemon]
}
