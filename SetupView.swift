import SwiftUI
import AppKit

struct SetupView: View {
    @ObservedObject var journalManager: JournalManager
    @State private var isShowingFolderPicker = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: "folder.badge.questionmark")
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text("Journal Folder Not Set")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Please select your journal folder to get started.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                showFolderPicker()
            }) {
                Text("Choose Folder...")
                    .font(.body)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .frame(width: 500, height: 700)
    }

    private func showFolderPicker() {
        // Call the AppDelegate's folder picker method
        AppDelegate.shared?.showFolderPicker()
    }
}
