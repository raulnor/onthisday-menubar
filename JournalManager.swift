import Foundation

class JournalManager: ObservableObject {
    @Published var entries: [JournalEntry] = []

    private let journalPath: URL
    private let dateFormatter: DateFormatter

    init() {
        // Path to your journal directory
        self.journalPath = URL(fileURLWithPath: "/Users/travis/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault/journal")

        // Date formatter for parsing file names
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
    }

    /// Load all entries for a specific month and day across all years
    func loadEntriesForDate(month: Int, day: Int) {
        entries.removeAll()

        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(at: journalPath, includingPropertiesForKeys: nil)

            for file in files {
                guard file.pathExtension == "md" else { continue }

                let fileName = file.deletingPathExtension().lastPathComponent

                // Parse the date from filename (format: YYYY-MM-DD-dayone)
                let components = fileName.components(separatedBy: "-")
                guard components.count >= 3,
                      let fileMonth = Int(components[1]),
                      let fileDay = Int(components[2]),
                      fileMonth == month,
                      fileDay == day else {
                    continue
                }

                // Parse full date
                let dateString = "\(components[0])-\(components[1])-\(components[2])"
                guard let date = dateFormatter.date(from: dateString) else { continue }

                // Read file content
                let content = try String(contentsOf: file, encoding: .utf8)

                let entry = JournalEntry(date: date, content: content, filePath: file)
                entries.append(entry)
            }

            // Sort by year (oldest first)
            entries.sort { $0.date < $1.date }

        } catch {
            print("Error loading journal entries: \(error)")
        }
    }
}
