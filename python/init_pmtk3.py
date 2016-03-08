#!/usr/bin/env python3

import os

print "welcome to pmtk3 python code"
PMTK_PYTHON_DIR = os.path.dirname(os.path.realpath(__file__))
PMTK_DIR = os.path.dirname(PMTK_PYTHON_DIR)
DATA_DIR = os.path.join(PMTK_DIR, 'data')
#DATA_DIR = '/Users/kpmurphy/github/pmtk3/data'
print "Data lives in {}".format(DATA_DIR)