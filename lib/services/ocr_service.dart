import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'app_config.dart';

class OCRService {
  /// Returns the preferred model ID for AI-assisted OCR parsing.
  ///
  /// Vision-capable models (isVision == true in [AppConfig.availableModels])
  /// can process images directly and produce higher-quality results for
  /// receipt and screenshot parsing. This method returns the first available
  /// vision model, or the current active model when none is available.
  ///
  /// Call this before invoking the LLM step so the caller can temporarily
  /// switch to the vision model for the duration of the parse:
  /// ```dart
  /// final savedModel = AppConfig.activeModelId;
  /// final ocrModel = OCRService.preferredModelForOcr();
  /// if (ocrModel != savedModel) AppConfig.setModel(ocrModel);
  /// final result = await LLMService.parseReceipt(ocrText);
  /// if (ocrModel != savedModel) AppConfig.setModel(savedModel);
  /// ```
  static String preferredModelForOcr() {
    return AppConfig.preferredVisionModelId ?? AppConfig.activeModelId;
  }

  /// Whether the given model ID is vision-capable (can accept image input).
  static bool isVisionModel(String modelId) =>
      AppConfig.visionModelIds.contains(modelId);

  /// Scan a receipt image and return cleaned, structured text for AI parsing.
  /// Handles image rotation, noise removal, and receipt-specific formatting.
  static Future<String> scanReceipt(String path) async {
    if (kIsWeb) return '';
    return _scan(path, cleanForReceipt: true);
  }

  /// Scan any document/table image and return the raw OCR text with minimal cleaning.
  /// Use this for transaction history tables, bank statements, etc.
  /// Does NOT apply receipt-specific filtering that would destroy table structure.
  static Future<String> scanDocument(String path) async {
    if (kIsWeb) return '';
    return _scan(path, cleanForReceipt: false);
  }

