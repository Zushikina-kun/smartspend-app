content = open('defense_reviewer.html', encoding='utf-8').read()
# Fix slide guide section id
content = content.replace(
    '<section id="tips">\n<h2>📋 Slide-by-Slide Cheat Sheet</h2>',
    '<section id="slides">\n<h2>📋 Slide-by-Slide Cheat Sheet</h2>'
)
# Fix nav link
content = content.replace(
    '<a href="#tips">Slides</a>',
    '<a href="#slides">Slides</a>'
)
print(f'tips sections: {content.count("id=\"tips\"")}')
print(f'slides sections: {content.count("id=\"slides\"")}')
open('defense_reviewer.html', 'w', encoding='utf-8').write(content)
print('done')
