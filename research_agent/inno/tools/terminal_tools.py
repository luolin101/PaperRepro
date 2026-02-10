import os
import socket
import json
import base64
import math
# from metachain.util import run_command_in_container
from research_agent.inno.environment.docker_env import DockerEnv, DockerConfig
from research_agent.inno.registry import register_tool
from research_agent.inno.environment.markdown_browser.requests_markdown_browser import RequestsMarkdownBrowser
from typing import Tuple, Optional, Dict
import time
import tiktoken
from datetime import datetime
from functools import wraps
from rich.console import Console
from pathlib import Path

terminal_env = RequestsMarkdownBrowser(local_root=os.getcwd(), workplace_name="terminal_env", viewport_size=1024 * 6)
_last_terminal_file = None  # Track the last opened terminal output file

def _get_browser_state(env: RequestsMarkdownBrowser) -> Tuple[str, str]:
    """
    Get the current state of the browser, including the header and content.
    """
    # Ensure history is not empty
    if not env.history:
        return ("Error: No terminal output loaded. Please run a command first to view its output.", "")
    
    # Ensure viewport_pages is not empty and current_page is valid
    if not env.viewport_pages:
        if env.page_content:
            env.viewport_pages = [(0, len(env.page_content))]
        else:
            return ("Error: No terminal output content available.", "")
    
    if env.viewport_current_page < 0:
        env.viewport_current_page = 0
    if env.viewport_current_page >= len(env.viewport_pages):
        env.viewport_current_page = max(0, len(env.viewport_pages) - 1)
    
    # Get address safely
    try:
        address = env.address
    except (IndexError, AttributeError):
        return ("Error: Invalid terminal state. Please run a command first to view its output.", "")
    
    # Extract tool name from address
    try:
        tool_name = address.split('/')[-1].split('.')[0].split('___')[-1]
        if tool_name == "about:blank":
            tool_name = "blank"
    except:
        tool_name = "terminal"
    
    header = f"[The output of the tool `{tool_name}` showing in the interactive terminal]\n"

    current_page = env.viewport_current_page
    total_pages = len(env.viewport_pages)

    
    for i in range(len(env.history) - 2, -1, -1):  # Start from the second last
        if env.history[i][0] == address:
            header += f"You previously visited this page of terminal {round(time.time() - env.history[i][1])} seconds ago.\n"
            break
    prefix = f"[Your terminal is currently open to the page '{env.page_title}']\n" if env.page_title is not None else ""
    
    header = prefix + header
    header += f"Terminal viewport position: Showing page {current_page+1} of {total_pages}.\n"
    if total_pages > 1:
        header += f"[NOTE] The output of the tool `{tool_name}`, you can use `terminal_page_up` to scroll up and `terminal_page_down` to scroll down. If there are many pages with meaningless content like progress bar or output of generating directory structure when there are many datasets in the directory, you can use `terminal_page_to` to move the viewport to the end of terminal where the meaningful content is.\n"
    return (header, env.viewport)

def open_local_terminal_output(path: str):
    """
    Open a local file at a path in the text-based browser and return current viewport content.

    Args:
        path: The absolute path of a local file to visit.
    """
    global _last_terminal_file
    try:
        full_path = os.path.abspath(os.path.expanduser(path))
        # Normalize the path to ensure consistency
        full_path = os.path.normpath(full_path)
        
        # DEBUG: Log before opening
        old_path = getattr(terminal_env, '_current_page_path', None)
        print(f"DEBUG open_local_terminal_output: Opening {full_path}")
        print(f"DEBUG open_local_terminal_output: Old _current_page_path = {old_path}")
        
        # Open the file
        terminal_env.open_local_file(full_path)
        
        # DEBUG: Log after open_local_file
        after_open_path = getattr(terminal_env, '_current_page_path', None)
        print(f"DEBUG open_local_terminal_output: After open_local_file, _current_page_path = {after_open_path}")
        
        # CRITICAL: Ensure _current_page_path is set correctly after open_local_file
        # The issue is that open_local_file calls set_address which calls _fetch_page,
        # and _fetch_page processes the file:// URI but doesn't update _current_page_path
        # So we must explicitly set it here AFTER all the processing is done
        if hasattr(terminal_env, '_current_page_path'):
            terminal_env._current_page_path = full_path
            # Also verify that terminal_env.address matches the file we opened
            expected_uri = Path(full_path).as_uri()
            current_address = getattr(terminal_env, 'address', None)
            if current_address != expected_uri:
                # If address doesn't match, it means something went wrong
                # Try to fix it by setting address directly (but don't fetch again)
                # Just update the address and ensure _current_page_path is set
                print(f"DEBUG open_local_terminal_output: Address mismatch! Expected {expected_uri}, got {current_address}")
                terminal_env.address = expected_uri
                terminal_env._current_page_path = full_path
        
        # Final verification: ensure _current_page_path is set to the file we just opened
        # This is a double-check to prevent race conditions or other issues
        if hasattr(terminal_env, '_current_page_path'):
            if terminal_env._current_page_path != full_path:
                print(f"DEBUG open_local_terminal_output: Final verification failed! Setting _current_page_path to {full_path}")
                terminal_env._current_page_path = full_path
        
        final_path = getattr(terminal_env, '_current_page_path', None)
        print(f"DEBUG open_local_terminal_output: Final _current_page_path = {final_path}")
        
        # Always update _last_terminal_file when opening a file (for terminal output, read_file output, etc.)
        # This allows terminal_page_* functions to restore to the currently viewed file
        if "terminal_output_" in os.path.basename(full_path) and "__" in os.path.basename(full_path):
            _last_terminal_file = full_path  # Save the last opened file
            print(f"DEBUG open_local_terminal_output: Updated _last_terminal_file = {_last_terminal_file}")
            
        header, content = _get_browser_state(terminal_env)
        final_response = header.strip() + "\n==============================================\n" + content + "\n==============================================\n"
        return final_response
    except Exception as e:
        return f"Error in `open_local_terminal_output`: {e}"
    
