// Stub for dart:html on non-web platforms.
// When compiled for mobile/desktop, dart:html is not available;
// this stub satisfies the conditional import and is never actually called
// because all call sites are guarded with kIsWeb checks.

class Blob {
  Blob(List<dynamic> parts);
}

class AnchorElement {
  AnchorElement({String? href});
  void setAttribute(String name, String value) {}
  void click() {}
}

class Url {
  static String createObjectUrlFromBlob(Blob blob) => '';
  static void revokeObjectUrl(String url) {}
}
