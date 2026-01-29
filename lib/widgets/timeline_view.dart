import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';
import '../utils/date_format_utils.dart';

class TimelineView extends StatefulWidget {
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
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  String _timeFormat = 'default';

  @override
  void initState() {
    super.initState();
    _loadTimeFormat();
  }

  Future<void> _loadTimeFormat() async {
    final format = await DateFormatUtils.getTimeFormat();
    setState(() {
      _timeFormat = format;
    });
  }

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
    final itemCount = widget.entries.length + (widget.epitaphEntry != null ? 1 : 0);
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (widget.epitaphEntry != null && index == widget.entries.length) {
          // Show epitaph at the end
          return _buildEpitaphItem(context);
        }
        final entry = widget.entries[index];
        return _buildVerticalTimelineItem(context, entry, index);
      },
    );
  }

  Widget _buildVerticalTimelineItem(BuildContext context, LogEntry entry, int index) {
    final now = DateTime.now();
    final isLocked = entry.isWriteToFuture && 
                     entry.unlockDate != null && 
                     entry.unlockDate!.isAfter(now);
    
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
                  DateFormatUtils.formatTime(entry.timestamp, _timeFormat),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  DateFormatUtils.formatShortDate(entry.timestamp, _timeFormat),
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
                  color: isLocked 
                      ? Colors.grey.shade300 
                      : entry.isHighlight
                          ? Colors.amber.shade100
                          : Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isLocked 
                        ? Colors.grey 
                        : entry.isHighlight
                            ? Colors.amber
                            : Theme.of(context).colorScheme.primary,
                    width: entry.isHighlight ? 3 : 2,
                  ),
                  boxShadow: entry.isHighlight
                      ? [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: isLocked 
                      ? const Icon(Icons.lock, size: 20)
                      : Text(
                          entry.mood,
                          style: const TextStyle(fontSize: 20),
                        ),
                ),
              ),
              if (index < widget.entries.length - 1)
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
                elevation: entry.isHighlight ? 4 : 1,
                color: entry.isHighlight 
                    ? Colors.amber.shade50.withOpacity(0.3) 
                    : null,
                child: InkWell(
                  onTap: () => widget.onEntryTap(entry),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            isLocked ? '***' : entry.event,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isLocked)
                          const Icon(Icons.lock, size: 16, color: Colors.grey),
                        if (entry.isHighlight && !isLocked)
                          const Icon(Icons.star, size: 20, color: Colors.amber),
                      ],
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
            itemCount: widget.entries.length,
            itemBuilder: (context, index) {
              final entry = widget.entries[index];
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
                onTap: () => widget.onEntryTap(entry),
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
                              DateFormatUtils.formatTime(entry.timestamp, _timeFormat),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormatUtils.formatDate(entry.timestamp, _timeFormat),
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
                      widget.epitaphEntry!.mood,
                      style: const TextStyle(fontSize: 40),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormatUtils.formatDate(widget.epitaphEntry!.timestamp, _timeFormat),
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
                  widget.epitaphEntry!.event,
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