@register_tool("terminal_page_up")
def terminal_page_up():
    """
    Scroll the viewport UP one page-length in the current terminal. Use this function when the terminal is too long and you want to scroll up to see the previous content.
    """
    global _last_terminal_file
    try:
        # First, check _current_page_path (most reliable - it's the actual file that's currently open)
        current_file_path = None
        if hasattr(terminal_env, '_current_page_path') and terminal_env._current_page_path:
            if os.path.exists(terminal_env._current_page_path):
                basename = os.path.basename(terminal_env._current_page_path)
                # Accept any terminal_output_* file (including read_file outputs)
                if "terminal_output_" in basename and "__" in basename:
                    current_file_path = terminal_env._current_page_path
        
        # Normalize path
        normalized_current_path = None
        if current_file_path:
            normalized_current_path = os.path.normpath(os.path.abspath(current_file_path))
        
        # If we have a valid current file path from _current_page_path, use it directly
        if normalized_current_path:
            # Current file is valid - update _last_terminal_file and use it directly
            _last_terminal_file = normalized_current_path
            needs_restore = False
        else:
            # Current file is invalid - need to restore
            needs_restore = (not terminal_env.viewport_pages or 
                            not terminal_env.page_content or
                            not terminal_env.history or
                            terminal_env.address == "about:blank")
        
        if needs_restore:
            # Try multiple methods to find the file to restore
            file_to_open = None
            
            # Method 1: Try _last_terminal_file global variable (if it's a terminal output file) - PRIORITY
            if _last_terminal_file and os.path.exists(_last_terminal_file):
                # Check if it's a terminal output file (has terminal_output_ prefix and __ separator)
                basename = os.path.basename(_last_terminal_file)
                if "terminal_output_" in basename and "__" in basename:
                    file_to_open = _last_terminal_file
            
            # Method 2: Try to find the most recent terminal output file in terminal_tmp (PRIORITY)
            if not file_to_open:
                tmp_dir = os.path.join(os.getcwd(), "terminal_tmp")
                if os.path.exists(tmp_dir):
                    import glob
                    pattern = os.path.join(tmp_dir, "terminal_output_*___*.txt")
                    files = glob.glob(pattern)
                    if files:
                        files.sort(key=os.path.getmtime, reverse=True)
                        file_to_open = files[0]
                        _last_terminal_file = file_to_open
            
            # Method 3: Try terminal_env._current_page_path (if it's a terminal output file)
            if not file_to_open and hasattr(terminal_env, '_current_page_path') and terminal_env._current_page_path:
                if os.path.exists(terminal_env._current_page_path):
                    # Check if it's a terminal output file
                    basename = os.path.basename(terminal_env._current_page_path)
                    if "terminal_output_" in basename and "__" in basename:
                        file_to_open = terminal_env._current_page_path
            
            # Method 4: Try to find from history, but ONLY terminal output files (exclude read_file)
            if not file_to_open and terminal_env.history:
                for addr, _ in reversed(terminal_env.history):
                    if addr.startswith("file://"):
                        # Extract file path from file:// URI
                        file_path = addr[7:]  # Remove "file://" prefix
                        # Handle Windows paths (file:///C:/path or file:///C|/path)
                        if os.name == "nt" and len(file_path) >= 3 and file_path[0] == "/":
                            if file_path[2] == ":":
                                file_path = file_path[1:]  # Remove leading /
                            elif file_path[2] == "|":
                                file_path = file_path[1:2] + ":" + file_path[3:]  # Convert | to :
                        if os.path.exists(file_path):
                            # Only consider terminal output files (including read_file outputs)
                            basename = os.path.basename(file_path)
                            if "terminal_output_" in basename and "__" in basename:
                                file_to_open = file_path
                                _last_terminal_file = file_to_open
                                break
            
            if file_to_open:
                terminal_env.open_local_file(file_to_open)
                _last_terminal_file = file_to_open
            else:
                return "Error: No terminal output loaded. Please run a command first to view its output."
        
        # Final check - ensure we have valid content
        if not terminal_env.viewport_pages:
            if terminal_env.page_content:
                terminal_env._set_page_content(terminal_env.page_content)
            else:
                return "Error: No terminal output loaded. Please run a command first to view its output."
        
        terminal_env.page_up()
        header, content = _get_browser_state(terminal_env)
        final_response = header.strip() + "\n==============================================\n" + content + "\n==============================================\n"
        return final_response
    except Exception as e:
        return f"Error in `page_up`: {e}"
    
