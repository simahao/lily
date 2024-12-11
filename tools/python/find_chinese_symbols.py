# author: zhanghao
# date: 2024/12/9
# version: 1.0
# find chinese symbols like brackets and commas in pl/sql(bdy|spc)

"""
If you use this script under cmd
e.g.
python find_chinese_symbols.py D:\database\logical
python find_chinese_symbols.py ./logical

If you use this script under git bash
e.g.
python find_chinese_symbols.py 'D:\database\logical'
python find_chinese_symbols.py "D:\database\logical"
python find_chinese_symbols.py D:\\database\\logical
python find_chinese_symbols.py ./logical

Importants:
1. You can not run script under git bash like this
python find_chinese_symbols.py D:\database\logical
2. If path include space, you should use single quotes or double quotes to wrap the path
3. If you use git bash,garbled texts maybe shown in git bash terminal for chinese symbols,
you can set git bash option'text as default or gb2312
"""
import argparse
import os
import re

total_num = 0
file_num = 0
old_filename = ''
def extract_chinese_symbols_from_code(file_content, file_name):
    # Regular expression: Match single-line comments and block comments, using non-greedy mode
    comment_pattern = r'--.*|/\*[\s\S]*?\*/'

    # Remove all comments while preserving line numbers
    code_without_comments, lines_with_comments = remove_comments_and_preserve_lines(file_content, comment_pattern)

    # Match Chinese parentheses, Chinese commas, and Chinese semicolons
    chinese_symbol_pattern = r'[（），；]'

    # Find the positions of Chinese symbols, ignoring symbols inside strings
    matches = list(re.finditer(chinese_symbol_pattern, code_without_comments))

    global total_num, file_num, old_filename
    # If Chinese symbols are found, return related information
    if matches:
        for match in matches:
            start, end = match.span()
            # Extract the line number where the Chinese symbol is located
            line_number = file_content.count('\n', 0, start) + 1
            code_line = lines_with_comments[line_number - 1]  # Use the original code line
            # Check if the symbol is inside a string
            if not is_in_string(code_line):
                # Output format: filename, line, code, issue char
                print(f"filename: {file_name}")
                print(f"line: {line_number}")
                print(f"code: {code_line.strip()}")
                print(f"issue char: {match.group(0)}")
                print("-" * 50)
                total_num += 1
                if old_filename != file_name:
                    file_num += 1
                    old_filename = file_name

def is_in_string(line):
    """
    Determine whether a character is inside a string (single or double quotes).
    Returns True if the character is inside a string.
    """
    in_quote_pattern = r"(['\"])(.*?[（），；].*?)\1"
    # If the result is not None, it means the special character is inside a string
    return re.search(in_quote_pattern, line) is not None

def remove_comments_and_preserve_lines(file_content, comment_pattern):
    """
    Remove comments while preserving the number of lines. The removed comments will be replaced with spaces, and newlines will be preserved.
    Returns: the code content without comments and the original lines with comments.
    """
    lines = file_content.splitlines()
    modified_lines = []
    lines_with_comments = []

    # Handle block comments, replacing them with spaces
    def replace_block_comment(match):
        # The content of the block comment, replace each line with spaces
        comment_text = match.group(0)
        # Replace each line in the block comment with spaces, preserving the newlines
        lines_in_comment = comment_text.splitlines()
        replaced_comment = "\n".join([' ' * len(line) for line in lines_in_comment])
        return replaced_comment

    # Process the file content to replace comments
    modified_content = re.sub(comment_pattern, replace_block_comment, file_content)

    # Split the processed content into lines
    modified_lines = modified_content.splitlines()

    # Preserve the original lines, maintaining the number of lines
    lines_with_comments = lines

    return '\n'.join(modified_lines), lines_with_comments

def open_with_multiple_encodings(file_path):
    encodings = ['gb2312', 'utf-8', 'gbk', 'gb18030']  # Encoding order
    for encoding in encodings:
        try:
            # Try to open the file with the specified encoding
            with open(file_path, 'r', encoding=encoding) as file:
                file_content = file.read()
                if file_content:
                    if encoding != 'gb2312':
                        print(f"open file: {file_path} with encoding: {encoding}")
                    return file_content
                else:
                    continue
        except UnicodeDecodeError:
            # If the current encoding fails, catch the exception and try the next encoding
            continue
        except Exception as e:
            raise e

def analyze_files_in_directory(directory):
    # Traverse all files in the specified directory
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.spc') or file.endswith('.bdy'):
                file_path = os.path.join(root, file)
                file_content = open_with_multiple_encodings(file_path)
                if file_content:
                    extract_chinese_symbols_from_code(file_content, file)
                else:
                    print(f"{file_path} cannot be opened with any encoding")
    print(f"\nThere are {total_num} chinese symbols in {file_num} files")

if __name__ == "__main__":
    # create parser of arguments
    parser = argparse.ArgumentParser(description='Analyze files in the given directory.')
    # add directory argument
    parser.add_argument('directory', type=str, help='Directory to scan')
    # parse arguments
    args = parser.parse_args()
    # scan
    analyze_files_in_directory(args.directory)
