import sys
import os
from os import path
import shutil

import re
import xml.etree.ElementTree as ET
from ihroteka_converter import convert as convert_markdown

def main():
    in_dir = '.\\'
    out_dir = '.\\out'

    metadata_file = ".\\metadata.xml"
    readme_file = ".\\readme.md"

    if len(sys.argv) > 1 and sys.argv[1] == "test_convert":
        test_convert(readme_file)
        return

    update_metadata(metadata_file, readme_file)

    bad_dirs = [out_dir, ".\\.vscode", ".\\.git", ".\\resources\\gfx\\characters\\costumes_percy\\edit me"]
    bad_files = [".\\cat_guy_config_user.lua"]
    extensions = [".lua", ".xml", ".ogg", ".wav", ".anm2", ".png", ".fs", ".vs", ".md"]

    if path.isdir(out_dir):
        shutil.rmtree(out_dir)

    copy(in_dir, out_dir, bad_dirs, bad_files, extensions)

def update_metadata(metadata_file: str, readme_file: str):
    metadata = ET.parse(metadata_file)

    readme: str
    with open(readme_file) as f:
        readme = f.read()
    readme = convert(readme)

    description = metadata.find("description")
    if description == None:
        print("description not found")
        return
    
    description.text = readme
    metadata.write(metadata_file, encoding="utf-8", xml_declaration=True)
    pass

def test_convert(readme_file: str):
    readme: str
    with open(readme_file) as f:
        readme = f.read()
    readme = convert(readme)

    with open(readme_file + ".txt", "w") as f:
        f.write(readme)

def convert(readme: str):
    readme = re.sub(r"<!--.*-->\n*", "", readme)
    readme = re.sub(r"^## ", "# ", readme, flags=re.MULTILINE)
    readme = re.sub(r"^### ", "## ", readme, flags=re.MULTILINE)
    readme = re.sub(r"^#### ", "### ", readme, flags=re.MULTILINE)
    readme = re.sub(r"`([^`]*)`", "\"*\\1*\"", readme)
    readme = re.sub(r"\[(.+)\]\(#[a-z\-]+\)", "*\\1*", readme)
    readme = convert_markdown(readme)
    return readme

def copy(in_dir: str, out_dir: str, bad_dirs: list[str], bad_files: list[str], extensions: list[str]):
    for item in os.listdir(in_dir):
        item_path_in = path.join(in_dir, item)
        item_path_out = path.join(out_dir, item)
        if path.isfile(item_path_in):
            if item_path_in in bad_files:
                continue
            _, ext = path.splitext(item)
            if not ext in extensions:
                continue
            print(item_path_out)
            os.makedirs(out_dir, exist_ok=True)
            shutil.copy(item_path_in, item_path_out)
        else:
            if item_path_in in bad_dirs:
                continue
            copy(item_path_in, item_path_out, bad_dirs, bad_files, extensions)

if __name__ == "__main__":
    main()
            