@register_tool("terminal_page_down")
def terminal_page_down():
    """
    Scroll the viewport DOWN one page-length in the current terminal. Use this function when the terminal is too long and you want to scroll down to see the next content.
    """
    global _last_terminal_file
    try:
        # ========== DEBUG OUTPUT START ==========
        print("\n" + "=" * 80)
        print("DEBUG: terminal_page_down() called")
        print("=" * 80)
        
        # Check _current_page_path
        current_page_path_value = None
        if hasattr(terminal_env, '_current_page_path'):
            current_page_path_value = terminal_env._current_page_path
        print(f"DEBUG: terminal_env._current_page_path = {current_page_path_value}")
        print(f"DEBUG: _current_page_path exists? {current_page_path_value is not None}")
        if current_page_path_value:
            print(f"DEBUG: _current_page_path file exists? {os.path.exists(current_page_path_value)}")
            if os.path.exists(current_page_path_value):
                basename_check = os.path.basename(current_page_path_value)
                print(f"DEBUG: _current_page_path basename = {basename_check}")
                is_terminal_output = "terminal_output_" in basename_check and "__" in basename_check
                print(f"DEBUG: _current_page_path is terminal output? {is_terminal_output}")
        
        # Check _last_terminal_file
        print(f"DEBUG: _last_terminal_file = {_last_terminal_file}")
        if _last_terminal_file:
            print(f"DEBUG: _last_terminal_file exists? {os.path.exists(_last_terminal_file)}")
        
        # Check terminal_env.address
        try:
            current_address = terminal_env.address
            print(f"DEBUG: terminal_env.address = {current_address}")
        except:
            print("DEBUG: terminal_env.address = (error getting address)")
        
        # Check terminal_tmp directory
        tmp_dir = os.path.join(os.getcwd(), "terminal_tmp")
        print(f"DEBUG: terminal_tmp directory = {tmp_dir}")
        print(f"DEBUG: terminal_tmp exists? {os.path.exists(tmp_dir)}")
        if os.path.exists(tmp_dir):
            import glob
            pattern = os.path.join(tmp_dir, "terminal_output_*___*.txt")
            files = glob.glob(pattern)
            print(f"DEBUG: Found {len(files)} terminal output files in terminal_tmp")
            if files:
                files_with_mtime = [(f, os.path.getmtime(f)) for f in files]
                files_with_mtime.sort(key=lambda x: x[1], reverse=True)  # Sort by mtime, newest first
                print("DEBUG: Files in terminal_tmp (sorted by mtime, newest first):")
                for i, (f, mtime) in enumerate(files_with_mtime[:10], 1):  # Show top 10
                    from datetime import datetime
                    mtime_str = datetime.fromtimestamp(mtime).strftime("%Y-%m-%d %H:%M:%S.%f")
                    basename = os.path.basename(f)
                    print(f"  {i}. {basename} (mtime: {mtime_str})")
        
        # Check terminal_env state
        print(f"DEBUG: terminal_env.viewport_pages = {len(terminal_env.viewport_pages) if terminal_env.viewport_pages else 0}")
        print(f"DEBUG: terminal_env.page_content length = {len(terminal_env.page_content) if terminal_env.page_content else 0}")
        print(f"DEBUG: terminal_env.history length = {len(terminal_env.history) if terminal_env.history else 0}")
        print("=" * 80 + "\n")
        # ========== DEBUG OUTPUT END ==========
        
        # First, check _current_page_path (most reliable - it's the actual file that's currently open)
        current_file_path = None
        if hasattr(terminal_env, '_current_page_path') and terminal_env._current_page_path:
            if os.path.exists(terminal_env._current_page_path):
                basename = os.path.basename(terminal_env._current_page_path)
                # Accept any terminal_output_* file (including read_file outputs)
                if "terminal_output_" in basename and "__" in basename:
                    current_file_path = terminal_env._current_page_path
                    print(f"DEBUG: Using _current_page_path: {current_file_path}")
        
        # CRITICAL FIX: Check if _current_page_path points to an outdated file
        # If so, find the most recent terminal_output file and use that instead
        if current_file_path:
            tmp_dir = os.path.join(os.getcwd(), "terminal_tmp")
            if os.path.exists(tmp_dir):
                import glob
                pattern = os.path.join(tmp_dir, "terminal_output_*___*.txt")
                files = glob.glob(pattern)
                if files:
                    files.sort(key=os.path.getmtime, reverse=True)
                    newest_file = files[0]
                    current_file_mtime = os.path.getmtime(current_file_path)
                    newest_file_mtime = os.path.getmtime(newest_file)
                    
                    # If the newest file is newer than current_file_path, use the newest file
                    if newest_file_mtime > current_file_mtime:
                        print(f"DEBUG: _current_page_path points to outdated file!")
                        print(f"DEBUG: Current file mtime: {current_file_mtime}, Newest file mtime: {newest_file_mtime}")
                        print(f"DEBUG: Switching to newest file: {newest_file}")
                        # CRITICAL: We must actually OPEN the new file, not just update variables!
                        terminal_env.open_local_file(newest_file)
                        terminal_env._current_page_path = newest_file
                        _last_terminal_file = newest_file
                        current_file_path = newest_file
                        print(f"DEBUG: Successfully opened newest file and updated state")
        
        # Normalize path
        normalized_current_path = None
        if current_file_path:
            normalized_current_path = os.path.normpath(os.path.abspath(current_file_path))
        
        # If we have a valid current file path from _current_page_path, use it directly
        if normalized_current_path:
            # Current file is valid - update _last_terminal_file and use it directly
            _last_terminal_file = normalized_current_path
            needs_restore = False
            print(f"DEBUG: No restore needed, using current file: {normalized_current_path}")
            # Ensure viewport is at the beginning if we just switched files
            # (This prevents showing old file's page content when switching to new file)
            if terminal_env.viewport_current_page >= len(terminal_env.viewport_pages):
                terminal_env.viewport_current_page = 0
        else:
            # Current file is invalid - need to restore
            needs_restore = (not terminal_env.viewport_pages or 
                            not terminal_env.page_content or
                            not terminal_env.history or
                            terminal_env.address == "about:blank")
            print(f"DEBUG: needs_restore = {needs_restore}")
            if needs_restore:
                print(f"  - viewport_pages empty? {not terminal_env.viewport_pages}")
                print(f"  - page_content empty? {not terminal_env.page_content}")
                print(f"  - history empty? {not terminal_env.history}")
                try:
                    print(f"  - address is about:blank? {terminal_env.address == 'about:blank'}")
                except:
                    print(f"  - address check failed")
        
        if needs_restore:
            print("DEBUG: Entering restore logic...")
            # Try multiple methods to find the file to restore
            file_to_open = None
            
            # Method 1: Try _last_terminal_file global variable (if it's a terminal output file) - PRIORITY
            if _last_terminal_file and os.path.exists(_last_terminal_file):
                # Check if it's a terminal output file (has terminal_output_ prefix and __ separator)
                basename = os.path.basename(_last_terminal_file)
                if "terminal_output_" in basename and "__" in basename:
                    file_to_open = _last_terminal_file
                    print(f"DEBUG: Method 1 selected: {_last_terminal_file}")
            
            # Method 2: Try to find the most recent terminal output file in terminal_tmp (PRIORITY)
            if not file_to_open:
                tmp_dir = os.path.join(os.getcwd(), "terminal_tmp")
                if os.path.exists(tmp_dir):
                    import glob
                    pattern = os.path.join(tmp_dir, "terminal_output_*___*.txt")
                    files = glob.glob(pattern)
                    if files:
                        files.sort(key=os.path.getmtime, reverse=True)
                        file_to_open = files[0]
                        _last_terminal_file = file_to_open
                        print(f"DEBUG: Method 2 selected (newest file): {file_to_open}")
                        from datetime import datetime
                        mtime_str = datetime.fromtimestamp(os.path.getmtime(file_to_open)).strftime("%Y-%m-%d %H:%M:%S.%f")
                        print(f"DEBUG: Method 2 file mtime: {mtime_str}")
            
            # Method 3: Try terminal_env._current_page_path (if it's a terminal output file)
            if not file_to_open and hasattr(terminal_env, '_current_page_path') and terminal_env._current_page_path:
                if os.path.exists(terminal_env._current_page_path):
                    # Check if it's a terminal output file
                    basename = os.path.basename(terminal_env._current_page_path)
                    if "terminal_output_" in basename and "__" in basename:
                        file_to_open = terminal_env._current_page_path
                        print(f"DEBUG: Method 3 selected: {terminal_env._current_page_path}")
            
            # Method 4: Try to find from history, but ONLY terminal output files (exclude read_file)
            if not file_to_open and terminal_env.history:
                for addr, _ in reversed(terminal_env.history):
                    if addr.startswith("file://"):
                        # Extract file path from file:// URI
                        file_path = addr[7:]  # Remove "file://" prefix
                        # Handle Windows paths (file:///C:/path or file:///C|/path)
                        if os.name == "nt" and len(file_path) >= 3 and file_path[0] == "/":
                            if file_path[2] == ":":
                                file_path = file_path[1:]  # Remove leading /
                            elif file_path[2] == "|":
                                file_path = file_path[1:2] + ":" + file_path[3:]  # Convert | to :
                        if os.path.exists(file_path):
                            # Only consider terminal output files (including read_file outputs)
                            basename = os.path.basename(file_path)
                            if "terminal_output_" in basename and "__" in basename:
                                file_to_open = file_path
                                _last_terminal_file = file_to_open
                                print(f"DEBUG: Method 4 selected from history: {file_path}")
                                break
            
            if file_to_open:
                print(f"DEBUG: Restoring to file: {file_to_open}")
                terminal_env.open_local_file(file_to_open)
                _last_terminal_file = file_to_open
                print(f"DEBUG: After restore, _current_page_path = {getattr(terminal_env, '_current_page_path', None)}")
            else:
                print("DEBUG: No file found to restore!")
                return "Error: No terminal output loaded. Please run a command first to view its output."
        
        # Final check - ensure we have valid content
        if not terminal_env.viewport_pages:
            if terminal_env.page_content:
                terminal_env._set_page_content(terminal_env.page_content)
            else:
                return "Error: No terminal output loaded. Please run a command first to view its output."
        
        terminal_env.page_down()
        header, content = _get_browser_state(terminal_env)
        final_response = header.strip() + "\n==============================================\n" + content + "\n==============================================\n"
        return final_response
    except Exception as e:
        return f"Error in `page_down`: {e}"

