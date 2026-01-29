import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import '../l10n/app_localizations.dart';
import '../models/log_entry.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventController = TextEditingController();
  final StorageService _storageService = StorageService();
  final NotificationService _notificationService = NotificationService();
  final ImagePicker _imagePicker = ImagePicker();
  
  DateTime _selectedDateTime = DateTime.now();
  String _selectedMood = '😊';
  List<String> _attachments = [];
  int? _feelingScore; // 1-10 scale, null means not set
  bool _isWriteToFuture = false;
  DateTime? _unlockDate;
  double? _latitude;
  double? _longitude;
  String? _locationName;
  bool _isHighlight = false;

  final List<String> _moodEmojis = [
    // Happy & Positive
    '😊', '😃', '😄', '😁', '😆', '😂', '🤣',
    '🥰', '😍', '🤩', '😎', '🤗', '🥳',
    // Calm & Relaxed
    '😌', '😴', '🥱', '😪', '😇', '🤓', '🧐',
    // Thinking & Curious
    '🤔', '🤨', '😐', '😑', '🙄', '😬', '🤐',
    // Sad & Upset
    '😕', '😟', '🙁', '😢', '😭', '😞', '😔',
    // Angry & Frustrated
    '😡', '🤬', '😠', '😤', '💢', '😖', '😣',
    // Surprised & Shocked
    '🤯', '😱', '😨', '😰', '😳', '🤭', '😲',
    // Worried & Anxious
    '🥺', '😥', '😓', '😩', '😫', '🤕', '🤒',
    // Others
    '🤡', '🥴', '😵', '🤠', '🥶', '🥵', '😷',
  ];

  @override
  void dispose() {
    _eventController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: _isWriteToFuture ? DateTime(2100) : DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null && mounted) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      } else if (mounted) {
        // If only date is selected (time is cancelled), update with the date but keep current time
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            _selectedDateTime.hour,
            _selectedDateTime.minute,
          );
        });
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    final l10n = AppLocalizations.of(context);
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (image != null && !_attachments.contains(image.path)) {
        setState(() {
          _attachments.add(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToPickImage)),
        );
      }
    }
  }

  Future<void> _pickVideoFromGallery() async {
    final l10n = AppLocalizations.of(context);
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null && !_attachments.contains(video.path)) {
        setState(() {
          _attachments.add(video.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToPickVideo)),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    final l10n = AppLocalizations.of(context);
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (photo != null && !_attachments.contains(photo.path)) {
        setState(() {
          _attachments.add(photo.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToTakePhoto)),
        );
      }
    }
  }

  Future<void> _recordVideo() async {
    final l10n = AppLocalizations.of(context);
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      if (video != null && !_attachments.contains(video.path)) {
        setState(() {
          _attachments.add(video.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToRecordVideo)),
        );
      }
    }
  }

  bool _isVideoFile(String path) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm', '.3gp', '.flv', '.wmv'];
    final lowercasePath = path.toLowerCase();
    return videoExtensions.any((ext) => lowercasePath.endsWith(ext));
  }

  void _removeAttachment(int index) {
    setState(() {
      _attachments.removeAt(index);
    });
  }

  void _showAttachmentOptions() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImageFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_library),
              title: Text(l10n.chooseVideoFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickVideoFromGallery();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: Text(l10n.recordVideo),
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectUnlockDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _unlockDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(2100),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_unlockDate ?? now),
      );

      if (time != null && mounted) {
        setState(() {
          _unlockDate = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    final l10n = AppLocalizations.of(context);
    
    try {
      // Check location permission
      var permission = await Permission.location.status;
      if (permission.isDenied) {
        permission = await Permission.location.request();
      }

      if (permission.isDenied || permission.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.locationPermissionDenied)),
          );
        }
        return;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.enableLocationServices)),
          );
        }
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          final locationParts = [
            place.name,
            place.locality,
            place.administrativeArea,
            place.country,
          ].where((part) => part != null && part.isNotEmpty).toList();

          setState(() {
            _latitude = position.latitude;
            _longitude = position.longitude;
            _locationName = locationParts.join(', ');
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.locationAdded)),
            );
          }
        }
      } catch (e) {
        // If geocoding fails, still save coordinates
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationName = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.locationAdded)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToGetLocation)),
        );
      }
    }
  }

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final entryId = DateTime.now().millisecondsSinceEpoch.toString();
      final entry = LogEntry(
        id: entryId,
        timestamp: _selectedDateTime,
        mood: _selectedMood,
        event: _eventController.text.trim(),
        attachments: _attachments,
        feelingScore: _feelingScore,
        isWriteToFuture: _isWriteToFuture,
        unlockDate: _unlockDate,
        latitude: _latitude,
        longitude: _longitude,
        locationName: _locationName,
        isHighlight: _isHighlight,
      );

      await _storageService.addEntry(entry);
      
      // Schedule notification if it's a future letter
      if (_isWriteToFuture && _unlockDate != null) {
        final l10n = AppLocalizations.of(context);
        await _notificationService.scheduleLetterFromPastNotification(
          id: entryId.hashCode,
          scheduledDate: _unlockDate!,
          title: l10n.letterFromPast,
          body: l10n.letterFromPastBody,
        );
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newEntry),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveEntry,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(l10n.time),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(_selectedDateTime),
                ),
                onTap: _selectDateTime,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.howAreYouFeeling,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 280,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  childAspectRatio: 1,
                ),
                itemCount: _moodEmojis.length,
                itemBuilder: (context, index) {
                  final emoji = _moodEmojis[index];
                  final isSelected = emoji == _selectedMood;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedMood = emoji),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : null,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.feelingScoreOptional,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _feelingScore?.toDouble() ?? 5.0,
                    min: 1.0,
                    max: 10.0,
                    divisions: 9,
                    label: _feelingScore?.toString() ?? '-',
                    onChanged: (value) {
                      setState(() {
                        _feelingScore = value.round();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    _feelingScore != null ? _feelingScore.toString() : '-',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _feelingScore != null
                      ? () => setState(() => _feelingScore = null)
                      : null,
                  tooltip: l10n.cancel,
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _eventController,
              decoration: InputDecoration(
                labelText: l10n.whatHappened,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.pleaseEnterEvent;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.attachments,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _showAttachmentOptions,
                  tooltip: l10n.addAttachment,
                ),
              ],
            ),
            if (_attachments.isNotEmpty)
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _attachments.length,
                  itemBuilder: (context, index) {
                    final path = _attachments[index];
                    final isVideo = _isVideoFile(path);
                    
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 120,
                          height: 120,
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
                                      size: 48,
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
                                          size: 48,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 8,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.surface,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(24, 24),
                            ),
                            onPressed: () => _removeAttachment(index),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  CheckboxListTile(
                    title: Text(l10n.writeToFuture),
                    subtitle: _isWriteToFuture ? Text(l10n.writeToFutureHint) : null,
                    value: _isWriteToFuture,
                    onChanged: (value) {
                      setState(() {
                        _isWriteToFuture = value ?? false;
                        if (_isWriteToFuture && _unlockDate == null) {
                          _unlockDate = DateTime.now().add(const Duration(days: 30));
                        } else if (!_isWriteToFuture) {
                          _unlockDate = null;
                        }
                      });
                    },
                  ),
                  if (_isWriteToFuture)
                    ListTile(
                      leading: const Icon(Icons.lock_clock),
                      title: Text(l10n.unlockDate),
                      subtitle: _unlockDate != null
                          ? Text(DateFormat('MMM dd, yyyy HH:mm').format(_unlockDate!))
                          : null,
                      onTap: _selectUnlockDate,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: Text(l10n.location),
                subtitle: _locationName != null
                    ? Text(_locationName!)
                    : null,
                trailing: _locationName != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _latitude = null;
                            _longitude = null;
                            _locationName = null;
                          });
                        },
                      )
                    : null,
                onTap: _getCurrentLocation,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: CheckboxListTile(
                title: Text(l10n.markAsHighlight),
                subtitle: Text(l10n.highlightMoment),
                value: _isHighlight,
                onChanged: (value) {
                  setState(() {
                    _isHighlight = value ?? false;
                  });
                },
                secondary: const Icon(Icons.star, color: Colors.amber),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
