import os
import subprocess

status_output = subprocess.run('git status --porcelain', shell=True, capture_output=True, text=True).stdout
count = 0
for line in status_output.split('\n'):
    if not line:
        continue
    status = line[:2]
    if status in ('UU', 'AA', 'AU', 'UA'):
        file_path = line[3:].strip()
        if file_path.startswith('"') and file_path.endswith('"'):
            file_path = file_path[1:-1]
            
        resolved = False
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                if '<<<<<<< HEAD' not in content:
                    print(f'File {file_path} already resolved manually. Adding to git.')
                    os.system(f'git add "{file_path}"')
                    resolved = True
        except Exception as e:
            print(f'Error reading {file_path}: {e}')

        if not resolved:
            normalized_path = file_path.replace('\\', '/')
            if 'lib/ServiceOrder' in normalized_path:
                print(f'Accepting theirs for {file_path}')
                os.system(f'git checkout --theirs "{file_path}"')
            else:
                print(f'Accepting ours for {file_path}')
                os.system(f'git checkout --ours "{file_path}"')
            os.system(f'git add "{file_path}"')
            count += 1

print(f'\nFinished processing conflicts. Processed {count} files.')