@register_tool("terminal_page_to")
def terminal_page_to(page_idx: int):
    """
    Move the viewport to the specified page index. The index starts from 1.
    Use this function when you want to move the viewport to a specific page, especially when the middle of terminal output are meaningless, like the output of progress bar or output of generating directory structure when there are many datasets in the directory, you can use this function to move the viewport to the end of terminal where the meaningful content is.
    """
    global _last_terminal_file
    try:
        # First, check _current_page_path (most reliable - it's the actual file that's currently open)
        current_file_path = None
        if hasattr(terminal_env, '_current_page_path') and terminal_env._current_page_path:
            if os.path.exists(terminal_env._current_page_path):
                basename = os.path.basename(terminal_env._current_page_path)
                # Accept any terminal_output_* file (including read_file outputs)
                if "terminal_output_" in basename and "__" in basename:
                    current_file_path = terminal_env._current_page_path
        
        # Normalize path
        normalized_current_path = None
        if current_file_path:
            normalized_current_path = os.path.normpath(os.path.abspath(current_file_path))
        
        # If we have a valid current file path from _current_page_path, use it directly
        if normalized_current_path:
            # Current file is valid - update _last_terminal_file and use it directly
            _last_terminal_file = normalized_current_path
            needs_restore = False
        else:
            # Current file is invalid - need to restore
            needs_restore = (not terminal_env.viewport_pages or 
                            not terminal_env.page_content or
                            not terminal_env.history or
                            terminal_env.address == "about:blank")
        
        if needs_restore:
            # Try multiple methods to find the file to restore
            file_to_open = None
            
            # Method 1: Try _last_terminal_file global variable (if it's a terminal output file) - PRIORITY
            if _last_terminal_file and os.path.exists(_last_terminal_file):
                # Check if it's a terminal output file (has terminal_output_ prefix and __ separator)
                basename = os.path.basename(_last_terminal_file)
                if "terminal_output_" in basename and "__" in basename:
                    file_to_open = _last_terminal_file
            
            # Method 2: Try to find the most recent terminal output file in terminal_tmp (PRIORITY)
            if not file_to_open:
                tmp_dir = os.path.join(os.getcwd(), "terminal_tmp")
                if os.path.exists(tmp_dir):
                    import glob
                    pattern = os.path.join(tmp_dir, "terminal_output_*___*.txt")
                    files = glob.glob(pattern)
                    if files:
                        files.sort(key=os.path.getmtime, reverse=True)
                        file_to_open = files[0]
                        _last_terminal_file = file_to_open
            
            # Method 3: Try terminal_env._current_page_path (if it's a terminal output file)
            if not file_to_open and hasattr(terminal_env, '_current_page_path') and terminal_env._current_page_path:
                if os.path.exists(terminal_env._current_page_path):
                    # Check if it's a terminal output file
                    basename = os.path.basename(terminal_env._current_page_path)
                    if "terminal_output_" in basename and "__" in basename:
                        file_to_open = terminal_env._current_page_path
            
            # Method 4: Try to find from history, but ONLY terminal output files (exclude read_file)
            if not file_to_open and terminal_env.history:
                for addr, _ in reversed(terminal_env.history):
                    if addr.startswith("file://"):
                        # Extract file path from file:// URI
                        file_path = addr[7:]  # Remove "file://" prefix
                        # Handle Windows paths (file:///C:/path or file:///C|/path)
                        if os.name == "nt" and len(file_path) >= 3 and file_path[0] == "/":
                            if file_path[2] == ":":
                                file_path = file_path[1:]  # Remove leading /
                            elif file_path[2] == "|":
                                file_path = file_path[1:2] + ":" + file_path[3:]  # Convert | to :
                        if os.path.exists(file_path):
                            # Only consider terminal output files (including read_file outputs)
                            basename = os.path.basename(file_path)
                            if "terminal_output_" in basename and "__" in basename:
                                file_to_open = file_path
                                _last_terminal_file = file_to_open
                                break
            
            if file_to_open:
                terminal_env.open_local_file(file_to_open)
                _last_terminal_file = file_to_open
            else:
                return "Error: No terminal output loaded. Please run a command first to view its output."
        
        # Final check - ensure we have valid content
        if not terminal_env.viewport_pages:
            if terminal_env.page_content:
                terminal_env._set_page_content(terminal_env.page_content)
            else:
                return "Error: No terminal output loaded. Please run a command first to view its output."
        
        terminal_env.page_to(page_idx - 1)
        header, content = _get_browser_state(terminal_env)
        final_response = header.strip() + "\n==============================================\n" + content + "\n==============================================\n"
        return final_response
    except Exception as e:
        return f"Error in `page_to`: {e}"

