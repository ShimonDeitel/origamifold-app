import Foundation

struct Fold: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var paperType: String = ""
    var difficulty: String = ""
    var notes: String = ""
    var dateAdded: Date = Date()
}
