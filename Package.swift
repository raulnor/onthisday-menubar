// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OnThisDay",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.3.0")
    ],
    targets: [
        .executableTarget(
            name: "OnThisDay",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui")
            ],
            path: ".",
            exclude: [
                "README.md",
                "install.sh",
                "com.onthisday.plist"
            ],
            sources: [
                "OnThisDayApp.swift",
                "ContentView.swift",
                "EntryView.swift",
                "JournalEntry.swift",
                "JournalManager.swift"
            ]
        )
    ]
)
