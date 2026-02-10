import yaml
import hashlib
import zipfile
import os
import json


_VALID_JSON_ESCAPES = {'"', '\\', '/', 'b', 'f', 'n', 'r', 't', 'u'}


def _fix_invalid_backslashes(text: str, replace_with: str = "/") -> str:
    """
    Fix invalid backslash escape sequences inside JSON string literals.

    This is a *tolerant* pre-processor to make slightly-invalid JSON
    (e.g. Windows paths like "C:\\foo\\bar" written as "C:\foo\bar")
    parseable by the standard json library.

    Rules:
    - Only operates inside double-quoted strings.
    - Leaves valid escapes (\", \\\\, \\n, \\t, \\uXXXX, etc.) unchanged.
    - When encountering an invalid escape (like \\g, \\s, etc.), replaces
      the backslash with `replace_with` (default "/") and keeps the next
      character as-is.
    """
    out = []
    i = 0
    n = len(text)
    in_string = False

    while i < n:
        ch = text[i]

        # Toggle string state on unescaped double quotes
        if ch == '"' and (i == 0 or text[i - 1] != '\\'):
            in_string = not in_string
            out.append(ch)
            i += 1
            continue

        if in_string and ch == '\\':
            # Look ahead to determine if this is a valid escape
            if i + 1 < n:
                nxt = text[i + 1]
                if nxt in _VALID_JSON_ESCAPES:
                    # Valid escape sequence, keep as-is
                    out.append(ch)
                    out.append(nxt)
                    i += 2
                    continue
                else:
                    # Invalid escape: replace '\' with the chosen replacement
                    out.append(replace_with)
                    i += 1
                    continue
            else:
                # Trailing '\' at end of file/string, treat as invalid
                out.append(replace_with)
                i += 1
                continue

        # Default: copy character
        out.append(ch)
        i += 1

    return "".join(out)


def json_loads_tolerant(s: str, *, replace_with: str = "/"):
    """
    Tolerant wrapper around json.loads.

    - First tries a normal json.loads.
    - If it fails with "Invalid \\escape", applies a light pre-processing
      to fix illegal backslashes inside strings and retries.
    - Other JSON errors are propagated unchanged.
    """
    try:
        return json.loads(s)
    except json.JSONDecodeError as e:
        if "Invalid \\escape" not in str(e):
            raise
        fixed = _fix_invalid_backslashes(s, replace_with=replace_with)
        return json.loads(fixed)
def read_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()
    return content

def read_yaml_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = yaml.safe_load(file)
    return content

def get_file_md5(file_path):
    md5_hash = hashlib.md5()
    with open(file_path, "rb") as f:
        # read file block
        for byte_block in iter(lambda: f.read(4096), b""):
            md5_hash.update(byte_block)
    return md5_hash.hexdigest()


def compress_folder(source_folder, destination_folder, archive_name):
    os.makedirs(destination_folder, exist_ok=True)
    
    archive_path = os.path.join(destination_folder, archive_name)
    
    with zipfile.ZipFile(archive_path, 'w', zipfile.ZIP_DEFLATED) as zipf:

        for root, _, files in os.walk(source_folder):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, source_folder)
                zipf.write(file_path, arcname)
    
    print(f"Folder '{source_folder}' has been compressed to '{archive_path}'")

def get_md5_hash_bytext(text):
    return hashlib.md5(text.encode('utf-8')).hexdigest()

def read_json_file(file_path):
    with open(file_path, 'r', encoding='utf-8') as file:
        content = json.load(file)
    return content


def read_json_file_tolerant(file_path, *, replace_with: str = "/"):
    """
    Read a JSON file with tolerant handling of invalid backslash escapes.

    Typical use case: JSON produced by tools that embed Windows paths like
    "C:\\\\foo\\\\bar" without proper escaping. This helper tries to parse
    normally first, and only falls back to pre-processing when encountering
    an "Invalid \\escape" decoding error.
    """
    with open(file_path, 'r', encoding='utf-8') as file:
        text = file.read()
    return json_loads_tolerant(text, replace_with=replace_with)