  static Future<String> _scan(String path,
      {required bool cleanForReceipt, bool enhanceDark = false}) async {
    final file = File(path);
    if (!await file.exists()) {
      throw Exception("Image file not found.");
    }

    final correctedPath = await _fixOrientation(path, enhanceDark: enhanceDark);

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

  /// Fix EXIF orientation and optionally enhance contrast for dark screenshots.
  /// Rotates image to upright, then if the image is predominantly dark
  /// (average luminance < 128), inverts or brightens it so ML Kit can
  /// read white-on-dark text (Steam, dark-themed app receipts, etc.)
  static Future<String> _fixOrientation(String path,
      {bool enhanceDark = false}) async {
    try {
      final bytes = await File(path).readAsBytes();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return path;

      // img package auto-applies EXIF orientation on decode
      img.Image processed = decoded;

      if (enhanceDark) {
        // Sample a 50×50 patch from the centre to estimate luminance
        final cx = processed.width ~/ 2;
        final cy = processed.height ~/ 2;
        double lumSum = 0;
        int samples = 0;
        for (var y = cy - 25; y < cy + 25 && y < processed.height; y++) {
          for (var x = cx - 25; x < cx + 25 && x < processed.width; x++) {
            final px = processed.getPixel(x, y);
            // Luminance ≈ 0.299R + 0.587G + 0.114B
            lumSum += 0.299 * px.r + 0.587 * px.g + 0.114 * px.b;
            samples++;
          }
        }
        final avgLum = samples > 0 ? lumSum / samples : 128;

        if (avgLum < 100) {
          // Dark screenshot — invert so white text becomes black on white
          // (ML Kit reads black-on-white far more reliably)
          processed = img.invert(processed);
          // Then apply a contrast boost to sharpen the now-dark text
          processed =
              img.adjustColor(processed, contrast: 1.4, brightness: 1.1);
        } else if (avgLum < 140) {
          // Mid-range — just boost contrast slightly
          processed = img.adjustColor(processed, contrast: 1.2);
        }
      }

      final fixed = img.encodeJpg(processed, quality: 95);
      final dir = await getTemporaryDirectory();
      final outPath =
          '${dir.path}/ocr_fixed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(outPath).writeAsBytes(fixed);
      return outPath;
    } catch (_) {
      return path;
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

  // ── BATCH IMAGE PROCESSING ─────────────────────────────────────────────────

  /// Pick up to [maxImages] images from the gallery at once.
  /// Returns a list of image file paths.
  static Future<List<String>> pickMultipleImages({int maxImages = 10}) async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      imageQuality: 90,
      maxWidth: 2048,
    );
    if (images.isEmpty) return [];
    return images.take(maxImages).map((x) => x.path).toList();
  }

  /// Run OCR on a single image path and return raw text.
  /// Uses document mode (raw OCR, no receipt cleaning) for screenshots.
  /// Applies dark-image contrast enhancement for Steam/dark-themed apps.
  static Future<String> scanImageRaw(String path) async {
    return _scan(path, cleanForReceipt: false, enhanceDark: true);
  }

  /// Process a batch of image paths in parallel:
  /// OCR each image, detect its type, return structured list ready for
  /// LLMService.parseScreenshotBatch().
  ///
  /// Returns list of maps with keys: 'path', 'ocrText', 'type', 'error'.
  static Future<List<Map<String, String>>> processBatch(
      List<String> paths) async {
    const concurrency = 3; // process 3 images at a time
    final results = List<Map<String, String>>.filled(
        paths.length, {'path': '', 'ocrText': '', 'type': 'unknown'});

    for (var i = 0; i < paths.length; i += concurrency) {
      final batch = paths.sublist(i, (i + concurrency).clamp(0, paths.length));
      final batchResults = await Future.wait(
        batch.asMap().entries.map((entry) async {
          final idx = i + entry.key;
          final path = entry.value;
          try {
            final text = await scanImageRaw(path);
            final type = _detectScreenshotTypeFromOCR(text);
            return MapEntry(idx, {
              'path': path,
              'ocrText': text,
              'type': type,
              'error': '',
            });
          } catch (e) {
            return MapEntry(idx, {
              'path': path,
              'ocrText': '',
              'type': 'unknown',
              'error': e.toString().replaceAll('Exception: ', ''),
            });
          }
        }),
      );
      for (final entry in batchResults) {
        results[entry.key] = entry.value;
      }
    }
    return results;
  }

  /// Fast screenshot type detection from OCR text — mirrors LLMService.detectScreenshotType.
  static String _detectScreenshotTypeFromOCR(String text) {
    // Delegate to LLMService's canonical implementation to stay in sync
    // (import avoided at class level; call it inline via identical logic)
    final lower = text.toLowerCase();
    if (lower.contains('steam') || lower.contains('valve corporation'))
      return 'steam';
    if (lower.contains('google play') || lower.contains('play store'))
      return 'google_play';
    if (lower.contains('app store') ||
        lower.contains('itunes') ||
        (lower.contains('apple') && lower.contains('receipt')))
      return 'apple_appstore';
    if (lower.contains('codashop')) return 'codashop';
    if (lower.contains('unipin')) return 'unipin';
    if (lower.contains('garena')) return 'garena';
    if (lower.contains('moonton') || lower.contains('mobile legends'))
      return 'mobile_legends';
    if (lower.contains('gcash')) return 'gcash';
    if (lower.contains('maya') || lower.contains('paymaya')) return 'maya';
    if (lower.contains('grabpay') || lower.contains('grab pay'))
      return 'grabpay';
    if (lower.contains('shopeepay') ||
        lower.contains('shopee pay') ||
        lower.contains('spaylater')) return 'shopeepay';
    if (lower.contains('coins.ph') || lower.contains('coinsph'))
      return 'coins_ph';
    if (lower.contains('paypal')) return 'paypal';
    if (lower.contains('shopee')) return 'shopee';
    if (lower.contains('lazada') || lower.contains('lazwallet'))
      return 'lazada';
    if (lower.contains('zalora')) return 'zalora';
    if (lower.contains('tiktok shop') || lower.contains('tiktokshop'))
      return 'tiktok_shop';
    if (lower.contains('aliexpress')) return 'aliexpress';
    if (lower.contains('amazon') && lower.contains('order')) return 'amazon';
    if (lower.contains('shein')) return 'shein';
    if (lower.contains('temu')) return 'temu';
    if (lower.contains('grabfood') || lower.contains('grab food'))
      return 'grabfood';
    if (lower.contains('foodpanda') || lower.contains('food panda'))
      return 'foodpanda';
    if (lower.contains('grab') &&
        (lower.contains('order') ||
            lower.contains('ride') ||
            lower.contains('car') ||
            lower.contains('bike'))) return 'grab';
    if (lower.contains('angkas')) return 'angkas';
    if (lower.contains('lalamove')) return 'lalamove';
    if (lower.contains('netflix')) return 'netflix';
    if (lower.contains('spotify')) return 'spotify';
    if (lower.contains('bpi') && lower.contains('transaction')) return 'bpi';
    if (lower.contains('bdo') && lower.contains('transaction')) return 'bdo';
    if (lower.contains('metrobank')) return 'metrobank';
    if (lower.contains('unionbank')) return 'unionbank';
    if (lower.contains('gotyme')) return 'gotyme';
    if (lower.contains('jollibee') ||
        lower.contains('mcdonald') ||
        lower.contains('kfc') ||
        lower.contains('starbucks')) return 'receipt_fastfood';
    if (lower.contains('sm supermarket') ||
        lower.contains('puregold') ||
        lower.contains('robinsons supermarket')) return 'receipt_grocery';
    if (lower.contains('mercury drug') || lower.contains('watsons'))
      return 'receipt_pharmacy';
    if (lower.contains('meralco') && lower.contains('amount'))
      return 'receipt_utility';
    if (lower.contains('total') ||
        lower.contains('subtotal') ||
        lower.contains('amount due')) return 'receipt';
    if (RegExp(r'\d{4}-\d{2}-\d{2}').allMatches(text).length >= 3)
      return 'transaction_history';
    return 'unknown';
  }

  /// Extract line items (product names and prices) from receipt text.
  /// Returns a list of maps with keys: 'productName' and 'price'.
  /// Matches patterns like "ItemName ... ₱XX.XX" or "ItemName XX.XX"
  static List<Map<String, dynamic>> extractLineItems(String receiptText) {
    final lines = receiptText.split('\n');
    final items = <Map<String, dynamic>>[];

    // Patterns to match:
    // 1. "ProductName ₱99.99" or "ProductName 99.99"
    // 2. "ProductName ... ₱99.99"
    // 3. "ProductName 1x 99.99"
    final patterns = [
      // Pattern: text followed by currency symbol and price
      RegExp(r'^(.+?)\s*[₱P]?\s*(\d+[,.]?\d*\.?\d{2})\s*$'),
      // Pattern: text with dots/spaces leading to price
      RegExp(r'^(.+?)\s*[.…\s]{2,}\s*[₱P]?\s*(\d+[,.]?\d*\.?\d{2})\s*$'),
      // Pattern: text with quantity indicator
      RegExp(r'^(.+?)\s+\d+x?\s+[₱P]?\s*(\d+[,.]?\d*\.?\d{2})\s*$'),
    ];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      // Skip obvious non-item lines
      if (trimmed.toLowerCase().contains('total') ||
          trimmed.toLowerCase().contains('subtotal') ||
          trimmed.toLowerCase().contains('change') ||
          trimmed.toLowerCase().contains('cash') ||
          trimmed.toLowerCase().contains('vat') ||
          trimmed.toLowerCase().contains('discount') ||
          trimmed.length < 3) {
        continue;
      }

      for (final pattern in patterns) {
        final match = pattern.firstMatch(trimmed);
        if (match != null) {
          final productName = match.group(1)?.trim();
          final priceStr = match.group(2)?.replaceAll(',', '');

          if (productName != null &&
              productName.isNotEmpty &&
              priceStr != null) {
            final price = double.tryParse(priceStr);
            if (price != null && price > 0 && price < 1000000) {
              // Reasonable price range
              items.add({
                'productName': productName,
                'price': price,
              });
              break; // Found match, don't try other patterns
            }
          }
        }
      }
    }

    return items;
  }

