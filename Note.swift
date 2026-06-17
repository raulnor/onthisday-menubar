import Foundation

struct Note: Identifiable {
    let id = UUID()
    let title: String?
    let content: String
    let filePath: URL
}
