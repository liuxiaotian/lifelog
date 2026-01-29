import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';
import 'epitaph_settings_screen.dart';
import 'statistics_screen.dart';

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
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.clearAllEntries),
        content: Text(l10n.clearAllConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.deleteAll),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.clearAllEntries();
      widget.onClearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.allEntriesCleared)),
        );
      }
    }
  }

  void _showAbout() {
    final l10n = AppLocalizations.of(context);
    showAboutDialog(
      context: context,
      applicationName: l10n.appTitle,
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.event_note, size: 48),
      children: [
        Text(l10n.appDescription),
        const SizedBox(height: 16),
        Text(l10n.builtWithFlutter),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l10n.theme,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          RadioListTile<String>(
            title: Text(l10n.light),
            value: 'light',
            groupValue: _currentThemeMode,
            onChanged: (value) => _setThemeMode(value!),
          ),
          RadioListTile<String>(
            title: Text(l10n.dark),
            value: 'dark',
            groupValue: _currentThemeMode,
            onChanged: (value) => _setThemeMode(value!),
          ),
          RadioListTile<String>(
            title: Text(l10n.followSystem),
            value: 'system',
            groupValue: _currentThemeMode,
            onChanged: (value) => _setThemeMode(value!),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.show_chart),
            title: Text(l10n.viewStatistics),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const StatisticsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_note),
            title: Text(l10n.epitaphSettings),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EpitaphSettingsScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.about),
            onTap: _showAbout,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(
              l10n.clearAllEntries,
              style: const TextStyle(color: Colors.red),
            ),
            onTap: _clearAllEntries,
          ),
        ],
      ),
    );
  }
}
