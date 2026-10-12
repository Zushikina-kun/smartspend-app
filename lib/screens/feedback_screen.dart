import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/peso_mascot.dart';
import '../services/debug_service.dart' show kAppVersion;

class FeedbackScreen extends StatefulWidget {
  final String? prefillType;
  final String? prefillTitle;
  final String? prefillDetails;

  const FeedbackScreen({
    super.key,
    this.prefillType,
    this.prefillTitle,
    this.prefillDetails,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _detailsCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  String _selectedType = 'suggestion';
  bool _consent = false;
  bool _submitted = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    if (widget.prefillType != null) {
      _selectedType = widget.prefillType!;
    }
    if (widget.prefillTitle != null) {
      _titleCtrl.text = widget.prefillTitle!;
    }
    if (widget.prefillDetails != null) {
      _detailsCtrl.text = widget.prefillDetails!;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_consent) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please confirm the consent checkbox before submitting.')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      final typeLabel = {
            'suggestion': '[Suggestion]',
            'bug': '[Bug]',
            'question': '[Question]',
            'other': '[Feedback]',
          }[_selectedType] ??
          '[Feedback]';
      final title = '$typeLabel ${_titleCtrl.text.trim()}';
      String deviceInfo = '';
      try {
        deviceInfo = 'Platform: Android\n';
      } catch (_) {}
      final body = StringBuffer();
      if (_emailCtrl.text.trim().isNotEmpty) {
        body.writeln('Submitted by: ${_emailCtrl.text.trim()}\n');
      }
      body.writeln('**Type:** $_selectedType');
      body.writeln('**App version:** $kAppVersion');
      body.writeln(deviceInfo);
      body.writeln('**Details:**\n${_detailsCtrl.text.trim()}');
      body.writeln('\n---\n*Submitted via SmartSpend in-app feedback*');
      final uri = Uri(
        scheme: 'https',
        host: 'github.com',
        path: '/Zushikina-kun/smartspend-app/issues/new',
        queryParameters: {
          'title': title,
          'body': body.toString(),
          'labels': _selectedType,
        },
      );
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      setState(() => _submitted = true);
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (_submitted) {
      return Scaffold(
        appBar: AppBar(
          title: const Row(children: [
            PesoMascot(size: 28, mood: PesoMood.happy),
            SizedBox(width: 8),
            Text('Send Feedback'),
          ]),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PesoMascot.withSpeech(
                  size: 80,
                  mood: PesoMood.celebrating,
                  text: 'Salamat! 🙏\nWe\'ll review your feedback!',
                ),
                const SizedBox(height: 32),
                FilledButton.tonal(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Done'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(children: [
          PesoMascot(size: 28, mood: PesoMood.happy),
          SizedBox(width: 8),
          Text('Send Feedback'),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Type selector
              const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _typeChip('suggestion', '💡 Suggestion', cs),
                  _typeChip('bug', '🐛 Bug Report', cs),
                  _typeChip('question', '❓ Question', cs),
                  _typeChip('other', '💬 Other', cs),
                ],
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleCtrl,
                maxLength: 120,
                decoration: const InputDecoration(
                  labelText: 'Title / Topic',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Details
              TextFormField(
                controller: _detailsCtrl,
                maxLength: 2000,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Details',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Please enter some details';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email (optional)
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Your email (optional — only if you want a reply)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Consent checkbox
              CheckboxListTile(
                value: _consent,
                onChanged: (v) => setState(() => _consent = v ?? false),
                title: const Text(
                    'I understand this may be posted as a public GitHub issue'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 20),

              // Submit button
              FilledButton(
                onPressed: _sending ? null : _submit,
                child: _sending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Send to Team →'),
              ),
              const SizedBox(height: 8),

              // Browse issues link
              TextButton(
                onPressed: () => launchUrl(
                  Uri.parse(
                      'https://github.com/Zushikina-kun/smartspend-app/issues'),
                  mode: LaunchMode.externalApplication,
                ),
                child: const Text('Browse existing issues →'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label, ColorScheme cs) {
    final selected = _selectedType == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: cs.primary,
      labelStyle: TextStyle(color: selected ? cs.onPrimary : null),
      onSelected: (_) => setState(() => _selectedType = value),
    );
  }
}
