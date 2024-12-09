# author: zhanghao
# date: 2024/12/9
# version: 1.0
# find chinese symbols like brackets and commas in pl/sql(bdy|spc)

import os
import re


def extract_chinese_symbols_from_code(file_content, file_name):
    # 正则表达式：匹配单行注释和块注释， 非贪婪匹配模式
    comment_pattern = r'--.*|/\*[\s\S]*?\*/'

    # 去掉所有注释，并保持相同行数
    code_without_comments, lines_with_comments = remove_comments_and_preserve_lines(file_content, comment_pattern)

    # 匹配中文括号，中文逗号，中文分号
    chinese_symbol_pattern = r'[（），；]'

    # 查找中文符号的位置，忽略字符串内的符号
    matches = list(re.finditer(chinese_symbol_pattern, code_without_comments))

    # 如果找到中文符号，返回相关信息
    if matches:
        for match in matches:
            start, end = match.span()
            # 提取出中文符号所在的行号
            line_number = file_content.count('\n', 0, start) + 1
            code_line = lines_with_comments[line_number - 1]  # 使用原始的代码行
            # 检查符号是否位于字符串内部
            if not is_in_string(code_line):
                # 输出格式：filename, line, code, issue char
                print(f"filename: {file_name}")
                print(f"line: {line_number}")
                print(f"code: {code_line.strip()}")
                print(f"issue char: {match.group(0)}")
                print("-" * 50)

def is_in_string(line):
    """
    判断一个字符是否位于字符串内部（单引号或双引号内）。
    返回 True 表示在字符串内
    """
    in_quote_pattern = r"(['\"])(.*?[（），；].*?)\1"
    # 不为None代表匹配成功，也就是特殊字符在字符串内部
    return re.search(in_quote_pattern, line) is not None

def remove_comments_and_preserve_lines(file_content, comment_pattern):
    """
    删除注释，同时保持行数一致。删除的注释部分会被空格替换，并保留换行符。
    返回：去掉注释后的代码内容和去除注释后的每一行
    """
    lines = file_content.splitlines()
    modified_lines = []
    lines_with_comments = []

    # 先处理块注释，用空格替换掉块注释内容
    def replace_block_comment(match):
        # 块注释的内容，逐行替换成空格
        comment_text = match.group(0)
        # 将每行替换为空格，保留换行符
        lines_in_comment = comment_text.splitlines()
        replaced_comment = "\n".join([' ' * len(line) for line in lines_in_comment])
        return replaced_comment

    # 处理文件内容中的注释
    modified_content = re.sub(comment_pattern, replace_block_comment, file_content)

    # 将处理后的内容按行分割
    modified_lines = modified_content.splitlines()

    # 保存原始的行内容，保持行数一致
    lines_with_comments = lines

    return '\n'.join(modified_lines), lines_with_comments

def open_with_multiple_encodings(file_path):
    encodings = ['gb2312', 'utf-8', 'gbk', 'gb18030']  # 编码顺序
    for encoding in encodings:
        try:
            # 尝试使用指定编码打开文件
            with open(file_path, 'r', encoding=encoding) as file:
                file_content = file.read()
                if file_content:
                    if encoding != 'gb2312':
                        print(f"open file: {file_path} with encoding: {encoding}")
                    return file_content
                else:
                    continue
        except UnicodeDecodeError:
            # 如果当前编码失败，捕获异常并尝试下一个编码
            continue
        except Exception as e:
            raise e
def analyze_files_in_directory(directory):
    # 遍历指定目录的所有文件
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.spc') or file.endswith('.bdy'):
                file_path = os.path.join(root, file)
                file_content = open_with_multiple_encodings(file_path)
                if file_content:
                    extract_chinese_symbols_from_code(file_content, file)
                else:
                    print(f"{file_path} can not open with any encoding")

directory_to_scan = './'  # 替换为实际的目录路径
# directory_to_scan = 'D:\dev\sixth\database\logical'  # 替换为实际的目录路径
analyze_files_in_directory(directory_to_scan)
