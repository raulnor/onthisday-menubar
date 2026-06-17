import SwiftUI

@main struct OnThisDayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var journalManager = JournalManager()
    var noteManager = NoteManager()
    var mainWindow: NSWindow?
    var noteWindows: [NSWindow] = []

    static var shared: AppDelegate?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self

        // Register URL handler
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )

        NSApp.setActivationPolicy(.accessory) // Policy to allow modal dialogs

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "book.fill", accessibilityDescription: "On This Day")
            button.action = #selector(handleMenuBarClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }

        popover = NSPopover()
        popover?.contentSize = NSSize(width: 500, height: 700)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView().environmentObject(journalManager))
    }

    @objc func handleMenuBarClick() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            togglePopover()
        }
    }

    @objc func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                if let button = statusItem?.button {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                }
            }
        }
    }

    @objc func showMenu() {
        let menu = NSMenu()

        menu.addItem(NSMenuItem(title: "On This Day", action: nil, keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Random Note...", action: #selector(randomNote), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Change Journal Folder...", action: #selector(changeJournalFolder), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Change Note Folder...", action: #selector(changeNotesFolder), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        if let button = statusItem?.button {
            statusItem?.menu = menu
            button.performClick(nil)
            statusItem?.menu = nil
        }
    }
    
    @objc func randomNote() {
        guard let note = noteManager.getRandomNote() else {
            return
        }
        let hosting = NSHostingController(
            rootView: NoteView(note: note).environmentObject(noteManager)
        )
        let window = NSWindow(contentViewController: hosting)
        window.title = "Note"
        window.setContentSize(NSSize(width: 480, height: 600))
        window.styleMask = [.titled, .closable, .resizable]
        window.isReleasedWhenClosed = false
        window.delegate = self
        noteWindows.append(window)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func showJournalFolderPicker() {
        let wasShowing = popover?.isShown ?? false
        
        popover?.performClose(nil)

        NSApp.activate(ignoringOtherApps: true)

        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select your journal folder"
        panel.prompt = "Choose"
        panel.canCreateDirectories = true

        let response = panel.runModal()

        if response == .OK, let url = panel.url {
            journalManager.setJournalPath(url)
        }

        // Reopen the popover if it was showing
        if wasShowing, let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    @objc func changeJournalFolder() {
        showJournalFolderPicker()
    }

    func showNotesFolderPicker() {
        let wasShowing = popover?.isShown ?? false
        
        popover?.performClose(nil)

        NSApp.activate(ignoringOtherApps: true)

        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false
        panel.message = "Select your note folder"
        panel.prompt = "Choose"
        panel.canCreateDirectories = true

        let response = panel.runModal()

        if response == .OK, let url = panel.url {
            noteManager.setNotesFolderURL(url)
        }

        // Reopen the popover if it was showing
        if wasShowing, let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }

    @objc func changeNotesFolder() {
        showNotesFolderPicker()
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }

    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString),
              url.scheme == "onthisday" else {
            return
        }

        showMainWindow()

        // Check if the URL path is "today"
        if url.host == "today" || url.path == "/today" {
            NotificationCenter.default.post(name: NSNotification.Name("JumpToToday"), object: nil)
        }
    }

    func showMainWindow() {
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if mainWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 500, height: 700),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Journal"
            window.center()
            window.contentView = NSHostingView(rootView: ContentView().environmentObject(journalManager))
            window.isReleasedWhenClosed = false
            window.delegate = self

            mainWindow = window
        }

        mainWindow?.makeKeyAndOrderFront(nil)
    }

    func windowWillClose(_ notification: Notification) {
        guard let closed = notification.object as? NSWindow else { return }

        if closed === mainWindow {
            NSApp.setActivationPolicy(.accessory)
        } else {
            noteWindows.removeAll { $0 === closed }
        }
    }
}

/// Parse YAML frontmatter and extract time and title, returning content without frontmatter
func parseFrontmatter(_ content: String) -> (content: String, time: String?, title: String?) {
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

func openInObsidian(_ url: URL) {
    var components = URLComponents()
    components.scheme = "obsidian"
    components.host = "open"
    components.queryItems = [
        URLQueryItem(name: "path", value: url.path)
    ]
    if let url = components.url {
        NSWorkspace.shared.open(url)
    }
}