def process_terminal_response(func):
    """
    装饰器函数，用于处理命令执行的响应结果
    - 如果结果是包含 status 和 result 的字典，返回格式化后的结果
    - 如果结果是错误字符串，直接返回
    """
    @wraps(func)  # 保持原函数的签名和文档
    def wrapper(*args, **kwargs):
        result = func(*args, **kwargs)
        
        # 如果返回值是字典且包含 status 和 result
        if isinstance(result, dict) and 'status' in result and 'result' in result:
            try:
                res_output = result['result']
                if res_output == "": res_output = " "
                tmp_dir = os.path.join(os.getcwd(), "terminal_tmp")
                os.makedirs(tmp_dir, exist_ok=True)
                # Use timestamp with microseconds to avoid filename collisions
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S_%f")
                tmp_file = os.path.join(os.getcwd(), "terminal_tmp", "terminal_output_{}___{}.txt".format(timestamp, func.__name__))
                
                with open(tmp_file, "w", encoding="utf-8") as f:
                    f.write(res_output)
                return open_local_terminal_output(tmp_file)
                # return res_output
            except Exception as e:
                return f"Error in the post-processing of `{func.__name__}`: {e}"
            
        elif isinstance(result, str):
            return result
        else:
            return f"Error in `{func.__name__}`: {result}"
    
    return wrapper
@register_tool("read_file")
@process_terminal_response
def read_file(file_path: str, env: DockerEnv) -> str:
    """
    Read the contents of a file and return it as a string. 
    Supports most text-based formats including code files, documents (PDF, DOCX, DOC, RTF, LaTeX), 
    data formats (JSON, XML, YAML), web formats (HTML), and more.
    The tool automatically detects the file format and uses appropriate parsers.
    
    NOTE: This tool cannot read binary files such as images, audio, or video files. 
    For images, use `add_image_to_context` instead. For audio/video files, use appropriate specialized tools.
    
    Args:
        file_path: The path of the file to read (absolute path recommended).
    Returns:
        A string representation of the contents of the file.
    """
    try:
        # Check for unsupported binary file types (images, audio, video)
        file_ext = os.path.splitext(file_path)[1].lower()
        
        # Image formats
        image_extensions = {'.png', '.jpg', '.jpeg', '.gif', '.bmp', '.tiff', '.tif', '.svg', 
                           '.webp', '.ico', '.heic', '.heif', '.raw', '.cr2', '.nef', '.orf', '.sr2'}
        # Audio formats
        audio_extensions = {'.mp3', '.wav', '.flac', '.aac', '.ogg', '.wma', '.m4a', '.opus', 
                           '.amr', '.au', '.ra', '.aiff', '.mpa'}
        # Video formats
        video_extensions = {'.mp4', '.avi', '.mov', '.mkv', '.wmv', '.flv', '.webm', '.m4v', 
                           '.mpg', '.mpeg', '.3gp', '.rm', '.rmvb', '.vob', '.asf', '.divx'}
        
        unsupported_extensions = image_extensions | audio_extensions | video_extensions
        
        if file_ext in unsupported_extensions:
            file_type = "image" if file_ext in image_extensions else ("audio" if file_ext in audio_extensions else "video")
            return {
                "status": 1, 
                "result": f"Error: Cannot read {file_type} files (extension: {file_ext}) with read_file tool. "
                         f"For images, use `add_image_to_context` instead. For audio/video files, use appropriate specialized tools."
            }
        from research_agent.inno.environment.local_env import LocalEnv
        from research_agent.inno.tools.file_parser import decode_textual_file
        
        # Try to get local file path
        local_file_path = None
        
        # Check if it's LocalEnv - use path directly
        if isinstance(env, LocalEnv):
            local_file_path = os.path.abspath(file_path)
            # If path is relative, make it relative to local_workplace
            if not os.path.isabs(file_path):
                local_file_path = os.path.join(env.local_workplace, file_path)
        else:
            # For DockerEnv, try to convert container path to local path
            if hasattr(env, 'docker_workplace') and hasattr(env, 'local_workplace'):
                if env.docker_workplace in file_path:
                    # Replace docker_workplace with local_workplace
                    local_file_path = file_path.replace(env.docker_workplace, env.local_workplace)
                    # Normalize path separators
                    local_file_path = os.path.normpath(local_file_path)
                elif not os.path.isabs(file_path):
                    # Relative path - try joining with local_workplace
                    local_file_path = os.path.join(env.local_workplace, file_path)
                else:
                    # Already absolute path, try as-is
                    local_file_path = file_path
            else:
                local_file_path = file_path
        
        # Try to use file parser if file exists locally
        if local_file_path and os.path.exists(local_file_path):
            try:
                content = decode_textual_file(local_file_path)
                return {"status": 0, "result": content}
            except Exception as e:
                # If parsing fails, fall back to command-based reading
                pass
        
        # Fallback to command-based reading (original method)
        # Detect if running on Windows
        is_windows = False
        if isinstance(env, LocalEnv):
            is_windows = os.name == "nt"
        
        if is_windows:
            # Use PowerShell Get-Content for Windows
            command = f'Get-Content -Path "{file_path}" -Raw'
        else:
            # Use cat for Linux/Mac
            command = f"cat {file_path}"
        
        response = env.run_command(command)  # status, result
        return response
        
    except FileNotFoundError:
        return {"status": 1, "result": f"Error: File not found: {file_path}"}
    except Exception as e:
        return {"status": 1, "result": f"Error reading file {file_path}: {str(e)}"}

