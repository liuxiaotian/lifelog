import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';
import '../services/storage_service.dart';

class AddEntryScreen extends StatefulWidget {
  const AddEntryScreen({super.key});

  @override
  State<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventController = TextEditingController();
  final StorageService _storageService = StorageService();
  
  DateTime _selectedDateTime = DateTime.now();
  String _selectedMood = '😊';

  final List<String> _moodEmojis = [
    '😊', '😃', '😄', '😁', '😆',
    '🥰', '😍', '🤩', '😎', '🤗',
    '😌', '😴', '🤔', '🤨', '😐',
    '😕', '😟', '😢', '😭', '😡',
    '🤯', '😱', '😨', '🥺', '😳',
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
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
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

  Future<void> _saveEntry() async {
    if (_formKey.currentState!.validate()) {
      final entry = LogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: _selectedDateTime,
        mood: _selectedMood,
        event: _eventController.text.trim(),
      );

      await _storageService.addEntry(entry);
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Entry'),
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
                title: const Text('Time'),
                subtitle: Text(
                  DateFormat('MMM dd, yyyy HH:mm').format(_selectedDateTime),
                ),
                onTap: _selectDateTime,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'How are you feeling?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
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
            TextFormField(
              controller: _eventController,
              decoration: const InputDecoration(
                labelText: 'What happened?',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an event description';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
