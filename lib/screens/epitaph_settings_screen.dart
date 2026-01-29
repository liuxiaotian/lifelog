import 'package:flutter/material.dart';
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
  final _contentController = TextEditingController();
  
  bool _epitaphEnabled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    final enabled = await _storageService.isEpitaphEnabled();
    final content = await _storageService.getEpitaphContent();

    setState(() {
      _epitaphEnabled = enabled;
      _contentController.text = content ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    if (!_epitaphEnabled) {
      await _storageService.setEpitaphEnabled(false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).save)),
        );
        Navigator.pop(context, true);
      }
      return;
    }

    if (_formKey.currentState!.validate()) {
      await _storageService.setEpitaphEnabled(_epitaphEnabled);
      await _storageService.setEpitaphContent(_contentController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).save)),
        );
        Navigator.pop(context, true);
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
