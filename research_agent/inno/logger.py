from datetime import datetime
from rich.console import Console
from rich.markup import escape
import json
import re
import sys
from typing import List
from research_agent.constant import DEBUG, DEFAULT_LOG, LOG_PATH
from pathlib import Path

def _format_image_content(content: str) -> str:
    """
    Check if content is an image (base64 encoded) and return a shortened version for display.
    
    Args:
        content: The content string to check
        
    Returns:
        If it's an image, returns a shortened message. Otherwise, returns the original content.
    """
    if not isinstance(content, str):
        return content
    
    # Check if it's a data URI image
    if content.startswith("data:image/"):
        # Extract image type from data URI
        match = re.match(r"data:image/([^;]+)", content)
        image_type = match.group(1) if match else "image"
        # Estimate size
        size_chars = len(content)
        size_kb = size_chars / 1024
        if size_kb > 1024:
            size_str = f"{size_kb/1024:.1f}MB"
        else:
            size_str = f"{size_kb:.1f}KB"
        return f"[Image data ({image_type}), {size_str}, base64 encoded - content added to context]"
    
    # Check if it's a long base64 string (likely an image)
    # Base64 strings are typically very long and contain only base64 characters
    if len(content) > 1000:
        # Remove whitespace for checking
        content_no_ws = re.sub(r'\s+', '', content)
        # Check if it looks like base64 (alphanumeric + / + = + - + _)
        if len(content_no_ws) > 1000 and re.match(r'^[A-Za-z0-9+/=\-_]+$', content_no_ws):
            # Estimate size
            size_chars = len(content_no_ws)
            size_kb = size_chars / 1024
            if size_kb > 1024:
                size_str = f"{size_kb/1024:.1f}MB"
            else:
                size_str = f"{size_kb:.1f}KB"
            return f"[Image data (base64 encoded, {size_str}) - content added to context]"
    
    return content

def _remove_emoji(text: str) -> str:
    """
    Remove emoji characters from text to avoid encoding issues on Windows.
    """
    if not isinstance(text, str):
        return text
    # Remove common emoji characters (✅, ⚠️, etc.)
    emoji_pattern = re.compile(
        "["
        "\U0001F600-\U0001F64F"  # emoticons
        "\U0001F300-\U0001F5FF"  # symbols & pictographs
        "\U0001F680-\U0001F6FF"  # transport & map symbols
        "\U0001F1E0-\U0001F1FF"  # flags (iOS)
        "\U00002702-\U000027B0"  # dingbats
        "\U000024C2-\U0001F251"  # enclosed characters
        "\U00002700-\U000027BF"  # dingbats
        "\U0001F900-\U0001F9FF"  # supplemental symbols
        "\U00002600-\U000026FF"  # miscellaneous symbols
        "\U00002700-\U000027BF"  # dingbats
        "]+",
        flags=re.UNICODE
    )
    return emoji_pattern.sub('', text)

