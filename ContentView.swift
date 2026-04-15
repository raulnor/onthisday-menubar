import SwiftUI

struct ContentView: View {
    @EnvironmentObject var journalManager: JournalManager
    @State private var selectedDate = Date()
    @FocusState private var isDatePickerFocused: Bool

    var body: some View {
        if journalManager.journalPath == nil {
            SetupView(journalManager: journalManager)
        } else {
            mainView
        }
    }

    private var mainView: some View {
        VStack(spacing: 0) {
            // Header with navigation
            HStack {
                Button(action: previousDay) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .padding(12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(-12)
                .keyboardShortcut(.leftArrow, modifiers: [])
                .help("Previous day")

                Spacer()

                VStack(spacing: 4) {
                    Text("On This Day")
                        .font(.headline)

                    Text(formattedSelectedDate)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: nextDay) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                        .padding(12)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(-12)
                .keyboardShortcut(.rightArrow, modifiers: [])
                .help("Next day")
            }
            .padding()
            .background(Color(nsColor: .windowBackgroundColor))

            Divider()

            // Compact date picker
            HStack {
                Text("Date:")
                    .foregroundColor(.secondary)

                DatePicker(
                    "",
                    selection: $selectedDate,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.field)
                .labelsHidden()
                .focused($isDatePickerFocused)
                .onChange(of: selectedDate) { oldValue, newValue in
                    loadEntries(for: newValue)
                }

                Spacer()

                Text("\(journalManager.entries.count) entries")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)

            Divider()

            // Entries list
            if journalManager.entries.isEmpty {
                VStack {
                    Spacer()
                    Image(systemName: "book.closed")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No entries for this day")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(journalManager.entries) { entry in
                            EntryView(entry: entry)
                        }
                    }
                    .padding()
                }
            }
        }
        .frame(width: 500, height: 700)
        .focusable(false)
        .onAppear {
            loadEntries(for: selectedDate)
            DispatchQueue.main.async {
                isDatePickerFocused = false
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("JumpToToday"))) { _ in
            selectedDate = Date()
        }
    }

    private var formattedSelectedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: selectedDate)
    }

    private func loadEntries(for date: Date) {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        journalManager.loadEntriesForDate(month: month, day: day)
    }

    private func previousDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private func nextDay() {
        if let newDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

