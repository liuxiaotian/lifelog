# Quick Start Guide

## Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/liuxiaotian/lifelog.git
   cd lifelog
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app:**
   - Android: `flutter run`
   - Web: `flutter run -d chrome`

## User Guide

### Adding a Log Entry
1. Tap the **+** button on the home screen
2. Select the date and time by tapping the time field
3. Choose a mood emoji from the grid (25 options available)
4. Enter a description of what happened
5. Tap the checkmark ✓ to save

### Viewing Entries
- **Portrait Mode**: Entries are displayed in a vertical timeline with nodes
- **Landscape Mode**: Entries are displayed in a horizontal timeline
- **Tap any entry** to view full details in a popup

### Deleting Entries
1. Tap an entry to view details
2. Click the **Delete** button in the popup
3. Confirm the deletion

### Settings
Access settings via the gear icon in the top-right:

- **Theme**: Choose Light, Dark, or Follow System
- **About**: View app information
- **Clear All Entries**: Delete all log entries (requires confirmation)

## Building for Production

### Android APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Web
```bash
flutter build web
```
Output: `build/web/`

## Creating a Release

To trigger the automated build and release:

```bash
git tag v1.0.0
git push origin v1.0.0
```

This will:
- Build the Android APK
- Create a GitHub release
- Attach `lifelog_1.0.0.apk` and `sourcecode.zip`

## Troubleshooting

### Issue: App won't build
**Solution**: Ensure Flutter SDK is properly installed and run `flutter doctor` to check your setup.

### Issue: Data not persisting
**Solution**: The app uses `shared_preferences`. Ensure your platform supports local storage.

### Issue: Icons not displaying
**Solution**: The app uses native emoji rendering. Ensure your device/browser supports emoji display.

## Development

### Project Structure
See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed code structure.

### Testing
Currently, the app is designed for manual testing. Run the app and test:
- Adding entries
- Viewing in both orientations
- Deleting entries
- Theme switching
- Data persistence (restart app to verify)

## License
MIT License - See [LICENSE](LICENSE) file for details.
