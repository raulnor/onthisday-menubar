# On This Day

A SwiftUI macOS app that shows all your journal entries for any given day across all years.

## Features

- 📅 Interactive calendar to select any date
- 📖 Displays all journal entries from that day across different years
- ✨ Beautiful markdown rendering
- 🎨 Native macOS design with split view

## Requirements

- macOS 14.0 or later
- Swift 5.9 or later
- Xcode 15.0 or later

## Building and Running

### Option 1: Run with Swift Package Manager

```bash
cd /tmp/onthisday
swift run
```

### Option 2: Open in Xcode

1. Open Xcode
2. File > Open > Select `/tmp/onthisday` folder
3. Wait for package dependencies to resolve
4. Click Run

## How It Works

The app reads journal entries from:
```
/Users/travis/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vault/journal
```

When you select a date (e.g., March 31), it will show all entries from that day across all years (2016-03-31, 2017-03-31, 2018-03-31, etc.).

## Configuration

To change the journal directory path, edit `JournalManager.swift` and update the `journalPath` variable.
