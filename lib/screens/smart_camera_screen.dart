import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import '../services/ocr_service.dart';
import '../services/db_service.dart';

/// Smart Camera Screen — Auto mode only.
/// Live viewfinder with detection box.
/// - Barcode/QR: detected live by mobile_scanner → review screen
/// - Receipt/Document: tap shutter → ML Kit OCR → review screen
/// - Gallery: pick image → auto-detect barcode first, fall back to OCR
///
/// Pipeline: Camera → Auto-detect → Scan Review → AI
/// Set documentMode: true when scanning transaction history tables
/// (uses raw OCR without receipt-specific cleaning that destroys table structure)
class SmartCameraScreen extends StatefulWidget {
  final bool documentMode;
  const SmartCameraScreen({super.key, this.documentMode = false});

  @override
  State<SmartCameraScreen> createState() => _SmartCameraScreenState();
}

class _SmartCameraScreenState extends State<SmartCameraScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scanCtrl = MobileScannerController();
  bool _torchOn = false;
  bool _processing = false;
  bool _barcodeDetected = false;
  bool _receiptMode = false; // tall guide for receipts vs square for barcodes

  // Animation for the detection box
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── BARCODE DETECTED (live) ───────────────────────────────

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_barcodeDetected || _processing) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    setState(() => _barcodeDetected = true);
    _scanCtrl.stop();

    final code = barcode!.rawValue!;
    final format = barcode.format.name;
    await DBService.insertScan(code);

    // Check if this barcode was scanned before
    final history = await DBService.getScanHistory(limit: 50);
    final prevCount = history.where((h) => h['barcode'] == code).length;
    final repeatHint =
        prevCount > 1 ? '\n\n[Scanned $prevCount times before]' : '';

    // SH-2: Check if an expense was logged for this barcode (by shop_name match)
    String linkedExpenseHint = '';
    try {
      final allExpenses = await DBService.getExpenses();
      final codeShort = code.length > 8 ? code.substring(0, 8) : code;
      final linked = allExpenses
          .where((e) =>
              (e.shopName?.contains(codeShort) ?? false) ||
              (e.notes?.contains(codeShort) ?? false))
          .toList();
      if (linked.isNotEmpty) {
        final last = linked.first;
        linkedExpenseHint =
            '\n[Last logged: ${last.itemName} ₱${last.amount.toStringAsFixed(0)} on ${last.date.substring(5)}]';
      }
    } catch (_) {}

    if (!mounted) return;
    final reviewed = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanReviewScreen(
          initialText:
              'Barcode: $code\n\nI bought: $repeatHint$linkedExpenseHint',
          title: "Describe Product",
          isBarcode: true,
          barcodeFormat: format,
        ),
      ),
    );

    if (reviewed != null && reviewed.isNotEmpty && mounted) {
      Navigator.pop(context,
          ScanResult(text: reviewed, isBarcode: true, barcodeFormat: format));
    } else {
      // User cancelled — resume scanning
      setState(() => _barcodeDetected = false);
      _scanCtrl.start();
    }
  }

  // ── SHUTTER: capture photo → OCR ─────────────────────────

  Future<void> _captureForOCR() async {
    if (_processing) return;
    setState(() => _processing = true);
    await _scanCtrl.stop();

    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
          source: ImageSource.camera, imageQuality: 100, maxWidth: 2048);
      if (photo == null) {
        await _scanCtrl.start();
        setState(() => _processing = false);
        return;
      }
      await _processImage(photo.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Capture failed: ${e.toString().replaceAll('Exception: ', '')}"),
          behavior: SnackBarBehavior.floating,
        ));
        await _scanCtrl.start();
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  // ── GALLERY: pick image → auto-detect ────────────────────

  Future<void> _pickFromGallery() async {
    if (_processing) return;
    setState(() => _processing = true);
    _scanCtrl.stop();

    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
          source: ImageSource.gallery, imageQuality: 100, maxWidth: 2048);
      if (photo == null) {
        _scanCtrl.start();
        setState(() => _processing = false);
        return;
      }
      await _processImage(photo.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              "Gallery error: ${e.toString().replaceAll('Exception: ', '')}"),
          behavior: SnackBarBehavior.floating,
        ));
        _scanCtrl.start();
      }
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  // ── PROCESS IMAGE: barcode first, fall back to OCR ────────

  Future<void> _processImage(String imagePath) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(children: [
          SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white)),
          SizedBox(width: 12),
          Text("Analyzing image..."),
        ]),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 15),
      ));
    }

    // Try barcode detection first
    String? barcodeCode;
    String? barcodeFormat;
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodeScanner = BarcodeScanner();
      final barcodes = await barcodeScanner.processImage(inputImage);
      await barcodeScanner.close();
      if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
        barcodeCode = barcodes.first.rawValue;
        barcodeFormat = barcodes.first.format.name;
      }
    } catch (_) {}

    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();

    if (barcodeCode != null) {
      // Barcode found in image
      await DBService.insertScan(barcodeCode);
      final reviewed = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (_) => ScanReviewScreen(
            initialText: 'Barcode: $barcodeCode\n\nI bought: ',
            title: "Describe Product",
            isBarcode: true,
            barcodeFormat: barcodeFormat,
          ),
        ),
      );
      if (reviewed != null && reviewed.isNotEmpty && mounted) {
        Navigator.pop(
            context,
            ScanResult(
                text: reviewed, isBarcode: true, barcodeFormat: barcodeFormat));
        return;
      }
    } else {
      // No barcode — run OCR
      try {
        final text = widget.documentMode
            ? await OCRService.scanDocument(imagePath)
            : await OCRService.scanReceipt(imagePath);
        if (!mounted) return;

        // Auto-detect: if it looks like a transaction history, suggest import screen
        if (!widget.documentMode) {
          final docType = OCRService.detectDocumentType(text);
          if (docType == 'transaction_history' && mounted) {
            ScaffoldMessenger.of(context).clearSnackBars();
            final useImport = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Transaction History Detected"),
                content: const Text(
                    "This looks like a bank or e-wallet transaction history.\n\n"
                    "Use the Import screen for better results — it parses all rows and lets you review before importing.\n\n"
                    "Or continue to the regular review screen."),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text("Regular Review"),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text("Open Import Screen"),
                  ),
                ],
              ),
            );
            if (useImport == true && mounted) {
              Navigator.pop(context); // close camera
              // Navigate to import screen with the OCR text pre-filled
              // The caller (ai_screen or bank_import) handles this
              Navigator.pop(context, ScanResult(text: text, isBarcode: false));
              return;
            }
          }
        }

        final reviewed = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder: (_) => ScanReviewScreen(
              initialText: text,
              imagePath: imagePath,
              title: widget.documentMode
                  ? "Review Transaction History"
                  : "Review Receipt",
            ),
          ),
        );
        if (reviewed != null && reviewed.isNotEmpty && mounted) {
          if (reviewed.startsWith('__IMPORT__')) {
            // User chose "Import Items" — return with import flag
            Navigator.pop(
                context,
                ScanResult(
                  text: reviewed.substring('__IMPORT__'.length),
                  isBarcode: false,
                  barcodeFormat: 'receipt_import',
                ));
          } else {
            Navigator.pop(context, ScanResult(text: reviewed));
          }
          return;
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("OCR: ${e.toString().replaceAll('Exception: ', '')}"),
            behavior: SnackBarBehavior.floating,
          ));
        }
      }
    }

    // User cancelled review or error — resume scanner
    if (mounted) {
      setState(() => _barcodeDetected = false);
      _scanCtrl.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title:
            const Text("Smart Scanner", style: TextStyle(color: Colors.white)),
        actions: [
          // Receipt mode toggle
          IconButton(
            icon: Icon(
              _receiptMode ? Icons.receipt_long : Icons.qr_code_scanner,
              color: _receiptMode ? Colors.amber : Colors.white,
            ),
            tooltip: _receiptMode
                ? "Switch to Barcode mode"
                : "Switch to Receipt mode",
            onPressed: () => setState(() => _receiptMode = !_receiptMode),
          ),
          // Torch toggle
          IconButton(
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              color: _torchOn ? Colors.yellow : Colors.white,
            ),
            onPressed: () {
              _scanCtrl.toggleTorch();
              setState(() => _torchOn = !_torchOn);
            },
          ),
          // Gallery
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            tooltip: "Pick from Gallery",
            onPressed: _processing ? null : _pickFromGallery,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Live scanner viewfinder
          MobileScanner(
            controller: _scanCtrl,
            onDetect: _onBarcodeDetected,
          ),

          // Animated detection box overlay
          Center(
            child: AnimatedBuilder(
              animation: _pulseAnim,
              builder: (_, __) => Transform.scale(
                scale: _pulseAnim.value,
                child: Container(
                  width: _receiptMode ? 220 : 260,
                  height: _receiptMode ? 360 : 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _barcodeDetected
                          ? Colors.greenAccent
                          : _receiptMode
                              ? Colors.amber
                              : cs.primary,
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _barcodeDetected
                      ? const Center(
                          child: Icon(Icons.check_circle,
                              color: Colors.greenAccent, size: 48))
                      : _receiptMode
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.receipt_long,
                                      color: Colors.amber, size: 32),
                                  const SizedBox(height: 8),
                                  Text("Receipt mode",
                                      style: TextStyle(
                                          color: Colors.amber
                                              .withValues(alpha: 0.6),
                                          fontSize: 11)),
                                ],
                              ),
                            )
                          : null,
                ),
              ),
            ),
          ),

          // Corner brackets for a more polished scanner look
          Center(
            child: SizedBox(
              width: _receiptMode ? 220 : 260,
              height: _receiptMode ? 360 : 260,
              child: CustomPaint(
                  painter: _CornerPainter(
                      color: _receiptMode ? Colors.amber : cs.primary)),
            ),
          ),

          // Status hint
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _processing
                      ? "Analyzing..."
                      : _barcodeDetected
                          ? "Barcode detected ✓"
                          : _receiptMode
                              ? "Receipt mode — tap shutter to capture"
                              : "Point at barcode, QR code, or receipt",
                  style: TextStyle(
                    color: _barcodeDetected
                        ? Colors.greenAccent
                        : _receiptMode
                            ? Colors.amber
                            : Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),

          // Shutter button for receipt capture
          if (!_barcodeDetected)
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _processing ? null : _captureForOCR,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        color: _processing
                            ? Colors.grey.withValues(alpha: 0.5)
                            : Colors.white24,
                      ),
                      child: _processing
                          ? const Center(
                              child: SizedBox(
                                  width: 28,
                                  height: 28,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2)))
                          : const Icon(Icons.camera_alt,
                              color: Colors.white, size: 32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Tap for receipt / document",
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── CORNER BRACKET PAINTER ────────────────────────────────────

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 24.0;
    const r = 16.0;

    // Top-left
    canvas.drawLine(Offset(r, 0), Offset(r + len, 0), paint);
    canvas.drawLine(Offset(0, r), Offset(0, r + len), paint);
    // Top-right
    canvas.drawLine(
        Offset(size.width - r - len, 0), Offset(size.width - r, 0), paint);
    canvas.drawLine(Offset(size.width, r), Offset(size.width, r + len), paint);
    // Bottom-left
    canvas.drawLine(
        Offset(r, size.height), Offset(r + len, size.height), paint);
    canvas.drawLine(
        Offset(0, size.height - r - len), Offset(0, size.height - r), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - r - len, size.height),
        Offset(size.width - r, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height - r - len),
        Offset(size.width, size.height - r), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

// ── SCAN RESULT ───────────────────────────────────────────────

class ScanResult {
  final String text;
  final bool isBarcode;
  final String? barcodeFormat;
  ScanResult({required this.text, this.isBarcode = false, this.barcodeFormat});
}

// ── SCAN REVIEW SCREEN ────────────────────────────────────────

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

  /// True if the scanned text looks like a multi-item receipt
  bool get _hasMultipleAmounts {
    final text = _ctrl.text;
    final amountMatches = RegExp(r'[₱\d]\d*\.\d{2}').allMatches(text).length +
        RegExp(r'₱\s*\d+').allMatches(text).length;
    return amountMatches >= 3 ||
        text.toLowerCase().contains('total') ||
        text.toLowerCase().contains('subtotal');
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
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(
                              _imageExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                              color: Colors.white,
                              size: 14),
                          const SizedBox(width: 4),
                          Text(_imageExpanded ? "Collapse" : "Expand",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
          ],
          if (widget.isBarcode && widget.barcodeFormat != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: Colors.purple.withValues(alpha: 0.08),
              child: Row(children: [
                const Icon(Icons.qr_code_scanner,
                    size: 14, color: Colors.purple),
                const SizedBox(width: 6),
                Text('Format: ${widget.barcodeFormat}',
                    style: const TextStyle(fontSize: 12, color: Colors.purple)),
                const SizedBox(width: 8),
                Text(_getBarcodeHint(widget.barcodeFormat!),
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ]),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [
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
                    fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5)),
              )),
            ]),
          ),
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
                      borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ),
          if (_charCountLabel.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(_charCountLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          _ctrl.text.length > 600 ? Colors.orange : Colors.grey,
                    )),
              ),
            ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(children: [
                Expanded(
                    child: OutlinedButton.icon(
                  icon: const Icon(Icons.clear, size: 16),
                  label: const Text("Clear"),
                  onPressed: () => _ctrl.clear(),
                )),
                const SizedBox(width: 12),
                // Show "Import Items" button for non-barcode scans with multiple amounts
                if (!widget.isBarcode && _hasMultipleAmounts) ...[
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.download_done, size: 16),
                      label: const Text("Import Items"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        final text = _ctrl.text.trim();
                        if (text.isEmpty) return;
                        // Return with a special prefix so caller knows to route to import
                        Navigator.pop(context, '__IMPORT__$text');
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.smart_toy, size: 16),
                      label: const Text("AI Chat"),
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
                ] else
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
                      )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
