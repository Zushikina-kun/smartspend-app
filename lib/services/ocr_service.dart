import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class OCRService {
  /// Scan a receipt image and return cleaned, structured text for AI parsing.
  /// Handles image rotation, noise removal, and receipt-specific formatting.
  static Future<String> scanReceipt(String path) async {
    return _scan(path, cleanForReceipt: true);
  }

  /// Scan any document/table image and return the raw OCR text with minimal cleaning.
  /// Use this for transaction history tables, bank statements, etc.
  /// Does NOT apply receipt-specific filtering that would destroy table structure.
  static Future<String> scanDocument(String path) async {
    return _scan(path, cleanForReceipt: false);
  }

  static Future<String> _scan(String path,
      {required bool cleanForReceipt}) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception("Image file not found.");
    }

    // Fix image orientation before OCR (handles sideways/upside-down photos)
    final correctedPath = await _fixOrientation(path);

    final inputImage = InputImage.fromFilePath(correctedPath);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      final raw = recognizedText.text;
      if (raw.trim().isEmpty) {
        throw Exception(
            "No text detected. Tips:\n• Ensure good lighting\n• Hold the phone steady\n• Keep the receipt flat and uncrumpled\n• Make sure text is in focus");
      }

      if (!cleanForReceipt) {
        // Raw mode for transaction tables — minimal cleaning, preserve structure
        // Just normalize whitespace and remove truly empty lines
        final lines = raw
            .split('\n')
            .map((l) => l.trim())
            .where((l) => l.isNotEmpty)
            .toList();
        final result = lines.join('\n');
        // Quality check
        final hasNumbers = RegExp(r'\d').hasMatch(result);
        if (!hasNumbers) {
          return '[Low quality scan — edit before sending]\n$result';
        }
        // No truncation for transaction tables — they need full text
        return result;
      }

      // Receipt mode — clean and structure
      final cleaned = _cleanReceiptText(raw);

      // Quality check — if result is very short or garbled, add a warning prefix
      final wordCount = cleaned.split(RegExp(r'\s+')).length;
      final hasNumbers = RegExp(r'\d').hasMatch(cleaned);
      String result = cleaned;
      if (wordCount < 5 || !hasNumbers) {
        result = '[Low quality scan — edit before sending]\n$cleaned';
      }

      // Trim to 1200 chars to stay within AI token limit (increased from 800)
      return result.length > 1200 ? result.substring(0, 1200) : result;
    } finally {
      await textRecognizer.close();
      // Clean up temp file if we created one
      if (correctedPath != path) {
        try {
          await File(correctedPath).delete();
        } catch (_) {}
      }
    }
  }

  /// Fix EXIF orientation — rotates image to upright before OCR
  static Future<String> _fixOrientation(String path) async {
    try {
      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return path;

      // img package auto-applies EXIF orientation on decode
      // Re-encode to apply the correction — use quality 95 to preserve OCR accuracy
      final fixed = img.encodeJpg(decoded, quality: 95);
      final dir = await getTemporaryDirectory();
      final outPath =
          '${dir.path}/ocr_fixed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(outPath).writeAsBytes(fixed);
      return outPath;
    } catch (_) {
      return path; // fallback to original if anything fails
    }
  }

  /// Clean and structure receipt text for better AI parsing
  /// Detect what type of document was scanned based on content patterns
  static String detectDocumentType(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('debit') &&
        lower.contains('credit') &&
        lower.contains('balance')) {
      return 'transaction_history';
    }
    if (lower.contains('gcash') ||
        lower.contains('maya') ||
        lower.contains('transfer from')) {
      return 'transaction_history';
    }
    if (lower.contains('total') ||
        lower.contains('subtotal') ||
        lower.contains('receipt')) {
      return 'receipt';
    }
    if (RegExp(r'\d{4}-\d{2}-\d{2}').allMatches(text).length >= 3) {
      return 'transaction_history'; // multiple dates = likely a history table
    }
    return 'receipt'; // default
  }

  static String _cleanReceiptText(String raw) {
    final lines = raw.split('\n');

    // Noise patterns — only filter truly useless lines
    final noisePatterns = [
      RegExp(r'^\s*$'), // empty lines
      RegExp(r'^[*=\-_]{5,}$'), // long separator lines only
      RegExp(r'^[0-9]{15,}$'), // very long pure number lines (serial numbers)
      RegExp(r'^(tel|fax|phone|address|addr|vat|tin|bir|rdo)[\s:]',
          caseSensitive: false),
      RegExp(r'^thank you', caseSensitive: false),
      RegExp(r'^please come again', caseSensitive: false),
    ];

    // Priority patterns — always keep these
    final priorityPatterns = [
      RegExp(r'total', caseSensitive: false),
      RegExp(r'amount', caseSensitive: false),
      RegExp(r'subtotal', caseSensitive: false),
      RegExp(r'₱|php|peso', caseSensitive: false),
      RegExp(r'\d+\.\d{2}'), // prices
      RegExp(r'\d{4}-\d{2}-\d{2}'), // dates
    ];

    final priorityLines = <String>[];
    final regularLines = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      bool isNoise = false;
      for (final pattern in noisePatterns) {
        if (pattern.hasMatch(trimmed)) {
          isNoise = true;
          break;
        }
      }
      if (isNoise) continue;

      bool isPriority = false;
      for (final pattern in priorityPatterns) {
        if (pattern.hasMatch(trimmed)) {
          isPriority = true;
          break;
        }
      }

      if (isPriority)
        priorityLines.add(trimmed);
      else
        regularLines.add(trimmed);
    }

    // Build output — keep more lines than before (up to 20 items)
    final result = <String>[];
    result.addAll(regularLines.take(3)); // store name / header
    if (regularLines.length > 3) {
      result.add('---');
      result.addAll(regularLines.skip(3).take(20)); // items
    }
    if (priorityLines.isNotEmpty) {
      result.add('---');
      result.addAll(priorityLines);
    }

    if (result.isEmpty || result.length < 2) {
      return raw.replaceAll(RegExp(r'\n{3,}'), '\n\n').trim();
    }

    final joined =
        result.join('\n').replaceAll(RegExp(r'[ \t]{2,}'), ' ').trim();
    // Increase limit to 1200 chars for receipts (was 800)
    return joined.length > 1200 ? joined.substring(0, 1200) : joined;
  }
}
