# Business Card Organizer — Project 27

Native iOS application for organizing business contacts with biometric authentication, secure local storage, and full CRUD capabilities.

## Technology Stack

- **Language:** Swift 5.9
- **UI Framework:** SwiftUI
- **Architecture:** MVVM (Models, Views, ViewModels, Services strictly separated)
- **Minimum iOS:** 17.0
- **Project Generation:** XcodeGen
- **Authentication:** LocalAuthentication (Face ID) with manual passcode fallback
- **Secure Storage:** Keychain (passcode verification material only)
- **Persistence:** Codable + local JSON file with iOS file protection
- **CI/CD:** GitHub Actions (macOS Xcode runner)

## Required Features

- Face ID authentication
- Manual passcode fallback
- Dashboard with contact statistics
- Contact listing with search and relationship filters
- Add / edit / delete contacts
- Contact details view
- Tags: Client, Vendor, Mentor, Colleague, Friend
- Favourite contacts
- Duplicate contact detection
- Contact import/export (vCard and JSON)
- Backup and restore
- Portrait orientation only
- Unit tests and UI tests

## Project Structure

```
BusinessCardOrganizer/
├── App/                 # App entry point and navigation coordinator
├── Models/              # Pure data models (Codable, no UI/persistence dependencies)
├── Services/            # Business logic, storage, authentication, import/export
├── ViewModels/          # State management, one per screen
├── Views/               # SwiftUI views, reusable components
├── Resources/           # Info.plist, Assets.xcassets
└── Supporting Files/    # Constants
```

## Build & Run

### Prerequisites (macOS only)

- Xcode 15.4 or later
- XcodeGen (`brew install xcodegen`)

### Generate Xcode Project

```bash
xcodegen generate
```

### Build for Simulator (no code signing)

```bash
xcodebuild -project BusinessCardOrganizer.xcodeproj \
  -scheme BusinessCardOrganizer \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

### Run Tests

```bash
xcodebuild test -project BusinessCardOrganizer.xcodeproj \
  -scheme BusinessCardOrganizer \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' \
  CODE_SIGNING_ALLOWED=NO
```

## CI/CD

GitHub Actions runs on `macos-latest`:
1. Installs pinned XcodeGen version
2. Generates the Xcode project from `project.yml`
3. Builds for iOS Simulator without code signing
4. Runs unit and UI tests
5. Uploads build logs, test results, and the simulator `.app` bundle

## Security

- Passcodes are never stored in plain text
- PBKDF2 with a unique cryptographically random salt per app installation
- Keychain stores only verification material (salt + derived key hash)
- Accessible only when device is unlocked (`kSecAttrAccessibleWhenUnlockedThisDeviceOnly`)
- Contact JSON file protected with `FileProtectionType.completeUntilFirstUserAuthentication`
- No personal contact information is logged

## License

MIT