import json
import re
import sys
import os

try:
    print(f"Current working directory: {os.getcwd()}")
    if not os.path.exists('prediction_insights.ipynb'):
        print("File not found: prediction_insights.ipynb")
        # List dir to help debug
        print("Files in directory:")
        print(os.listdir('.'))
        sys.exit(1)

    def has_chinese(text):
        return re.search(r'[\u4e00-\u9fff]', text) is not None

    with open('prediction_insights.ipynb', 'r', encoding='utf-8') as f:
        nb = json.load(f)

    print("--- Chinese Content Found ---")
    for cell in nb.get('cells', []):
        if cell.get('cell_type') == 'code':
            source = cell.get('source', [])
            for i, line in enumerate(source):
                if has_chinese(line):
                    print(f"Cell Code Line {i}: {line.strip()}")
except Exception as e:
    print(f"An error occurred: {e}")
    sys.exit(1)
