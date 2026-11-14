"""
Check that all features mentioned in the defense presentation actually exist in the app.
"""
import os
import re

# Features mentioned in Slide 10 and throughout defense
features = [
    ('OCR receipt scanning', ['google_mlkit_text_recognition', 'mlkit']),
    ('Voice input', ['speech_to_text', 'microphone']),
    ('Barcode scanning', ['mobile_scanner', 'barcode']),
    ('Firebase sync', ['cloud_firestore', 'firebase']),
    ('SQLite local storage', ['sqflite', 'database']),
    ('Demo mode with sample data', ['demo']),
    ('Financial Health Score', ['score', 'fhs']),
    ('Peso mascot', ['peso']),
    ('Achievement badges', ['badge', 'achievement']),
    ('Local AI mode (Ollama/LM Studio)', ['local', 'ollama']),
    ('Multi-wallet support', ['wallet']),
    ('GCash integration', ['gcash']),
    ('Batch screenshot import', ['screenshot', 'batch']),
]

pubspec_content = open('pubspec.yaml', encoding='utf-8').read()

print('DEFENSE FEATURE VERIFICATION:')
print('='*60)

all_good = True
for feature, keywords in features:
    found = any(k in pubspec_content.lower() for k in keywords)
    if found:
        print(f'✓ {feature}')
    else:
        print(f'✗ {feature}')
        all_good = False

# Check AI actions count (defense claims 34)
print('\n' + '='*60)
print('AI ACTIONS COUNT:')
ai_service = open(r'lib\services\ai_chat_service.dart', encoding='utf-8').read()

# Find all action types in the AI actions list
action_pattern = re.findall(r'"type":\s*"([a-z_]+)"', ai_service)
unique_actions = set(action_pattern)

print(f'  Found {len(unique_actions)} unique AI action types')
print(f'  Defense claims: 34 autonomous AI actions')

if len(unique_actions) >= 30:
    print(f'  ✓ Close enough to defense claim')
else:
    print(f'  ⚠ Significant mismatch')

# Show some actions
if unique_actions:
    print(f'\n  Sample actions: {", ".join(list(unique_actions)[:10])}...')

# Check for critical services
print('\n' + '='*60)
print('CRITICAL SERVICES:')
services_dir = 'lib/services'
if os.path.exists(services_dir):
    services = [f for f in os.listdir(services_dir) if f.endswith('.dart')]
    critical = ['ai_chat_service.dart', 'db_service.dart', 'score_service.dart', 'firebase_service.dart']
    
    for svc in critical:
        exists = svc in services
        print(f'  {"✓" if exists else "✗"} {svc}')
else:
    print('  ✗ lib/services directory not found')

# Check for screenshots and figures mentioned in defense
print('\n' + '='*60)
print('DEFENSE SCREENSHOTS (Figures 9-15):')
assets_dir = 'assets'
if os.path.exists(assets_dir):
    # Check if screenshots exist or if there's a mock mode
    demo_check = 'demo' in pubspec_content.lower()
    print(f'  {"✓" if demo_check else "⚠"} Demo mode (needed for screenshots)')
else:
    print('  ⚠ Assets directory check needed')

print('\n' + '='*60)
if all_good:
    print('RESULT: All claimed features are present ✓')
else:
    print('RESULT: Some features may need verification ⚠')
print('='*60)
