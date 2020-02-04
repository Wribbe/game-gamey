#!/usr/bin/env python

import os
import subprocess
import shlex
import shutil
import sys

from pathlib import Path

DEPS = [
  [
    'glfw',
    'git clone https://github.com/glfw/glfw glfw',
    'cd glfw',
    'git checkout latest',
    'cmake .',
    'make',
    'cd ..',
  ],[
    'portaudio',
    'git clone https://git.assembla.com/portaudio.git portaudio',
    'cd portaudio',
    'git checkout pa_stable_v190600_20161030',
    'cmake .',
    'make',
    'pkg-config --with-path="./src/" --cflags --libs --static portaudio',
    'cd ..',
  ],[
    'cglm',
    'git clone https://github.com/recp/cglm cglm',
    'cd cglm',
    'git checkout v0.6.2',
    'sh autogen.sh',
    'sh configure',
    'make',
    'pkg-config --with-path="." --cflags --libs --static cglm',
    'cd ..',
  ],[
    'stb',
    'git clone https://github.com/nothings/stb stb',
    'mkdir includes',
    'cd stb',
    'ln -sr stb_image.h ../includes/stb_image.h',
    'ln -sr stb_truetype.h ../includes/stb_truetype.h',
    'cd ..',
  ]
]

def call(cmd):
  print(f"calling: {cmd}")
  return subprocess.call(shlex.split(cmd))

def main():
  for cmd_list in DEPS:
    dest, *cmd_list = cmd_list
    dest = Path(dest)
    if not dest.is_dir():
      for cmd in cmd_list:
        if cmd.startswith('cd '):
          os.chdir(cmd.split(' ', 1)[-1])
        else:
          call(cmd)

if __name__ == "__main__":
  args = sys.argv[1:]
  if 'clean' in args:
    for dep in DEPS:
      dest = Path(dep[0])
      if dest.is_dir():
        shutil.rmtree(dest)
  else:
    main()
