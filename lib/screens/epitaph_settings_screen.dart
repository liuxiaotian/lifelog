import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../services/storage_service.dart';

class EpitaphSettingsScreen extends StatefulWidget {
  const EpitaphSettingsScreen({super.key});

  @override
  State<EpitaphSettingsScreen> createState() => _EpitaphSettingsScreenState();
}

class _EpitaphSettingsScreenState extends State<EpitaphSettingsScreen> {
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();
  final _lifespanController = TextEditingController();
  final _contentController = TextEditingController();
  
  bool _epitaphEnabled = false;
  DateTime? _birthday;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _lifespanController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final enabled = await _storageService.isEpitaphEnabled();
    final birthday = await _storageService.getEpitaphBirthday();
    final lifespan = await _storageService.getEpitaphLifespan();
    final content = await _storageService.getEpitaphContent();

    setState(() {
      _epitaphEnabled = enabled;
      _birthday = birthday;
      _lifespanController.text = lifespan?.toString() ?? '';
      _contentController.text = content ?? '';
      _isLoading = false;
    });
  }

  Future<void> _selectBirthday() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _birthday ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null && mounted) {
      setState(() {
        _birthday = date;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (!_epitaphEnabled) {
      await _storageService.setEpitaphEnabled(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).save)),
        );
        Navigator.pop(context);
      }
      return;
    }

    if (_formKey.currentState!.validate()) {
      await _storageService.setEpitaphEnabled(_epitaphEnabled);
      await _storageService.setEpitaphBirthday(_birthday);
      await _storageService.setEpitaphLifespan(
        _lifespanController.text.isNotEmpty
            ? int.tryParse(_lifespanController.text)
            : null,
      );
      await _storageService.setEpitaphContent(_contentController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).save)),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(l10n.epitaphSettings),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.epitaphSettings),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SwitchListTile(
              title: Text(l10n.enableEpitaph),
              value: _epitaphEnabled,
              onChanged: (value) {
                setState(() {
                  _epitaphEnabled = value;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_epitaphEnabled) ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.cake),
                  title: Text(l10n.birthday),
                  subtitle: Text(
                    _birthday != null
                        ? DateFormat('MMM dd, yyyy').format(_birthday!)
                        : l10n.pleaseEnterBirthday,
                  ),
                  onTap: _selectBirthday,
                  trailing: _birthday != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => _birthday = null),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lifespanController,
                decoration: InputDecoration(
                  labelText: l10n.expectedLifespan,
                  border: const OutlineInputBorder(),
                  suffixText: l10n.translate('expected_lifespan').contains('years') ? '' : 'years',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (_epitaphEnabled) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterLifespan;
                    }
                    final lifespan = int.tryParse(value);
                    if (lifespan == null || lifespan <= 0 || lifespan > 150) {
                      return 'Please enter a valid lifespan (1-150)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: l10n.epitaphContent,
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                validator: (value) {
                  if (_epitaphEnabled) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.pleaseEnterEpitaph;
                    }
                  }
                  return null;
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
