import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../l10n/app_localizations.dart';
import '../models/log_entry.dart';
import '../services/storage_service.dart';
import '../utils/date_format_utils.dart';

class EventMapScreen extends StatefulWidget {
  const EventMapScreen({super.key});

  @override
  State<EventMapScreen> createState() => _EventMapScreenState();
}

class _EventMapScreenState extends State<EventMapScreen> {
  final StorageService _storageService = StorageService();
  List<LogEntry> _entriesWithLocation = [];
  bool _isLoading = true;
  final MapController _mapController = MapController();
  String _timeFormat = 'default';

  @override
  void initState() {
    super.initState();
    _loadTimeFormat();
    _loadEntriesWithLocation();
  }

  Future<void> _loadTimeFormat() async {
    final format = await DateFormatUtils.getTimeFormat();
    setState(() {
      _timeFormat = format;
    });
  }

  Future<void> _loadEntriesWithLocation() async {
    setState(() => _isLoading = true);
    final entries = await _storageService.getEntries();
    final withLocation = entries.where((e) => 
      e.latitude != null && e.longitude != null
    ).toList();
    withLocation.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    setState(() {
      _entriesWithLocation = withLocation;
      _isLoading = false;
    });
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

  LatLng _calculateCenter() {
    if (_entriesWithLocation.isEmpty) {
      return LatLng(0, 0);
    }
    
    double sumLat = 0;
    double sumLng = 0;
    
    for (var entry in _entriesWithLocation) {
      sumLat += entry.latitude!;
      sumLng += entry.longitude!;
    }
    
    return LatLng(
      sumLat / _entriesWithLocation.length,
      sumLng / _entriesWithLocation.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventMap),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _entriesWithLocation.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noEventsWithLocation,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _calculateCenter(),
                    initialZoom: 10.0,
                    minZoom: 2.0,
                    maxZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.lifelog',
                    ),
                    MarkerLayer(
                      markers: _entriesWithLocation.map((entry) {
                        return Marker(
                          point: LatLng(entry.latitude!, entry.longitude!),
                          width: 50,
                          height: 50,
                          child: GestureDetector(
                            onTap: () => _showEntryDetails(entry),
                            child: Container(
                              decoration: BoxDecoration(
                                color: entry.isHighlight 
                                    ? Colors.amber.shade100 
                                    : Colors.blue.shade100,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: entry.isHighlight 
                                      ? Colors.amber 
                                      : Colors.blue,
                                  width: entry.isHighlight ? 3 : 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (entry.isHighlight 
                                        ? Colors.amber 
                                        : Colors.blue).withOpacity(0.5),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  entry.mood,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
    );
  }
}
