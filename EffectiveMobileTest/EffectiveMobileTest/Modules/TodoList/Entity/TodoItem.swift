import Foundation

struct TodoItem: Equatable {
    let id: Int64
    var title: String
    var description: String
    var createdAt: Date
    var isCompleted: Bool
}
