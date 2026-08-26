import os
from os import path
import shutil

def main():
    in_dir = '.\\'
    out_dir = '.\\out'

    bad_dirs = [out_dir, ".\\.vscode", ".\\.git", ".\\resources\\gfx\\characters\\costumes_percy\\edit me"]
    bad_files = [".\\cat_guy_config_user.lua"]
    extensions = [".lua", ".xml", ".ogg", ".wav", ".anm2", ".png", ".fs", ".vs", ".md"]

    if path.isdir(out_dir):
        shutil.rmtree(out_dir)
    build(in_dir, out_dir, bad_dirs, bad_files, extensions)

def build(in_dir: str, out_dir: str, bad_dirs: list[str], bad_files: list[str], extensions: list[str]):
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
            build(item_path_in, item_path_out, bad_dirs, bad_files, extensions)

if __name__ == "__main__":
    main()
            