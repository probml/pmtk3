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
    cwd = os.getcwd()
    demo_dir = os.path.join(cwd, 'demos')
    chapters = os.listdir(demo_dir)
    for chapter in chapters:
        if not os.path.isdir(os.path.join(demo_dir, chapter)):
            continue
        reg_py = os.path.join(demo_dir, chapter, '*.py')
        scripts = glob.glob(reg_py)
        rst_file = chapter + '.rst'
        rst_file = os.path.join(demo_dir, chapter, rst_file)
        with open(rst_file, 'w') as f:
            f.write(chapter)
            f.write('\n========================================\n')
            for script in scripts:
                script_name = os.path.basename(script)
                f.write('\n' + script_name[:-3])
                f.write('\n----------------------------------------\n')
                reg_png = os.path.join(demo_dir,
                                       chapter,
                                       script_name[:-3] + '*.png')
                for img in glob.glob(reg_png):
                    img_name = os.path.basename(img)
                    f.write(".. image:: " + img_name + "\n")
                f.write(".. literalinclude:: " + script_name + "\n")

if __name__ == '__main__':
    generate_rst()
    print("Finished generate chX.rst!")
