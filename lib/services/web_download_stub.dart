/// No-op stub for platforms where dart:html is unavailable (mobile, desktop).
/// All call sites are guarded with kIsWeb so these are never actually invoked.
void triggerWebDownload(String content, String fileName) {}
