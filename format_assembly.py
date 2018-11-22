# pretty printer source: https://github.com/nanochess/pretty6502

import os
import sys

root_dir = "./" + sys.argv[1] + "/"
print("Formatting all the files in " + root_dir + "...")

for directory, subdirectories, files in os.walk(root_dir):
   for file in files:
	file_name = os.path.join(directory, file)
        if('.asm' in file_name):
             os.system(r"./pretty6502 -l " + file_name + " " + file_name)
