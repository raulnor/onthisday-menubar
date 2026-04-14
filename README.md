# On This Day

A SwiftUI macOS menubar app that shows all your journal entries for any given day across all years. Vibe coded.

## Features

- 📅 Interactive calendar to select any date
- ⏰ Shows time from frontmatter if present
- 📖 Displays all journal entries from that day across different years (newest first)
- ✨ Beautiful markdown rendering (frontmatter stripped)
- ◀️ ▶️ Previous/Next day navigation buttons
- 🎯 Lives in your menubar for quick access
- 🎨 Native macOS design

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

The app will appear in your menubar as a book icon. Click it to open the popover.

### Option 2: Open in Xcode

1. Open Xcode
2. File > Open > Select `/tmp/onthisday` folder
3. Wait for package dependencies to resolve
4. Click Run

## How It Works

When you select a date (e.g., March 31), it will show all entries from that day across all years (2026-03-31, 2019-03-31, 2018-03-31, etc.), sorted from newest to oldest.

### Frontmatter Support

The app parses YAML frontmatter and:
- Extracts time from `date` field (e.g., `date: 2026-03-31T21:37`)
- Strips frontmatter from displayed content
- Shows time below the date if present

