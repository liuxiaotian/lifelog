import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../models/log_entry.dart';
import '../services/storage_service.dart';
import '../utils/feeling_score_utils.dart';
import 'add_entry_screen.dart';
import 'settings_screen.dart';
import '../widgets/timeline_view.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeModeChanged;

  const HomeScreen({super.key, required this.onThemeModeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storageService = StorageService();
  List<LogEntry> _entries = [];
  bool _isLoading = true;
  LogEntry? _epitaphEntry;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    setState(() => _isLoading = true);
    final entries = await _storageService.getEntries();
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    // Load epitaph if enabled
    LogEntry? epitaphEntry;
    final epitaphEnabled = await _storageService.isEpitaphEnabled();
    if (epitaphEnabled) {
      final birthday = await _storageService.getEpitaphBirthday();
      final lifespan = await _storageService.getEpitaphLifespan();
      final content = await _storageService.getEpitaphContent();
      
      if (birthday != null && lifespan != null && content != null && content.isNotEmpty) {
        final expectedEndDate = DateTime(
          birthday.year + lifespan,
          birthday.month,
          birthday.day,
        );
        epitaphEntry = LogEntry(
          id: 'epitaph',
          timestamp: expectedEndDate,
          mood: '🕊️',
          event: content,
          isEpitaph: true,
        );
      }
    }
    
    setState(() {
      _entries = entries;
      _epitaphEntry = epitaphEntry;
      _isLoading = false;
    });
  }

  Future<void> _deleteEntry(LogEntry entry) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteEntry),
        content: Text(l10n.deleteEntryConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storageService.deleteEntry(entry.id);
      _loadEntries();
    }
  }

  bool _isVideoFile(String path) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp', '.flv', '.wmv'];
    final lowercasePath = path.toLowerCase();
    return videoExtensions.any((ext) => lowercasePath.endsWith(ext));
  }

  void _showEntryDetails(LogEntry entry) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(entry.mood, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormat('MMM dd, yyyy HH:mm').format(entry.timestamp),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.event),
              if (entry.feelingScore != null) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      l10n.feelingScore,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FeelingScoreUtils.getColorForScore(entry.feelingScore!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.feelingScore}/10',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (entry.attachments.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  l10n.attachments,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: entry.attachments.length,
                    itemBuilder: (context, index) {
                      final path = entry.attachments[index];
                      final isVideo = _isVideoFile(path);
                      
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: isVideo
                              ? Center(
                                  child: Icon(
                                    Icons.video_library,
                                    size: 40,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : Image.file(
                                  File(path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  },
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEntry(entry);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    onThemeModeChanged: widget.onThemeModeChanged,
                    onClearAll: _loadEntries,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noEntriesYet,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.tapToAdd),
                    ],
                  ),
                )
              : TimelineView(
                  entries: _entries,
                  onEntryTap: _showEntryDetails,
                  epitaphEntry: _epitaphEntry,
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEntryScreen()),
          );
          _loadEntries();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
