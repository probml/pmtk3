#!/usr/bin/env python

import os
import scipy.io as sio

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
