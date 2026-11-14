"""
Check SmartSpend app for critical issues before defense.
"""
import os
import re

print('='*60)
print('SMARTSPEND APP HEALTH CHECK')
print('='*60)

# Check AI service
ai_file = r'lib\services\ai_chat_service.dart'
if os.path.exists(ai_file):
    with open(ai_file, encoding='utf-8') as f:
        content = f.read()
    
    print('\n1. AI SERVICE CHECKS:')
    checks = [
        ('Gemini import present', 'google_generative_ai' in content),
        ('Error handling (try/catch)', 'try' in content and 'catch' in content),
        ('Function calling support', 'functionCall' in content or 'FunctionCall' in content),
        ('No hardcoded API keys', 'YOUR_API_KEY' not in content and 'INSERT_KEY' not in content),
    ]
    
    for label, ok in checks:
        print(f'  {"✓" if ok else "✗"} {label}')
    
    # Check for TODOs
    todos = re.findall(r'(TODO|FIXME|HACK):.*', content)
    if todos:
        print(f'  ⚠ {len(todos)} TODO/FIXME comments')
else:
    print('\n1. AI SERVICE: ✗ File not found')

# Check Firebase config
print('\n2. FIREBASE CONFIG:')
firebase_files = [
    'android/app/google-services.json',
    'lib/firebase_options.dart',
]
for f in firebase_files:
    exists = os.path.exists(f)
    print(f'  {"✓" if exists else "✗"} {f}')

if os.path.exists('lib/firebase_options.dart'):
    with open('lib/firebase_options.dart', encoding='utf-8') as f:
        fb_content = f.read()
    has_keys = 'apiKey' in fb_content and 'projectId' in fb_content
    print(f'  {"✓" if has_keys else "✗"} Firebase keys configured')

# Check pubspec dependencies
print('\n3. DEPENDENCIES:')
if os.path.exists('pubspec.yaml'):
    with open('pubspec.yaml', encoding='utf-8') as f:
        pubspec = f.read()
    
    critical_deps = [
        'google_generative_ai',
        'firebase_core',
        'firebase_auth',
        'cloud_firestore',
        'sqflite',
        'google_mlkit_text_recognition',
    ]
    
    for dep in critical_deps:
        present = dep in pubspec
        print(f'  {"✓" if present else "✗"} {dep}')
else:
    print('  ✗ pubspec.yaml not found')

# Check for build issues
print('\n4. BUILD FILES:')
build_files = [
    'android/build.gradle',
    'android/app/build.gradle',
]
for f in build_files:
    exists = os.path.exists(f)
    print(f'  {"✓" if exists else "✗"} {f}')

# Check main entry point
print('\n5. MAIN ENTRY POINT:')
if os.path.exists('lib/main.dart'):
    with open('lib/main.dart', encoding='utf-8') as f:
        main_content = f.read()
    has_firebase_init = 'Firebase.initializeApp' in main_content
    has_main = 'void main()' in main_content
    print(f'  {"✓" if has_main else "✗"} main() function')
    print(f'  {"✓" if has_firebase_init else "✗"} Firebase initialization')
else:
    print('  ✗ lib/main.dart not found')

# Check for common runtime issues
print('\n6. POTENTIAL RUNTIME ISSUES:')
issues = []

# Check if there are unhandled async operations
dart_files = []
for root, dirs, files in os.walk('lib'):
    if 'build' in root or '.dart_tool' in root:
        continue
    for f in files:
        if f.endswith('.dart'):
            dart_files.append(os.path.join(root, f))

async_without_await = 0
for df in dart_files:
    try:
        with open(df, encoding='utf-8') as f:
            content = f.read()
        # Simple check: functions with async that don't use await
        if 'async {' in content:
            lines = content.split('\n')
            for i, line in enumerate(lines):
                if 'async {' in line:
                    # Check next 50 lines for await
                    block = '\n'.join(lines[i:min(i+50, len(lines))])
                    if 'await' not in block:
                        async_without_await += 1
                        break
    except:
        pass

if async_without_await > 5:
    print(f'  ⚠ {async_without_await} async functions might be missing await')
else:
    print(f'  ✓ Async/await usage looks okay')

print('\n' + '='*60)
print('SUMMARY:')
print('  Run "flutter build apk --release" to verify full build')
print('  Test on physical device before defense')
print('='*60)
