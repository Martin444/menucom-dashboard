import os
import re

def fix_print(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                # Skip the scripts directory
                if 'scripts' in filepath:
                    continue
                    
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace print(...) with debugPrint(...)
                # But only if it's not already debugPrint
                new_content = re.sub(r'(?<!debug)print\(', r'debugPrint(', content)
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f'Fixed print in {filepath}')

if __name__ == '__main__':
    fix_print('lib')
    fix_print('pu_material')
    fix_print('menu_dart_api')