def write_file_in_chunks(file_content, output_path, env, chunk_size=100000):
    # Check if this is LocalEnv - if so, write directly without base64
    from research_agent.inno.environment.local_env import LocalEnv
    if isinstance(env, LocalEnv):
        try:
            # For local environment, write directly to file
            output_path = os.path.abspath(output_path)
            dir_path = os.path.dirname(output_path)
            if dir_path:  # Only create directory if it's not empty
                os.makedirs(dir_path, exist_ok=True)
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(file_content)
            return f"File created at: {output_path}"
        except Exception as e:
            return f"Error creating file {output_path}: {str(e)}"
    
    # For DockerEnv, use base64 encoding (original method)
    encoded_content = base64.b64encode(file_content.encode('utf-8')).decode('utf-8')
    total_chunks = math.ceil(len(encoded_content) / chunk_size)
    
    for i in range(total_chunks):
        start = i * chunk_size
        end = (i + 1) * chunk_size
        chunk = encoded_content[start:end]
        
        # use cat command
        if i == 0:
            command = f"echo \"{chunk}\" | base64 -d > {output_path}"
        else:
            command = f"echo \"{chunk}\" | base64 -d >> {output_path}"
        
        response = env.run_command(command)
        
        if response["status"] != 0:
            return f"Error creating file {output_path}: " + response["result"]
        
        # print(f"Successfully written block {i+1}/{total_chunks}")
    
    return f"File created at: {output_path}"

@register_tool("create_file")
def create_file(path: str, content: str, env: DockerEnv) -> str:
    """
    Create a file with the given path and content. Use this function when there is a need to create a new file with initial content.
    Args:
        path: The path to the file to create.
        content: The initial content to write to the file.
    Returns:
        A string representation of the result of the file creation.
    """
    try:
        msg = write_file_in_chunks(content, path, env)
        return msg
    except Exception as e:
        return f"Error creating file: {str(e)}"

@register_tool("write_file")
def write_file(path: str, content: str, env: DockerEnv) -> str:
    """
    Write content to a file. Use this function when there is a need to write content to an existing file.
    Args:
        path: The path to the file to write to.
        content: The content to write to the file.
    Returns:
        A string representation of the result of the file writing.
    """
    try:
        msg = write_file_in_chunks(content, path, env)
        return msg
    except Exception as e:
        return f"Error writing to file: {str(e)}"

@register_tool("list_files")
@process_terminal_response
def list_files(path: str, env: DockerEnv) -> str:
    """
    List all files and directories under the given path if it is a directory. Use this function when there is a need to list the contents of a directory.
    
    **IMPORTANT**: On Windows, this tool automatically uses PowerShell commands. On Linux/Mac, it uses Unix commands.
    
    Args:
        path: The file system path to check and list contents from.
    Returns:
        A string representation of the contents of the directory.
    """
    if os.path.isfile(path):
        return "The given path is a file. Please provide a path of a directory."
    
    # Detect if running on Windows (use PowerShell) or Unix (use ls)
    # Check if env is LocalEnv and if it's running on Windows
    is_windows = os.name == "nt"
    
    # For LocalEnv, check if it's configured for PowerShell
    if hasattr(env, '_shell') and env._shell is not None:
        shell_lower = str(env._shell).lower()
        is_windows = "powershell" in shell_lower or os.name == "nt"
    elif hasattr(env, 'docker_workplace'):
        # DockerEnv - assume Unix-like environment
        is_windows = False
    else:
        # LocalEnv without explicit shell - detect from OS
        is_windows = os.name == "nt"
    
    if is_windows:
        # Use PowerShell command for Windows
        # Get-ChildItem with -Name flag for simple listing
        command = f"Get-ChildItem -Path \"{path}\" -Name"
    else:
        # Use Unix ls command
        command = f"ls -1 {path}"
    
    response = env.run_command(command)
    if response["status"] != 0:
        return f"Error listing files: {response['result']}"
    return response

