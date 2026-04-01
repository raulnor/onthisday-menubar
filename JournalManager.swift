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

    /// Parse YAML frontmatter and extract time and title, returning content without frontmatter
    private func parseFrontmatter(_ content: String) -> (content: String, time: String?, title: String?) {
        let lines = content.components(separatedBy: .newlines)

        var time: String? = nil
        var title: String? = nil
        var contentStartIndex = 0

        // Check for frontmatter
        if lines.first == "---" {
            var endIndex = 1

            // Find the closing ---
            for i in 1..<lines.count {
                if lines[i] == "---" {
                    endIndex = i
                    break
                }

                // Parse time from date field (format: "date: 2026-03-31T21:37")
                if lines[i].hasPrefix("date:") {
                    let dateValue = lines[i].replacingOccurrences(of: "date:", with: "").trimmingCharacters(in: .whitespaces)
                    if let tIndex = dateValue.firstIndex(of: "T") {
                        let timeString = String(dateValue[dateValue.index(after: tIndex)...])
                        time = timeString
                    }
                }
            }

            contentStartIndex = endIndex + 1
        }

        // Remove frontmatter from content
        let contentLines = Array(lines[contentStartIndex...])
        var strippedContent = contentLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)

        // Extract first-level heading as title and remove it from content
        var contentLineArray = strippedContent.components(separatedBy: .newlines)
        for (index, line) in contentLineArray.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            if trimmedLine.hasPrefix("# ") {
                // Extract title, removing the "# " prefix
                title = String(trimmedLine.dropFirst(2)).trimmingCharacters(in: .whitespaces)
                // Remove the title line from content
                contentLineArray.remove(at: index)
                strippedContent = contentLineArray.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }

        return (strippedContent, time, title)
    }
}
