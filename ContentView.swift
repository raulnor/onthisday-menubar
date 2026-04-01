import SwiftUI

struct ContentView: View {
    @StateObject private var journalManager = JournalManager()
    @State private var selectedDate = Date()

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 20) {
                Text("On This Day")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .padding()
                .onChange(of: selectedDate) { oldValue, newValue in
                    loadEntries(for: newValue)
                }

                Text("Found \(journalManager.entries.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .frame(minWidth: 300, idealWidth: 350)
            .onAppear {
                loadEntries(for: selectedDate)
            }
        } detail: {
            if journalManager.entries.isEmpty {
                VStack {
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No entries for this day")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        ForEach(journalManager.entries) { entry in
                            EntryView(entry: entry)
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private func loadEntries(for date: Date) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        journalManager.loadEntriesForDate(month: month, day: day)
    }
}

#Preview {
    ContentView()
}
