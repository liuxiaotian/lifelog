import 'package:flutter/material.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../models/log_entry.dart';
import '../services/storage_service.dart';
import '../utils/feeling_score_utils.dart';
import '../utils/date_format_utils.dart';

class LifeHighlightsScreen extends StatefulWidget {
  const LifeHighlightsScreen({super.key});

  @override
  State<LifeHighlightsScreen> createState() => _LifeHighlightsScreenState();
}

class _LifeHighlightsScreenState extends State<LifeHighlightsScreen> {
  final StorageService _storageService = StorageService();
  List<LogEntry> _highlights = [];
  bool _isLoading = true;
  String _timeFormat = 'default';

  @override
  void initState() {
    super.initState();
    _loadTimeFormat();
    _loadHighlights();
  }

  Future<void> _loadTimeFormat() async {
    final format = await DateFormatUtils.getTimeFormat();
    setState(() {
      _timeFormat = format;
    });
  }

  Future<void> _loadHighlights() async {
    setState(() => _isLoading = true);
    final entries = await _storageService.getEntries();
    final highlights = entries.where((e) => e.isHighlight).toList();
    highlights.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _highlights = highlights;
      _isLoading = false;
    });
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
            const Icon(Icons.star, color: Colors.amber, size: 32),
            const SizedBox(width: 8),
            Text(entry.mood, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DateFormatUtils.formatDateTime(entry.timestamp, _timeFormat),
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.lifeHighlights),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _highlights.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.star_border,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noHighlightsYet,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _highlights.length,
                  itemBuilder: (context, index) {
                    final entry = _highlights[index];
                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      color: Colors.amber.shade50.withOpacity(0.3),
                      child: InkWell(
                        onTap: () => _showEntryDetails(entry),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.amber,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.amber.withOpacity(0.5),
                                          blurRadius: 8,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        entry.mood,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormatUtils.formatDate(entry.timestamp, _timeFormat),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          DateFormatUtils.formatTime(entry.timestamp, _timeFormat),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.star, color: Colors.amber, size: 28),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                entry.event,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 15),
                              ),
                              if (entry.feelingScore != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      l10n.feelingScore,
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: FeelingScoreUtils.getColorForScore(entry.feelingScore!),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${entry.feelingScore}/10',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              if (entry.locationName != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        entry.locationName!,
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
