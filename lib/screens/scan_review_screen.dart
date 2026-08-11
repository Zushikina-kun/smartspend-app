import 'dart:io';
import 'package:flutter/material.dart';

/// Shown after OCR or barcode scan — lets user review and edit
/// the extracted text before sending to the AI.
class ScanReviewScreen extends StatefulWidget {
  final String initialText;
  final String? imagePath;
  final String title;
  final bool isBarcode;
  final String? barcodeFormat;

  const ScanReviewScreen({
    super.key,
    required this.initialText,
    this.imagePath,
    this.title = "Review Scan",
    this.isBarcode = false,
    this.barcodeFormat,
  });

  @override
  State<ScanReviewScreen> createState() => _ScanReviewScreenState();
}

class _ScanReviewScreenState extends State<ScanReviewScreen> {
  late final TextEditingController _ctrl;
  bool _imageExpanded = false;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
    _ctrl.addListener(() => setState(() {}));
    final delay = widget.isBarcode
        ? const Duration(milliseconds: 100)
        : const Duration(milliseconds: 400);
    Future.delayed(delay, () {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String get _charCountLabel {
    final len = _ctrl.text.length;
    if (len > 600) return '⚠️ Long text — AI will focus on totals ($len chars)';
    if (len > 300) return '$len chars';
    return '';
  }

  String _getBarcodeHint(String format) {
    final f = format.toLowerCase();
    if (f.contains('qr')) return '• QR code';
    if (f.contains('ean13') || f.contains('ean-13')) return '• Product barcode';
    if (f.contains('ean8')) return '• Small product barcode';
    if (f.contains('upca') || f.contains('upc')) return '• Product barcode';
    if (f.contains('code128') || f.contains('code 128'))
      return '• Shipping/receipt barcode';
    if (f.contains('pdf417')) return '• ID/document barcode';
    if (f.contains('datamatrix')) return '• Data matrix code';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasImage =
        widget.imagePath != null && File(widget.imagePath!).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.send),
            label: const Text("Send to AI"),
            style: TextButton.styleFrom(
              foregroundColor: cs.primary,
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              final text = _ctrl.text.trim();
              if (text.isEmpty) return;
              Navigator.pop(context, text);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Image preview (OCR only) — collapsible
          if (hasImage) ...[
            GestureDetector(
              onTap: () => setState(() => _imageExpanded = !_imageExpanded),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _imageExpanded ? 280 : 120,
                width: double.infinity,
                color: Colors.black,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(widget.imagePath!), fit: BoxFit.contain),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _imageExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.white,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _imageExpanded ? "Collapse" : "Expand",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
          ],

          // Barcode format badge
          if (widget.isBarcode && widget.barcodeFormat != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: Colors.purple.withValues(alpha: 0.08),
              child: Row(
                children: [
                  const Icon(Icons.qr_code_scanner,
                      size: 14, color: Colors.purple),
                  const SizedBox(width: 6),
                  Text(
                    'Format: ${widget.barcodeFormat}',
                    style: const TextStyle(fontSize: 12, color: Colors.purple),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getBarcodeHint(widget.barcodeFormat!),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

          // Header hint
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Icon(Icons.edit_note,
                    size: 18, color: cs.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    hasImage
                        ? "Extracted text — edit if needed before sending"
                        : widget.isBarcode
                            ? "Describe what you bought and the price"
                            : "Edit your description before sending to AI",
                    style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          ),

          // Editable text area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: TextField(
                controller: _ctrl,
                focusNode: _focusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: const TextStyle(fontSize: 14, height: 1.5),
                decoration: InputDecoration(
                  hintText: hasImage
                      ? "Extracted receipt text will appear here..."
                      : widget.isBarcode
                          ? 'e.g. "Kopiko 78°C 150 pesos"'
                          : "Describe what you bought and the price...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ),

          // Character count warning
          if (_charCountLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _charCountLabel,
                  style: TextStyle(
                    fontSize: 11,
                    color:
                        _ctrl.text.length > 600 ? Colors.orange : Colors.grey,
                  ),
                ),
              ),
            ),

          // Bottom action bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text("Clear"),
                      onPressed: () => _ctrl.clear(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.smart_toy, size: 16),
                      label: const Text("Send to AI"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final text = _ctrl.text.trim();
                        if (text.isEmpty) return;
                        Navigator.pop(context, text);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
