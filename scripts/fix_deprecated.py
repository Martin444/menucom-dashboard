import os
import re

def fix_with_opacity(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Replace .withOpacity(value) with .withValues(alpha: value)
                # This handles cases like .withOpacity(0.5) or .withOpacity(someVar)
                new_content = re.sub(r'\.withOpacity\((.*?)\)', r'.withValues(alpha: \1)', content)
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f'Fixed withOpacity in {filepath}')

if __name__ == '__main__':
    fix_with_opacity('lib')
    fix_with_opacity('pu_material')