BAR_LENGTH = 60
class MetaChainLogger:
    def __init__(self, log_path: str):
        self.log_path = log_path
        # Configure console to avoid emoji encoding issues on Windows
        # Use legacy_windows=False to avoid GBK encoding issues
        try:
            self.console = Console(legacy_windows=False, encoding='utf-8')
        except Exception:
            # Fallback to default console if encoding setup fails
            self.console = Console()
        self.debug = DEBUG
        
    def _write_log(self, message: str):
        with open(self.log_path, 'a') as f:
            f.write(message + '\n')
    def _warp_args(self, args_dict: str):
        args_dict = json.loads(args_dict)
        args_str = ''
        for k, v in args_dict.items():
            args_str += f"{repr(k)}={repr(v)}, "
        return args_str[:-2]
    def _wrap_title(self, title: str, color: str = None):
        single_len = (BAR_LENGTH - len(title)) // 2
        color_bos = f"[{color}]" if color else ""
        color_eos = f"[/{color}]" if color else ""
        return f"{color_bos}{'*'*single_len} {title} {'*'*single_len}{color_eos}"
    def info(self, *args: str, **kwargs: dict):
        # console = Console()
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        message = "\n".join(map(str, args))
        color = kwargs.get("color", "white")
        title = kwargs.get("title", "INFO")
        log_str = f"[{timestamp}]\n{message}"
        if self.debug: 
            # print_in_box(log_str, color=color, title=title)
            # Wrap the whole rich printing block to catch any encoding issues
            try:
                self.console.print(self._wrap_title(title, f"bold {color}"))
                # Remove emoji to avoid encoding issues on Windows
                safe_log_str = _remove_emoji(log_str)
                self.console.print(escape(safe_log_str), highlight=True, emoji=False)
            except UnicodeEncodeError:
                # Fallback: replace problematic characters for the entire block
                safe_title = self._wrap_title(title)
                safe_log_str = f"[{timestamp}]\n{message}"
                safe_title = safe_title.encode("ascii", "replace").decode("ascii")
                safe_log_str = safe_log_str.encode("ascii", "replace").decode("ascii")
                # Use a very plain print to avoid rich/encoding issues
                try:
                    print(safe_title)
                    print(safe_log_str)
                except Exception:
                    # As a last resort, ignore logging to console
                    pass
        log_str = self._wrap_title(title) + "\n" + log_str
        if self.log_path: self._write_log(log_str) 
    def lprint(self, *args: str, **kwargs: dict):
        if not self.debug: return
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        message = "\n".join(map(str, args))
        color = kwargs.get("color", "white")
        title = kwargs.get("title", "")
        log_str = f"[{timestamp}]\n{message}"
        # print_in_box(log_str, color=color, title=title)
        try:
            self.console.print(self._wrap_title(title, f"bold {color}"))
            # Remove emoji to avoid encoding issues on Windows
            safe_log_str = _remove_emoji(log_str)
            self.console.print(escape(safe_log_str), highlight=True, emoji=False)
        except UnicodeEncodeError:
            # Fallback: replace problematic characters for the entire block
            safe_title = self._wrap_title(title)
            safe_log_str = f"[{timestamp}]\n{message}"
            safe_title = safe_title.encode("ascii", "replace").decode("ascii")
            safe_log_str = safe_log_str.encode("ascii", "replace").decode("ascii")
            try:
                print(safe_title)
                print(safe_log_str)
            except Exception:
                pass
        
    def _wrap_timestamp(self, timestamp: str, color: bool = True):
        color_bos = "[grey58]" if color else ""
        color_eos = "[/grey58]" if color else ""
        return f"{color_bos}[{timestamp}]{color_eos}"
    def _print_tool_execution(self, message, timestamp: str):
        self.console.print(self._wrap_title("Tool Execution", "bold pink3"))
        self.console.print(self._wrap_timestamp(timestamp, color=True))
        self.console.print("[bold blue]Tool Execution:[/bold blue]", end=" ")
        self.console.print(f"[bold purple]{message['name']}[/bold purple]\n[bold blue]Result:[/bold blue]")
        formatted_content = _format_image_content(message['content'])
        # Remove emoji to avoid encoding issues on Windows
        safe_content = _remove_emoji(str(formatted_content))
        try:
            self.console.print(f"---\n{escape(safe_content)}\n---")
        except UnicodeEncodeError:
            # Fallback: replace problematic characters
            safe_content = safe_content.encode('ascii', 'replace').decode('ascii')
            self.console.print(f"---\n{escape(safe_content)}\n---")
    def _save_tool_execution(self, message, timestamp: str):
        self._write_log(self._wrap_title("Tool Execution"))
        formatted_content = _format_image_content(message['content'])
        self._write_log(f"{self._wrap_timestamp(timestamp, color=False)}\ntool execution: {message['name']}\nResult:\n---\n{formatted_content}\n---")
    def _print_assistant_message(self, message, timestamp: str):
        try:
            # Title line
            self.console.print(self._wrap_title("Assistant Message", "bold light_salmon3"))
            # Header with timestamp and sender
            self.console.print(
                f"{self._wrap_timestamp(timestamp, color=True)}\n[bold blue]{message['sender']}[/bold blue]:",
                end=" ",
            )
            if message["content"]:
                # Remove emoji to avoid encoding issues on Windows
                safe_content = _remove_emoji(str(message["content"]))
                self.console.print(escape(safe_content), highlight=True, emoji=False)
            else:
                self.console.print(None, highlight=True, emoji=False)
        except UnicodeEncodeError:
            # Fallback: replace problematic characters and print plainly
            try:
                title = self._wrap_title("Assistant Message")
                header = f"{self._wrap_timestamp(timestamp, color=False)}\n{message['sender']}: "
                content = str(message.get("content", ""))
                title = title.encode("ascii", "replace").decode("ascii")
                header = header.encode("ascii", "replace").decode("ascii")
                content = content.encode("ascii", "replace").decode("ascii")
                print(title)
                print(header + content)
            except Exception:
                # As a last resort, suppress console output
                pass
    def _save_assistant_message(self, message, timestamp: str):
        self._write_log(self._wrap_title("Assistant Message"))
        content = message["content"] if message["content"] else None
        self._write_log(f"{self._wrap_timestamp(timestamp, color=False)}\n{message['sender']}: {content}")
    def _print_tool_call(self, tool_calls: List, timestamp: str):
        try:
            if len(tool_calls) >= 1:
                self.console.print(self._wrap_title("Tool Calls", "bold light_pink1"))

            for tool_call in tool_calls:
                f = tool_call["function"]
                name, args = f["name"], f["arguments"]
                arg_str = self._warp_args(args)
                self.console.print(
                    f"{self._wrap_timestamp(timestamp, color=True)}\n[bold purple]{name}[/bold purple]({escape(arg_str)})"
                )
        except UnicodeEncodeError:
            # Fallback: replace problematic characters and print plainly
            try:
                title = self._wrap_title("Tool Calls")
                title = title.encode("ascii", "replace").decode("ascii")
                print(title)
                for tool_call in tool_calls:
                    f = tool_call["function"]
                    name, args = f["name"], f["arguments"]
                    arg_str = self._warp_args(args)
                    line = f"[{timestamp}] {name}({arg_str})"
                    line = line.encode("ascii", "replace").decode("ascii")
                    print(line)
            except Exception:
                # As a last resort, suppress console output
                pass
    def _save_tool_call(self, tool_calls: List, timestamp: str):
        if len(tool_calls) >= 1: self._write_log(self._wrap_title("Tool Calls"))

        for tool_call in tool_calls:
            f = tool_call["function"]
            name, args = f["name"], f["arguments"]
            arg_str = self._warp_args(args)
            self._write_log(f"{self._wrap_timestamp(timestamp, color=False)}\n{name}({arg_str})")

    def pretty_print_messages(self, message, **kwargs) -> None:
        # for message in messages:
        if message["role"] != "assistant" and message["role"] != "tool":
            return
        # console = Console()
        
        # handle tool call
        if message["role"] == "tool":
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            if self.log_path: self._save_tool_execution(message, timestamp)
            if self.debug: self._print_tool_execution(message, timestamp)
            return
        
        # handle assistant message
        # print agent name in blue
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if self.log_path: self._save_assistant_message(message, timestamp)
        if self.debug: self._print_assistant_message(message, timestamp)

        # print tool calls in purple, if any
        tool_calls = message.get("tool_calls") or []
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        if self.log_path: self._save_tool_call(tool_calls, timestamp)
        if self.debug: self._print_tool_call(tool_calls, timestamp)
