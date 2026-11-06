import urllib.request
import os

urls = [
    "https://www.sanfernandocity.gov.ph/wp-content/uploads/city-seal.png",
    "https://www.sanfernandocity.gov.ph/wp-content/uploads/2020/01/city-seal.png",
    "https://upload.wikimedia.org/wikipedia/commons/7/7a/Seal_of_San_Fernando%2C_La_Union.png",
    "https://seeklogo.com/images/S/san-fernando-logo-219803.png",
    "https://www.sanfernandocity.gov.ph/wp-content/themes/sflu/images/logo.png",
]

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"}
out = "docs/tools/extracted_images/logos/seal_sanfernando.png"

for url in urls:
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=10) as response:
            data = response.read()
            if len(data) > 5000:
                with open(out, 'wb') as f:
                    f.write(data)
                print(f"SUCCESS: {url} ({len(data)//1024}KB)")
                break
            else:
                print(f"Too small ({len(data)}B): {url}")
    except Exception as e:
        print(f"Failed: {url} — {e}")
