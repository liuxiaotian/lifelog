# LifeLog

A simple life logging app built with Flutter to track moments with time, mood, and events.

## Features

- **Add New Records**: Create log entries with:
  - Time point (customizable date and time)
  - Mood emoji selector (25 different emojis)
  - Event description

- **View All Records**:
  - Portrait mode: Vertical timeline with nodes showing events
  - Landscape mode: Horizontal timeline display
  - Chronologically ordered entries

- **View Specific Record**: Tap any entry to view details in a popup dialog

- **Delete Records**:
  - Delete individual records with confirmation
  - Clear all records from settings

- **Settings**:
  - Theme options: Light / Dark / Follow System
  - About section
  - Clear all records option

## Platforms

- Android
- Web

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- For Android: Android SDK and Android Studio
- For Web: Chrome browser

### Installation

1. Clone the repository:
```bash
git clone https://github.com/liuxiaotian/lifelog.git
cd lifelog
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:

For Android:
```bash
flutter run
```

For Web:
```bash
flutter run -d chrome
```

### Building

Build Android APK:
```bash
flutter build apk --release
```

Build for Web:
```bash
flutter build web
```

## GitHub Actions

This project includes automated build and release workflow:

- Automatically builds APK on tag push (e.g., `v1.0.0`)
- Creates GitHub release with:
  - `lifelog_version.apk` - Android installation file
  - `sourcecode.zip` - Source code archive

To create a release:
```bash
git tag v1.0.0
git push origin v1.0.0
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Technologies

- **Framework**: Flutter
- **State Management**: StatefulWidget
- **Data Persistence**: shared_preferences
- **Date/Time**: intl package
- **UI**: Material Design 3