import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeModeChanged;
  final VoidCallback onClearAll;

  const SettingsScreen({
    super.key,
    required this.onThemeModeChanged,
    required this.onClearAll,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  String _currentThemeMode = 'system';

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentThemeMode = prefs.getString('theme_mode') ?? 'system';
    });
  }

  Future<void> _setThemeMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode);
    setState(() {
      _currentThemeMode = mode;
    });

    ThemeMode themeMode;
    switch (mode) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system;
    }
    widget.onThemeModeChanged(themeMode);
  }

  Future<void> _clearAllEntries() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Entries'),
        content: const Text(
          'Are you sure you want to delete all log entries? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.clearAllEntries();
      widget.onClearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All entries cleared')),
        );
      }
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'LifeLog',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.event_note, size: 48),
      children: [
        const Text(
          'A simple life logging app to track moments with time, mood, and events.',
        ),
        const SizedBox(height: 16),
        const Text('Built with Flutter'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Theme',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          RadioListTile<String>(
            title: const Text('Light'),
            value: 'light',
            groupValue: _currentThemeMode,
            onChanged: (value) => _setThemeMode(value!),
          ),
          RadioListTile<String>(
            title: const Text('Dark'),
            value: 'dark',
            groupValue: _currentThemeMode,
            onChanged: (value) => _setThemeMode(value!),
          ),
          RadioListTile<String>(
            title: const Text('Follow System'),
            value: 'system',
            groupValue: _currentThemeMode,
            onChanged: (value) => _setThemeMode(value!),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: _showAbout,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Clear All Entries',
              style: TextStyle(color: Colors.red),
            ),
            onTap: _clearAllEntries,
          ),
        ],
      ),
    );
  }
}