@register_tool("get_directory_tree")
@process_terminal_response
def get_directory_tree(path: str, env: DockerEnv) -> str:
    """
    Get a complete directory tree structure showing all files and subdirectories.
    On Windows, uses PowerShell Get-ChildItem. On Linux/Mac, uses tree or find command.
    
    Args:
        path: The directory path to generate tree structure for.
    Returns:
        A string representation of the directory tree structure.
    """
    # Detect if running on Windows
    is_windows = False
    try:
        from research_agent.inno.environment.local_env import LocalEnv
        if isinstance(env, LocalEnv):
            is_windows = os.name == "nt"
    except:
        pass
    
    if is_windows:
        # Use PowerShell Get-ChildItem with -Recurse for Windows
        command = f'Get-ChildItem -Path "{path}" -Recurse | Select-Object FullName'
    else:
        # Use tree command if available, otherwise use find
        command = f"tree {path} 2>/dev/null || find {path} -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
    
    response = env.run_command(command)
    if response["status"] != 0:
        return f"Error getting directory tree: {response['result']}"
    return response


@register_tool("create_directory")
def create_directory(path: str, env: DockerEnv) -> str:
    """
    Create a directory if it does not exist. Use this function when there is a need to create a new directory.
    Args:
        path: The path of the directory to create.
    Returns:
        A string representation of the result of the directory creation.
    """
    try:
        command = f"mkdir -p {path}"
        response = env.run_command(command)
        if response["status"] != 0:
            return f"Error creating directory: {response['result']}"
        return f"Directory '{path}' created successfully."
    except OSError as error:
        return f"Creation of the directory '{path}' failed due to: {error}"

@register_tool("gen_code_tree_structure")
@process_terminal_response
def gen_code_tree_structure(directory: str, env: DockerEnv) -> str:
    """Generate a tree structure of the code in the specified directory. Use this function when you need to know the overview of the codebase and want to generate a tree structure of the codebase.
    Args:
        directory: The directory to generate the tree structure for.
    Returns:
        A string representation of the tree structure of the code in the specified directory.
    """
    try:
        command = f"tree {directory}"
        response = env.run_command(command)
        return response
    except Exception as e:
        return f"Error running tree {directory}: {str(e)}"
    
def print_stream(text):
    console = Console()
    console.print(f"[grey42]{text}[/grey42]")
    
@register_tool("execute_command")
@process_terminal_response
def execute_command(command: str, env: DockerEnv) -> str:
    """
    Execute a command in the system shell. Use this function when there is a need to run a system command, and execute programs.
    Args:
        command: The command to execute in the system shell.
    Returns:
        A string representation of the exit code and output of the command.
    """
    try:
        response = env.run_command(command, print_stream)
        print("exe success",response)
        return response
    except Exception as e:
        return f"Error running command: {str(e)}"

def print_stream(text):
    console = Console()
    console.print(f"[grey42]{text}[/grey42]")
def set_doc(doc_template):
    def decorator(func):
        func.__doc__ = doc_template
        return func
    return decorator

@register_tool("run_python")
@process_terminal_response
def run_python(
    env: DockerEnv,
    code_path: str,
    cwd: str = None,
    env_vars: Optional[Dict[str, str]] = None,
) -> str:
    """
    Run a python script. 
    Args:
        code_path: The absolute or relative path (the relative path is from the root of the workplace `/workplace`) to the python script file.
        cwd: The working directory of the python script. If not provided, will regard the directory of the script as the working directory. If there is a command `cd ...` in the instruction for running the script, you should provide the cwd and not use the default value. (Optional)
        env_vars: The environment variables to be set before running the python script. (Optional)
    Returns:
        A string representation of the exit code and output of the python script.
    """
    try:
        # 转换为绝对路径
        # abs_path = str(Path(code_path).resolve())
        if Path(code_path).is_absolute():
            if env.run_command(f"ls {code_path}")['status'] != 0: return f"File {code_path} does not exist"
            code_abs_path = code_path
        else: 
            code_abs_path = f"{env.docker_workplace}/{code_path}"
            if env.run_command(f"ls {code_abs_path}")['status'] != 0: return f'You use a relative path, so we regard the `{env.docker_workplace}` as the root of the workplace, but `{code_abs_path}` does not exist'
        
        
        if cwd:
            # 使用指定的项目根目录
            if Path(cwd).is_absolute():
                if env.run_command(f"ls {cwd}")['status'] != 0: return f"Working directory {cwd} does not exist"
            else: 
                cwd = f"{env.docker_workplace}/{cwd}"
                if env.run_command(f"ls {cwd}")['status'] != 0: return f"You use a relative path for `cwd`, so we regard the `{env.docker_workplace}` as the working directory, but `{cwd}` does not exist"
        else:
            cwd = str(Path(code_abs_path).parent)
            
        
        # 设置PYTHONPATH
        pythonpath = str(cwd)
        
        # 获取Python解释器路径
        env_str = f"PYTHONPATH={pythonpath}"
        
        if env_vars:
            env_str += " " + " ".join([f"{k}={v}" for k, v in env_vars.items()])
        # print(env_str)
        
        # 构建相对模块路径
        try:
            rel_path = Path(code_abs_path).relative_to(cwd)
            module_path = str(rel_path.with_suffix('')).replace(os.sep, '.')
            
            command = f"cd {cwd} && {env_str} python -m {module_path}"
        except ValueError:
            # 如果无法构建相对路径，使用完整路径
            command = f"cd {cwd} && {env_str} python {code_path}"
            
        # print(f"Executing: {command}")
        
        result = env.run_command(command, print_stream)
        return result
        
    except Exception as e:
        return f"Error when running the python script: {e}"


