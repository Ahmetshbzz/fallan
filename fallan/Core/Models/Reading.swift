import Foundation

struct Reading: Identifiable, Codable {
    var id: UUID = UUID()
    let date: Date
    let content: String
    let imageID: String
    
    init(content: String, imageID: String) {
        self.date = Date()
        self.content = content
        self.imageID = imageID
    }
} 