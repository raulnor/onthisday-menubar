import Foundation

class JournalManager: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var journalPath: URL?

    private let dateFormatter: DateFormatter
    private let userDefaultsKey = "journalFolderPath"

    init() {
        // Load path from UserDefaults
        if let savedPath = UserDefaults.standard.string(forKey: userDefaultsKey) {
            self.journalPath = URL(fileURLWithPath: savedPath)
        } else {
            self.journalPath = nil
        }

        // Date formatter for parsing file names
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
    }

    func setJournalPath(_ url: URL) {
        self.journalPath = url
        UserDefaults.standard.set(url.path, forKey: userDefaultsKey)
    }

    /// Load all entries for a specific month and day across all years
    func loadEntriesForDate(month: Int, day: Int) {
        entries.removeAll()

        guard let journalPath = journalPath else {
            return
        }

        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(at: journalPath, includingPropertiesForKeys: nil)

            for file in files {
                guard file.pathExtension == "md" else { continue }

                let fileName = file.deletingPathExtension().lastPathComponent

                // Parse the date from filename (format: YYYY-MM-DD-dayone or YYYY-MM-DD)
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
                let fullContent = try String(contentsOf: file, encoding: .utf8)

                // Parse frontmatter and extract time and title
                let (content, time, title) = parseFrontmatter(fullContent)

                let entry = JournalEntry(date: date, time: time, title: title, content: content, filePath: file)
                entries.append(entry)
            }

            // Sort by year (newest first)
            entries.sort { $0.date > $1.date }

        } catch {
            print("Error loading journal entries: \(error)")
        }
    }
}
