# LifeLog - Code Structure

## Overview
LifeLog is a Flutter application for tracking life moments with time, mood emojis, and event descriptions.

## Directory Structure

```
lifelog/
├── lib/
│   ├── main.dart                 # App entry point and theme management
│   ├── models/
│   │   └── log_entry.dart        # Data model for log entries
│   ├── screens/
│   │   ├── home_screen.dart      # Main screen with timeline view
│   │   ├── add_entry_screen.dart # Form to create new entries
│   │   └── settings_screen.dart  # Settings and preferences
│   ├── services/
│   │   └── storage_service.dart  # Data persistence layer
│   └── widgets/
│       └── timeline_view.dart    # Timeline visualization component
├── android/                      # Android platform configuration
├── web/                          # Web platform configuration
└── .github/workflows/            # CI/CD automation
```

## Key Features

### Data Model (log_entry.dart)
- Stores: ID, timestamp, mood emoji, event description
- JSON serialization for storage

### Storage (storage_service.dart)
- Uses `shared_preferences` for persistent storage
- CRUD operations for log entries

### Home Screen (home_screen.dart)
- Displays all entries in timeline format
- Handles entry viewing and deletion
- Navigation to settings

### Add Entry Screen (add_entry_screen.dart)
- Date/time picker
- Mood emoji selector (25 options)
- Event description input

### Timeline View (timeline_view.dart)
- Portrait: Vertical timeline with nodes
- Landscape: Horizontal timeline
- Responsive design

### Settings Screen (settings_screen.dart)
- Theme selection (Light/Dark/System)
- About dialog
- Clear all entries

## Building

### Android
```bash
flutter build apk --release
```

### Web
```bash
flutter build web
```

## Release Process

The project uses GitHub Actions to automatically:
1. Build Android APK when tags are pushed
2. Create GitHub releases
3. Attach APK and source code

To release:
```bash
git tag v1.0.0
git push origin v1.0.0
```
