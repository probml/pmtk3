#!/usr/bin/env python3

import os
import sys

# We assume the directory structure is as follows:
# .../github/pmtk3/python -- location of this file
# .../github/pmtk3/data

print "welcome to pmtk3 python code"
PMTK_PYTHON_DIR = os.path.dirname(os.path.realpath(__file__))
PMTK_DIR = os.path.dirname(PMTK_PYTHON_DIR)
GITHUB_DIR = os.path.dirname(PMTK_DIR)
DATA_DIR = os.path.join(PMTK_DIR, 'data')

add_dirs = [PMTK_PYTHON_DIR]
for d in add_dirs:
    print("Adding {}".format(d))
    sys.path.append(d)
    print "Execute this command: export PYTHONPATH=$PYTHONPATH:{}".format(d)

