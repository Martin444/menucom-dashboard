import os
import re

def fix_print_revert(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace debugPrint(...) back to print(...) in pure dart packages
                new_content = re.sub(r'debugPrint\(', r'print(', content)
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f'Reverted to print in {filepath}')

if __name__ == '__main__':
    fix_print_revert('menu_dart_api')