if __name__ == "__main__":
    # 使用 LocalEnv 而不是 DockerEnv 进行测试
    from research_agent.inno.environment.local_env import LocalEnv, LocalEnvConfig
    
    # 配置 LocalEnv（使用一个工作空间，但实际文件路径是绝对路径）
    env_config = LocalEnvConfig(
        workplace_name="test_workplace",
        local_root=os.path.join(os.getcwd(), "test_output"),
        create_workplace=True
    )
    env = LocalEnv(env_config)
    env.init_container()
    
    # 使用真实文件路径进行测试
    test_files = [
        r"C:\workspace\1\replication_package\scripts\hbg_analysis_modified.R",
        r"C:\workspace\2\replication_package\Ono Zilis Study 1_AJPS_modified.log",
        r"C:\workspace\41\replication_package\2_jtg_prepare_data_all_modified.log",
        r"C:\workspace\41\replication_package\3_jtg_results_main_modified.do",
        r"C:\workspace\41\replication_package\3_jtg_results_main_modified.log"
    ]
    
    # 检查文件是否存在
    import sys
    print("检查文件是否存在...")
    existing_files = []
    for i, file_path in enumerate(test_files, 1):
        if os.path.exists(file_path):
            file_size = os.path.getsize(file_path)
            print(f"文件 {i} 存在: {file_path} (大小: {file_size} 字节)")
            existing_files.append((i, file_path, file_size))
        else:
            print(f"警告: 文件 {i} 不存在: {file_path}")
    
    if len(existing_files) == 0:
        print("错误: 没有找到任何测试文件！")
        sys.exit(1)
    
    print(f"\n找到 {len(existing_files)} 个文件用于测试\n")
    
    print("=" * 60)
    print("开始测试 read_file 和翻页功能 (使用 LocalEnv)")
    print("=" * 60)
    
    # 对每个文件进行测试
    for file_idx, (file_num, file_path, file_size) in enumerate(existing_files, 1):
        print("\n" + "=" * 60)
        print(f"测试 {file_idx}: 读取文件 {file_num} ({os.path.basename(file_path)})")
        print("=" * 60)
        print(f"\n读取文件: {file_path}")
        
        # 读取文件
        result = read_file(file_path, env)
        print("\n读取结果 (前300字符):")
        print(result[:300] + "..." if len(result) > 300 else result)
        
        # 获取文件标识符（用于验证）
        file_identifier = os.path.basename(file_path)
        file_identifier_base = file_identifier.split(".")[0] if "." in file_identifier else file_identifier
        
        # 测试翻页功能
        print("\n" + "-" * 60)
        print(f"对文件 {file_num} 进行翻页测试")
        print("-" * 60)
        
        # 向下翻页
        print(f"\n{file_idx}.1 测试 terminal_page_down (向下翻页):")
        result_down = terminal_page_down()
        print(f"结果长度: {len(result_down)} 字符")
        print("结果前1000字符:")
        print(result_down[:1000] + "..." if len(result_down) > 1000 else result_down)
        # 验证是否正确
        if file_identifier in result_down or file_identifier_base in result_down:
            print(f"✓ 验证通过: 结果显示的是文件 {file_num} ({file_identifier}) 的内容")
        else:
            print(f"? 无法确定文件内容（可能文件内容不包含文件名）")
        
        # 再次向下翻页
        print(f"\n{file_idx}.2 再次 terminal_page_down:")
        result_down2 = terminal_page_down()
        print(f"结果长度: {len(result_down2)} 字符")
        print("结果前1000字符:")
        print(result_down2[:1000] + "..." if len(result_down2) > 1000 else result_down2)
        if file_identifier in result_down2 or file_identifier_base in result_down2:
            print(f"✓ 验证通过: 结果显示的是文件 {file_num} ({file_identifier}) 的内容")
        
        # 向上翻页
        print(f"\n{file_idx}.3 测试 terminal_page_up (向上翻页):")
        result_up = terminal_page_up()
        print(f"结果长度: {len(result_up)} 字符")
        print("结果前1000字符:")
        print(result_up[:1000] + "..." if len(result_up) > 1000 else result_up)
        if file_identifier in result_up or file_identifier_base in result_up:
            print(f"✓ 验证通过: 结果显示的是文件 {file_num} ({file_identifier}) 的内容")
        
        # 再次向上翻页
        print(f"\n{file_idx}.4 再次 terminal_page_up:")
        result_up2 = terminal_page_up()
        print(f"结果长度: {len(result_up2)} 字符")
        print("结果前1000字符:")
        print(result_up2[:1000] + "..." if len(result_up2) > 1000 else result_up2)
        if file_identifier in result_up2 or file_identifier_base in result_up2:
            print(f"✓ 验证通过: 结果显示的是文件 {file_num} ({file_identifier}) 的内容")
        
        # 跳转到第一页
        print(f"\n{file_idx}.5 测试 terminal_page_to(1) (跳转到第一页):")
        result_to1 = terminal_page_to(1)
        print(f"结果长度: {len(result_to1)} 字符")
        print("结果前1000字符:")
        print(result_to1[:1000] + "..." if len(result_to1) > 1000 else result_to1)
        if file_identifier in result_to1 or file_identifier_base in result_to1:
            print(f"✓ 验证通过: 结果显示的是文件 {file_num} ({file_identifier}) 的内容")
        
        # 验证：检查是否误显示了其他文件的内容
        print(f"\n{file_idx}.6 验证: 检查是否误显示了其他文件的内容:")
        all_results = [result_down, result_down2, result_up, result_up2, result_to1]
        found_other_file = False
        for other_num, other_path, _ in existing_files:
            if other_num == file_num:
                continue
            other_identifier = os.path.basename(other_path)
            other_identifier_base = other_identifier.split(".")[0] if "." in other_identifier else other_identifier
            for i, res in enumerate(all_results, 1):
                if other_identifier in res or other_identifier_base in res:
                    print(f"✗ 错误: 步骤 {file_idx}.{i} 的结果中包含了文件 {other_num} ({other_identifier}) 的内容！应该显示文件 {file_num}")
                    found_other_file = True
        if not found_other_file:
            print(f"✓ 验证通过: 所有翻页操作都正确显示文件 {file_num} ({file_identifier})，没有误显示其他文件")
    
    print("\n" + "=" * 60)
    print("所有测试完成!")
    print("=" * 60)
    
