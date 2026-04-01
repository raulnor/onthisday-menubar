import Foundation

struct JournalEntry: Identifiable {
    let id = UUID()
    let date: Date
    let content: String
    let filePath: URL

    var year: Int {
        Calendar.current.component(.year, from: date)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}