class LoggerManager:
    _instance = None
    _logger: MetaChainLogger = None

    @classmethod
    def get_instance(cls):
        if cls._instance is None:
            cls._instance = LoggerManager()
        return cls._instance

    @classmethod
    def get_logger(cls):
        return cls.get_instance()._logger

    @classmethod
    def set_logger(cls, new_logger):
        cls.get_instance()._logger = new_logger
if DEFAULT_LOG:
    if LOG_PATH is None:
        log_dir = Path(f'logs/res_{datetime.now().strftime("%Y%m%d_%H%M%S")}')
        log_dir.mkdir(parents=True, exist_ok=True)  # recursively create all necessary parent directories
        log_path = str(log_dir / "agent.log")
        # logger = MetaChainLogger(log_path=log_path)
        LoggerManager.set_logger(MetaChainLogger(log_path=log_path))
    else:
        # logger = MetaChainLogger(log_path=LOG_PATH)
        LoggerManager.set_logger(MetaChainLogger(log_path=LOG_PATH))
    # logger.info("Log file is saved to", logger.log_path, "...", title="Log Path", color="light_cyan3")
    LoggerManager.get_logger().info("Log file is saved to", 
                                  LoggerManager.get_logger().log_path, "...", 
                                  title="Log Path", color="light_cyan3")
else:
    # logger = None
    LoggerManager.set_logger(None)
logger = LoggerManager.get_logger()

def set_logger(new_logger):
    LoggerManager.set_logger(new_logger)
# if __name__ == "__main__":
#     logger = MetaChainLogger(log_path="test.log")
#     logger.pretty_print_messages({"role": "assistant", "content": "Hello, world!", "tool_calls": [{"function": {"name": "test", "arguments": {"url": "https://www.google.com", "query": "test"}}}], "sender": "test_agent"})

#     logger.pretty_print_messages({"role": "tool", "name": "test", "content": "import requests\n\nurl = 'https://www.google.com'\nquery = 'test'\n\nresponse = requests.get(url)\nprint(response.text)", "sender": "test_agent"})
#     logger.info("test content", color="red", title="test")
