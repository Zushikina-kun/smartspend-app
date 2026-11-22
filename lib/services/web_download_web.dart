// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Triggers a browser file download for the given text content.
void triggerWebDownload(String content, String fileName) {
  final blob = html.Blob([content]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
