import os
import json

apps = []
dirs = ['/usr/share/applications', os.path.expanduser('~/.local/share/applications')]

for d in dirs:
    if not os.path.exists(d): continue
    for f in os.listdir(d):
        if f.endswith('.desktop'):
            path = os.path.join(d, f)
            try:
                with open(path, 'r', errors='ignore') as file:
                    name = None
                    exec_cmd = None
                    icon = None
                    no_display = False
                    is_terminal = False
                    is_desktop_entry = False
                    
                    for line in file:
                        line = line.strip()
                        if line == '[Desktop Entry]':
                            is_desktop_entry = True
                            continue
                        if line.startswith('[') and line != '[Desktop Entry]':
                            if is_desktop_entry: break 
                            else: continue
                        
                        if not is_desktop_entry: continue

                        if line.startswith('Name='):
                            if not name: name = line[5:]
                        elif line.startswith('Exec='):
                            if not exec_cmd: exec_cmd = line[5:]
                        elif line.startswith('Icon='):
                            if not icon: icon = line[5:]
                        elif line.startswith('Terminal='):
                            is_terminal = line[9:].lower() == 'true'
                        elif line.startswith('NoDisplay=true'):
                            no_display = True
                    
                    if name and exec_cmd and not no_display:
                        # Remove field codes like %u, %F
                        # Also handle quotes if present
                        cmd = exec_cmd.split('%')[0].strip()
                        if cmd:
                            apps.append({'name': name, 'exec': cmd, 'terminal': is_terminal, 'icon': icon})
            except:
                pass

# Sort by name
apps.sort(key=lambda x: x['name'].lower())
print(json.dumps(apps))