  /// Detect if OCR text is from a Philippine government receipt.
  /// Returns 'BIR' | 'SSS' | 'PhilHealth' | 'PagIBIG' | 'LTO' | null.
  static String? detectGovReceiptType(String text) {
    final t = text.toUpperCase();
    if (t.contains('BUREAU OF INTERNAL REVENUE') ||
        t.contains('BIR') && t.contains('OFFICIAL RECEIPT')) return 'BIR';
    if (t.contains('SOCIAL SECURITY SYSTEM') ||
        t.contains('SSS') && (t.contains('CONTRIBUTION') || t.contains('LOAN')))
      return 'SSS';
    if (t.contains('PHILHEALTH') || t.contains('PHILIPPINE HEALTH'))
      return 'PhilHealth';
    if (t.contains('PAG-IBIG') ||
        t.contains('PAGIBIG') ||
        t.contains('HOME DEVELOPMENT MUTUAL')) return 'PagIBIG';
    if (t.contains('LAND TRANSPORTATION OFFICE') ||
        (t.contains('LTO') &&
            (t.contains('REGISTRATION') ||
                t.contains('PLATE') ||
                t.contains('DRIVER')))) return 'LTO';
    return null;
  }

  /// Parse a BIR Official Receipt.
  /// Extracts: orNumber, tin, amount, date.
  static Map<String, String?> parseBirReceipt(String text) {
    final orMatch = RegExp(r'O\.?R\.?\s*(?:NO\.?|NUMBER)?\s*[:#]?\s*([\d-]+)',
            caseSensitive: false)
        .firstMatch(text);
    final tinMatch = RegExp(r'TIN\s*[:#]?\s*([\d-]+)', caseSensitive: false)
        .firstMatch(text);
    final amountMatch = RegExp(r'(?:AMOUNT|TOTAL|DUE)[^\d]*([\d,]+\.?\d*)',
            caseSensitive: false)
        .firstMatch(text);
    final dateMatch = RegExp(
            r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4}|(?:JAN|FEB|MAR|APR|MAY|JUN|JUL|AUG|SEP|OCT|NOV|DEC)[a-z]*\s+\d{1,2},?\s*\d{4})',
            caseSensitive: false)
        .firstMatch(text);
    return {
      'orNumber': orMatch?.group(1),
      'tin': tinMatch?.group(1),
      'amount': amountMatch?.group(1)?.replaceAll(',', ''),
      'date': dateMatch?.group(0),
    };
  }

  /// Parse an SSS receipt/confirmation.
  /// Extracts: ssNumber, amount, date, referenceNumber.
  static Map<String, String?> parseSssReceipt(String text) {
    final ssMatch = RegExp(r'SS\s*(?:NO\.?|NUMBER)?\s*[:#]?\s*([\d-]+)',
            caseSensitive: false)
        .firstMatch(text);
    final amountMatch = RegExp(
            r'(?:AMOUNT|TOTAL|CONTRIBUTION)[^\d]*([\d,]+\.?\d*)',
            caseSensitive: false)
        .firstMatch(text);
    final dateMatch =
        RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})', caseSensitive: false)
            .firstMatch(text);
    final refMatch = RegExp(
            r'(?:REF(?:ERENCE)?|TXN|TRANSACTION)\s*(?:NO\.?)?\s*[:#]?\s*([\dA-Z-]+)',
            caseSensitive: false)
        .firstMatch(text);
    return {
      'ssNumber': ssMatch?.group(1),
      'amount': amountMatch?.group(1)?.replaceAll(',', ''),
      'date': dateMatch?.group(0),
      'referenceNumber': refMatch?.group(1),
    };
  }

  /// Parse a PhilHealth receipt/confirmation.
  /// Extracts: pin, amount, date, referenceNumber.
  static Map<String, String?> parsePhilhealthReceipt(String text) {
    final pinMatch = RegExp(r'(?:PIN|PHILHEALTH\s*NO\.?)\s*[:#]?\s*([\d-]+)',
            caseSensitive: false)
        .firstMatch(text);
    final amountMatch = RegExp(
            r'(?:AMOUNT|PREMIUM|CONTRIBUTION)[^\d]*([\d,]+\.?\d*)',
            caseSensitive: false)
        .firstMatch(text);
    final dateMatch =
        RegExp(r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})', caseSensitive: false)
            .firstMatch(text);
    final refMatch = RegExp(
            r'(?:REF(?:ERENCE)?|TXN|OR\s*NO\.?)\s*[:#]?\s*([\dA-Z-]+)',
            caseSensitive: false)
        .firstMatch(text);
    return {
      'pin': pinMatch?.group(1),
      'amount': amountMatch?.group(1)?.replaceAll(',', ''),
      'date': dateMatch?.group(0),
      'referenceNumber': refMatch?.group(1),
    };
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
