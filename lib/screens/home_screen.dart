import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../models/log_entry.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../utils/feeling_score_utils.dart';
import '../utils/mood_analyzer.dart';
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
  final NotificationService _notificationService = NotificationService();
  List<LogEntry> _entries = [];
  bool _isLoading = true;
  LogEntry? _epitaphEntry;
  bool _hasShownLowMoodCare = false;

  @override
  void initState() {
    super.initState();
    _notificationService.initialize();
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
      final content = await _storageService.getEpitaphContent();
      
      if (content != null && content.isNotEmpty) {
        // Set to a far future date (100 years from now), properly handling leap years
        final now = DateTime.now();
        final farFutureDate = DateTime(
          now.year + 100,
          now.month,
          now.day,
        );
        epitaphEntry = LogEntry(
          id: 'epitaph',
          timestamp: farFutureDate,
          mood: '🎯',
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
    
    // Check for low mood pattern and show care message
    if (!_hasShownLowMoodCare && MoodAnalyzer.hasLowMoodPattern(entries)) {
      _hasShownLowMoodCare = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showLowMoodCareDialog();
      });
    }
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

  void _showLowMoodCareDialog() {
    final l10n = AppLocalizations.of(context);
    final highlights = MoodAnalyzer.getHighlightEntries(_entries);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.lowMoodCareTitle),
        content: Text(l10n.lowMoodCareMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          if (highlights.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showHighlights(highlights);
              },
              child: Text(l10n.viewHighlights),
            ),
        ],
      ),
    );
  }

  void _showHighlights(List<LogEntry> highlights) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.viewHighlights),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: highlights.length,
            itemBuilder: (context, index) {
              final entry = highlights[index];
              return ListTile(
                leading: Text(entry.mood, style: const TextStyle(fontSize: 24)),
                title: Text(entry.event, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text(DateFormat('MMM dd, yyyy').format(entry.timestamp)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: FeelingScoreUtils.getColorForScore(entry.feelingScore ?? 5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.feelingScore}/10',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showEntryDetails(entry);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  bool _isVideoFile(String path) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp', '.flv', '.wmv'];
    final lowercasePath = path.toLowerCase();
    return videoExtensions.any((ext) => lowercasePath.endsWith(ext));
  }

  void _showEntryDetails(LogEntry entry) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final isLocked = entry.isWriteToFuture && 
                     entry.unlockDate != null && 
                     entry.unlockDate!.isAfter(now);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(entry.mood, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(entry.timestamp),
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (isLocked) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.lock, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          l10n.lockedEntry,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLocked) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.lock_clock, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        '${l10n.unlocksOn} ${DateFormat('MMM dd, yyyy HH:mm').format(entry.unlockDate!)}',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ] else ...[
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
                if (entry.locationName != null) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.locationName!,
                          style: const TextStyle(color: Colors.grey),
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
