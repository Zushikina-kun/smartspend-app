# Flutter wrapper
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ML Kit — keep text recognizer classes to prevent R8 stripping
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }

# Google Sign-In
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# SQLite / sqflite
-keep class io.flutter.plugins.sqflite.** { *; }

# local_auth (biometrics)
-keep class io.flutter.plugins.localauth.** { *; }

# mobile_scanner
-keep class com.google.zxing.** { *; }
-dontwarn com.google.zxing.**

# Play Core (not needed for direct APK)
-dontwarn com.google.android.play.core.**

# HTTP / OkHttp
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep class okio.** { *; }

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**
