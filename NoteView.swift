import SwiftUI
import MarkdownUI

struct NoteView: View {
    let note: Note
    @State private var isHovering = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with title
            HStack(alignment: .top) {
                Button(action: {
                    openInObsidian(note.filePath)
                }) {
                    Text(note.title ?? "Untitled")
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
            }

            Divider()

            // Markdown content
            ScrollView {
                Markdown(note.content)
                    .markdownTextStyle(\.text) {
                        FontSize(15)
                    }
                    .padding(.vertical, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
    }
}

