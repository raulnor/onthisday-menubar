import SwiftUI
import MarkdownUI

struct EntryView: View {
    let entry: JournalEntry
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title/year and date
            HStack(alignment: .top) {
                Button(action: openInObsidian) {
                    Text(entry.title ?? String(entry.year))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.tint)
                        .underline(isHovering)
                }
                .buttonStyle(.plain)
                .help("Open in Obsidian")
                .onHover { hovering in
                    isHovering = hovering
                    if hovering {
                        NSCursor.pointingHand.push()
                    } else {
                        NSCursor.pop()
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text(entry.formattedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let time = entry.time {
                        Text(time)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            Divider()

            // Markdown content
            Markdown(entry.content)
                .markdownTextStyle(\.text) {
                    FontSize(15)
                }
                .padding(.vertical, 4)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }

    private func openInObsidian() {
        // Create obsidian:// URL to open the file
        let fileName = entry.filePath.deletingPathExtension().lastPathComponent
        let vaultName = "Vault"
        let filePath = "journal/\(fileName)"

        // Obsidian URI format: obsidian://open?vault=VaultName&file=path/to/file
        let urlString = "obsidian://open?vault=\(vaultName)&file=\(filePath)"

        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? urlString) {
            NSWorkspace.shared.open(url)
        }
    }
}
