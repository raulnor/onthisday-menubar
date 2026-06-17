import Foundation

class NoteManager: ObservableObject {
    @Published var notes: [Note] = []
    @Published var notesFolderURL: URL?

    private let userDefaultsKey = "notesFolderPath"

    init() {
        // Load path from UserDefaults
        if let savedPath = UserDefaults.standard.string(forKey: userDefaultsKey) {
            self.notesFolderURL = URL(fileURLWithPath: savedPath)
        } else {
            self.notesFolderURL = nil
        }
    }

    func setNotesFolderURL(_ url: URL) {
        self.notesFolderURL = url
        UserDefaults.standard.set(url.path, forKey: userDefaultsKey)
        loadNotes()
    }

    func loadNotes() {
        notes.removeAll()

        guard let notesFolderURL = notesFolderURL else {
            return
        }

        do {
            let fileManager = FileManager.default
            let files = try fileManager.contentsOfDirectory(at: notesFolderURL, includingPropertiesForKeys: nil)

            for file in files {
                guard file.pathExtension == "md" else { continue }

                // Read file content
                let fullContent = try String(contentsOf: file, encoding: .utf8)

                // Parse frontmatter and extract time and title
                let (content, _, title) = parseFrontmatter(fullContent)

                let note = Note(title: title, content: content, filePath: file)
                notes.append(note)
            }
        } catch {
            print("Error loading notes: \(error)")
        }
    }
    
    func getRandomNote() -> Note? {
        if notes.isEmpty {
            loadNotes()
        }
        
        return notes.randomElement()
    }
}
