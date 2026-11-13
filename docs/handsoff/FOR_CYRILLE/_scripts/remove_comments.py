"""
Remove all comments from the DOCX by clearing comments.xml
and removing comment references from document.xml
"""
import zipfile, shutil, os, re
from lxml import etree

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
TEMP = DOCX + '.no_comments_temp.docx'
shutil.copy(DOCX, DOCX + '.comments.bak')

NSMAP = {
    'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main',
    'w14': 'http://schemas.microsoft.com/office/word/2010/wordml',
    'w15': 'http://schemas.microsoft.com/office/word/2012/wordml',
}

EMPTY_COMMENTS = '''<?xml version='1.0' encoding='UTF-8' standalone='yes'?>
<w:comments xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"/>'''

EMPTY_COMMENTS_EXT = '''<?xml version='1.0' encoding='UTF-8' standalone='yes'?>
<w15:commentsEx xmlns:w15="http://schemas.microsoft.com/office/word/2012/wordml"/>'''

with zipfile.ZipFile(DOCX, 'r') as zin:
    with zipfile.ZipFile(TEMP, 'w', zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            data = zin.read(item.filename)

            # Clear comments XML
            if item.filename == 'word/comments.xml':
                data = EMPTY_COMMENTS.encode('utf-8')
                print('Cleared word/comments.xml')

            elif item.filename == 'word/commentsExtended.xml':
                data = EMPTY_COMMENTS_EXT.encode('utf-8')
                print('Cleared word/commentsExtended.xml')

            # Remove comment references from document.xml
            elif item.filename == 'word/document.xml':
                content = data.decode('utf-8')
                original_len = len(content)
                # Remove <w:commentRangeStart .../>
                content = re.sub(r'<w:commentRangeStart[^/]*/>', '', content)
                # Remove <w:commentRangeEnd .../>
                content = re.sub(r'<w:commentRangeEnd[^/]*/>', '', content)
                # Remove <w:commentReference .../>
                content = re.sub(r'<w:commentReference[^/]*/>', '', content)
                removed = original_len - len(content)
                print(f'Removed {removed} chars of comment refs from document.xml')
                data = content.encode('utf-8')

            zout.writestr(item, data)

# Replace original
os.replace(TEMP, DOCX)
print(f'\nSaved: {DOCX}')
print('Comments removed. Open in Word to verify.')

# Verify
with zipfile.ZipFile(DOCX) as z:
    comments_size = z.getinfo('word/comments.xml').file_size
    print(f'comments.xml size: {comments_size} bytes (should be ~200)')
