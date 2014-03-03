#!/usr/bin/env python

import os
import scipy.io as sio
import glob

PYTHON_DIR = os.path.dirname(os.path.realpath(__file__))
DATA_DIR = os.path.join(os.path.dirname(PYTHON_DIR), 'pmtkdataCopy')


def load_mat(matName):
    """look for the .mat file in pmtk3/pmtkdataCopy/
    currently only support .mat files create by Matlab 5,6,7~7.2,
    """
    try:
        data = sio.loadmat(os.path.join(DATA_DIR, matName))
    except NotImplementedError:
        raise
    except FileNotFoundError:
        raise
    return data


def generate_rst():
    """generate chX.rst in current working directory"""
    scripts = glob.glob('*.py')
    chapter = os.path.basename(os.getcwd())
    rst_file = chapter + '.rst'
    with open(rst_file, 'w') as f:
        f.write(chapter)
        f.write('\n========================================\n')
        for script in scripts:
            f.write('\n' + script[:-3])
            f.write('\n----------------------------------------\n')
            for img in glob.glob(script[:-3] + '*.png'):
                f.write(".. image:: " + img + "\n")
            f.write(".. literalinclude:: " + script + "\n")
