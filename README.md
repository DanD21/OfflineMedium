# Offline Medium

An iOS app for downloading and reading Medium articles offline by parsing and saving them to a local Realm database.

## Swift 6 Upgrade

This project has been upgraded to support Swift 6 and modern iOS development:

### Changes Made

#### Dependencies
- **iOS Deployment Target**: Updated from 9.0 to 13.0
- **Swift Version**: Upgraded from 3.0 to 6.0
- **RealmSwift**: Updated from 3.13.1 to ~10.54.0
- **Kanna**: Updated from 2.1.0 to ~5.3.0

#### Code Modernization
- Migrated all Realm models to use `@Persisted` property wrappers instead of deprecated `dynamic` keyword
- Updated Realm API calls from `.add(update: true)` to `.add(update: .modified)`
- Fixed deprecated UIKit APIs:
  - `UIApplicationLaunchOptionsKey` → `UIApplication.LaunchOptionsKey`
  - `NSFontAttributeName` → `NSAttributedString.Key.font`
  - `NSForegroundColorAttributeName` → `NSAttributedString.Key.foregroundColor`
- Removed iOS version checks for iOS 10+ (now targeting iOS 13+)

#### Medium.com Parsing Updates
Updated HTML parsing to work with modern Medium.com structure:
- **BookmarksParser**: Enhanced to detect article links using multiple strategies (article tags, data attributes, URL patterns)
- **PostParser**: Modernized to extract metadata from:
  - OpenGraph meta tags (`og:title`, `og:image`)
  - Article meta tags (`author`, `article:author`)
  - Fallback to JSON-LD structured data
  - Multiple image source attributes (`src`, `data-src`, `srcset`)

## Setup

1. Install dependencies:
   ```bash
   pod update
   ```

2. Open the workspace:
   ```bash
   open "Offline Medium.xcworkspace"
   ```

3. Build and run the project in Xcode

## How It Works

1. User logs in through Medium OAuth
2. App fetches bookmarked articles from Medium
3. Articles are parsed to extract:
   - Title
   - Author
   - Main image
   - Article HTML content
   - Embedded images
4. Content is saved to local Realm database
5. Images are downloaded and stored locally
6. Articles can be read offline

## Architecture

- **RealmManager**: Database models and object definitions
- **DBManager**: Database operations (CRUD)
- **BookmarksParser**: Extracts article links from Medium bookmarks page
- **PostDownloader**: Downloads article HTML content
- **PostParser**: Parses article HTML to extract metadata and content
- **ImageDownloader**: Downloads and saves article images locally

## Requirements

- iOS 13.0+
- Xcode 15.0+
- Swift 6.0
- CocoaPods

## Notes

The Medium HTML structure may continue to evolve. If parsing breaks in the future, the parser logic in `BookmarksParser.swift` and `PostParser.swift` may need additional updates to match Medium's latest HTML structure.
