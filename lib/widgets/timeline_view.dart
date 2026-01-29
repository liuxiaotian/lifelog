import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';

class TimelineView extends StatelessWidget {
  final List<LogEntry> entries;
  final Function(LogEntry) onEntryTap;
  final LogEntry? epitaphEntry;

  const TimelineView({
    super.key,
    required this.entries,
    required this.onEntryTap,
    this.epitaphEntry,
  });

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return _buildVerticalTimeline(context);
        } else {
          return _buildHorizontalTimeline(context);
        }
      },
    );
  }

  Widget _buildVerticalTimeline(BuildContext context) {
    final itemCount = entries.length + (epitaphEntry != null ? 1 : 0);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (epitaphEntry != null && index == entries.length) {
          // Show epitaph at the end
          return _buildEpitaphItem(context);
        }
        final entry = entries[index];
        return _buildVerticalTimelineItem(context, entry, index);
      },
    );
  }

  Widget _buildVerticalTimelineItem(BuildContext context, LogEntry entry, int index) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  DateFormat('HH:mm').format(entry.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  DateFormat('MMM dd').format(entry.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    entry.mood,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              if (index < entries.length - 1)
                Expanded(
                  child: Container(
                    width: 2,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Card(
                child: InkWell(
                  onTap: () => onEntryTap(entry),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      entry.event,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalTimeline(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return _buildHorizontalTimelineItem(context, entry, index);
            },
          ),
        ),
        Container(
          height: 2,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          margin: const EdgeInsets.symmetric(horizontal: 16),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                'Tap any event to view details',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalTimelineItem(BuildContext context, LogEntry entry, int index) {
    return SizedBox(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Card(
              child: InkWell(
                onTap: () => onEntryTap(entry),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry.mood,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DateFormat('HH:mm').format(entry.timestamp),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM dd, yyyy').format(entry.timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Text(
                          entry.event,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpitaphItem(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Divider(
          thickness: 2,
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
        ),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.surfaceVariant,
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      epitaphEntry!.mood,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('MMM dd, yyyy').format(epitaphEntry!.timestamp),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  epitaphEntry!.event,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
