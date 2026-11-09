from pptx import Presentation

prs = Presentation('3_PRESENTATION_FINAL.pptx')

print('=' * 70)
print('FINAL POWERPOINT VERIFICATION — CRITICAL SLIDES')
print('=' * 70)

critical_checks = {
    'pass': [],
    'fail': []
}

# Slide 9 - Survey
print('\n📊 SLIDE 9 — Survey & Needs Assessment')
slide9_text = ' '.join([s.text.lower() for s in prs.slides[8].shapes if hasattr(s, 'text')])
if 'in progress' in slide9_text or 'will be added' in slide9_text:
    print('  FAIL: Still has in progress warning')
    critical_checks['fail'].append('Slide 9: in progress warning')
else:
    print('  PASS: No in progress warnings')
    critical_checks['pass'].append('Slide 9')

# Slide 11 - Demographics  
print('\n👥 SLIDE 11 — Demographics')
slide11_text = ' '.join([s.text for s in prs.slides[10].shapes if hasattr(s, 'text')])
if 'n=5' in slide11_text.lower() and 'preliminary' in slide11_text.lower():
    print('  FAIL: Still has N=5 preliminary data')
    critical_checks['fail'].append('Slide 11: N=5 preliminary')
elif '20 parents' in slide11_text.lower() and '10 young' in slide11_text.lower():
    print('  FAIL: Demographics inverted (20+10)')
    critical_checks['fail'].append('Slide 11: inverted demographics')
else:
    print('  PASS: Demographics correct or not shown')
    if '10 parents' in slide11_text or '10 young' in slide11_text or 'n=10' in slide11_text.lower():
        print('  CONFIRMED: Shows 10 parents / 20 YP')
    critical_checks['pass'].append('Slide 11')

# Slide 12 - SUS Results
print('\n📈 SLIDE 12 — SUS Results')
slide12_text = ' '.join([s.text for s in prs.slides[11].shapes if hasattr(s, 'text')])
issues = []
if 'preliminary' in slide12_text.lower() and 'n=' in slide12_text.lower():
    issues.append('preliminary N=X')
if 'pending' in slide12_text.lower():
    issues.append('pending text')
if 'n=5' in slide12_text.lower():
    issues.append('N=5 reference')

if issues:
    print(f'  FAIL: {", ".join(issues)}')
    critical_checks['fail'].append(f'Slide 12: {", ".join(issues)}')
else:
    print('  PASS: No preliminary/pending warnings')
    critical_checks['pass'].append('Slide 12')
    
if '61.83' in slide12_text:
    print('  CONFIRMED: Shows correct SUS mean (61.83)')
if 'grade d' in slide12_text.lower():
    print('  CONFIRMED: Shows Grade D')
if 'n=30' in slide12_text.lower():
    print('  CONFIRMED: Shows N=30')

# Final verdict
print('\n' + '=' * 70)
if critical_checks['fail']:
    print(f'VERIFICATION FAILED: {len(critical_checks["fail"])} critical issues')
    for issue in critical_checks['fail']:
        print(f'   - {issue}')
else:
    print(f'ALL CRITICAL CHECKS PASSED: {len(critical_checks["pass"])}/3 slides verified')
    print('\nDEFENSE READY!')
print('=' * 70)
