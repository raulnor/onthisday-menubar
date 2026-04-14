import SwiftUI

@main struct OnThisDayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var journalManager = JournalManager()

    static var shared: AppDelegate?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self

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
        menu.addItem(NSMenuItem(title: "Change Folder...", action: #selector(changeFolder), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q"))

        if let button = statusItem?.button {
            statusItem?.menu = menu
            button.performClick(nil)
            statusItem?.menu = nil
        }
    }

    func showFolderPicker() {
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

    @objc func changeFolder() {
        showFolderPicker()
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
}
