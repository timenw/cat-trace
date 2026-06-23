#!/usr/bin/env python3
"""Fix all broken import paths in the cat_trace project."""
import os
import re
import glob

LIB_DIR = '/root/cat_trace/lib'

# Build a set of all existing .dart file paths (relative to lib/)
existing_files = set()
for root, dirs, files in os.walk(LIB_DIR):
    dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build']]
    for f in files:
        if f.endswith('.dart'):
            full = os.path.join(root, f)
            rel = os.path.relpath(full, LIB_DIR)
            existing_files.add(rel)

print(f"Total .dart files: {len(existing_files)}")

# For each file, check and fix imports
fixed_count = 0
for root, dirs, files in os.walk(LIB_DIR):
    dirs[:] = [d for d in dirs if d not in ['.dart_tool', 'build']]
    for f in files:
        if not f.endswith('.dart'):
            continue
        full_path = os.path.join(root, f)
        file_rel = os.path.relpath(full_path, LIB_DIR)
        file_dir = os.path.dirname(full_path)
        
        with open(full_path, 'r') as fh:
            content = fh.read()
        
        original = content
        
        # Find all relative imports
        for match in re.finditer(r"import\s+'([^']+)'\s*(?:;|show|hide|as)", content):
            import_path = match.group(1)
            if import_path.startswith('package:') or import_path.startswith('dart:'):
                continue
            
            # Resolve relative to the file's directory
            resolved = os.path.normpath(os.path.join(file_dir, import_path))
            resolved_rel = os.path.relpath(resolved, LIB_DIR)
            
            if not os.path.exists(resolved):
                # Try to find the correct path
                # The import might be wrong - let's figure out what they're trying to import
                # Get the last part of the import path
                parts = import_path.split('/')
                target_file = parts[-1]
                
                # Search for this file in existing_files
                candidates = [ef for ef in existing_files if ef.endswith('/' + target_file) or ef == target_file]
                
                if len(candidates) == 1:
                    # Found exactly one match - compute the correct import path
                    candidate = candidates[0]
                    candidate_dir = os.path.dirname(os.path.join(LIB_DIR, candidate))
                    
                    # Compute relative path from file_dir to candidate_dir + filename
                    target_full = os.path.join(LIB_DIR, candidate)
                    correct_import = os.path.relpath(target_full, file_dir)
                    
                    # Normalize: ensure it starts with ./ or ../
                    if not correct_import.startswith('.'):
                        correct_import = './' + correct_import
                    
                    # Replace in content
                    old_import = f"import '{import_path}'"
                    new_import = f"import '{correct_import}'"
                    content = content.replace(old_import, new_import)
                    print(f"  FIXED: {file_rel}: '{import_path}' → '{correct_import}'")
                    fixed_count += 1
                elif len(candidates) > 1:
                    print(f"  AMBIGUOUS: {file_rel}: '{import_path}' matches multiple: {candidates}")
                else:
                    print(f"  NOT FOUND: {file_rel}: '{import_path}' - no matching file")
        
        if content != original:
            with open(full_path, 'w') as fh:
                fh.write(content)

print(f"\nTotal imports fixed: {fixed_count}")
