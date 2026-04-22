import re
from collections import Counter

def parse_analysis(filepath):
    with open(filepath, 'rb') as f:
        content = f.read().decode('utf-16le', errors='ignore')
    
    issues = re.findall(r'(\w+) - (.*?) - (.*?) - (\w+)', content)
    
    issue_types = Counter(issue[3] for issue in issues)
    print("Issue types count:")
    for type, count in issue_types.items():
        print(f"{type}: {count}")
    
    print("\nSample issues for top types:")
    for type, _ in issue_types.most_common(5):
        print(f"\n--- {type} ---")
        samples = [i for i in issues if i[3] == type][:5]
        for s in samples:
            print(f"{s[0]} in {s[2]}: {s[1]}")

if __name__ == '__main__':
    parse_analysis('analysis_results.txt')
