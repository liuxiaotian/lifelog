import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/log_entry.dart';
import '../services/storage_service.dart';
import '../utils/feeling_score_utils.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StorageService _storageService = StorageService();
  List<LogEntry> _entriesWithFeeling = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final entries = await _storageService.getEntries();
    // Filter only entries with feeling scores
    final entriesWithFeeling = entries
        .where((e) => e.feelingScore != null && !e.isEpitaph)
        .toList();
    entriesWithFeeling.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    setState(() {
      _entriesWithFeeling = entriesWithFeeling;
      _isLoading = false;
    });
  }

  double _calculateAverage() {
    if (_entriesWithFeeling.isEmpty) return 0;
    final sum = _entriesWithFeeling.fold<int>(
      0,
      (sum, entry) => sum + (entry.feelingScore ?? 0),
    );
    return sum / _entriesWithFeeling.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.statistics),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_entriesWithFeeling.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.statistics),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.show_chart,
                size: 64,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noFeelingData,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      );
    }

    final average = _calculateAverage();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.feelingCurve,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${l10n.averageFeeling}: ${average.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 200,
                    child: CustomPaint(
                      painter: FeelingCurvePainter(
                        entries: _entriesWithFeeling,
                        primaryColor: Theme.of(context).colorScheme.primary,
                        surfaceColor: Theme.of(context).colorScheme.surface,
                      ),
                      child: Container(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.recentEntries,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ...(_entriesWithFeeling.reversed.take(10).map((entry) {
                  return ListTile(
                    leading: Text(
                      entry.mood,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(entry.timestamp),
                    ),
                    subtitle: Text(
                      entry.event,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: FeelingScoreUtils.getColorForScore(entry.feelingScore ?? 5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        entry.feelingScore.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeelingCurvePainter extends CustomPainter {
  final List<LogEntry> entries;
  final Color primaryColor;
  final Color surfaceColor;

  FeelingCurvePainter({
    required this.entries,
    required this.primaryColor,
    required this.surfaceColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.isEmpty) return;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = primaryColor.withOpacity(0.1)
      ..strokeWidth = 1;

    // Draw grid lines
    for (int i = 0; i <= 10; i++) {
      final y = size.height - (i / 10 * size.height);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < entries.length; i++) {
      final x = entries.length == 1 
          ? size.width / 2 
          : (i / (entries.length - 1)) * size.width;
      final score = entries[i].feelingScore ?? 5;
      final y = size.height - ((score - 1) / 9 * size.height);
      points.add(Offset(x, y));
    }

    // Draw line
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      canvas.drawPath(path, paint);
    }

    // Draw points
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
