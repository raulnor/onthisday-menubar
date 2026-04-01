import SwiftUI
import MarkdownUI

struct EntryView: View {
    let entry: JournalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with year and date
            HStack {
                Text(String(entry.year))
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)

                Spacer()

                Text(entry.formattedDate)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
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
}
