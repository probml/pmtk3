Instructions
===============
This is an experimental directory containing translations of a few 
pmtk3 demos from Matlab to python. Over time, we hope to port
more and more functionality.

Guide
--------------
If you are new to using python for scientific computing, I strongly recommend 
you to spend some time on 

`scipy-lecture-notes <http://scipy-lectures.github.io>`_

This document will give you a quick introduction to central tools and 
techniques on the scientific Python ecosystem.

Requirements
--------------
To run demos, you should have installed either python2 or python3 as you like. 
You also need to install the following packages
    - numpy
    - scipy
    - matplotlib
    - sklearn
    - networkx

Here are some instructions on how to install:
    - How to install Python https://wiki.python.org/moin/BeginnersGuide/Download
    - How to install numpy, scipy, matplotlib http://www.scipy.org/install.html
    - How to install sklearn http://scikit-learn.org/stable/install.html
    - How to install networkx http://networkx.github.io/documentation/latest/install.html

For develpoers, you need install sphinx to generate docs. 
http://sphinx-doc.org/install.html
To generate docs, change your working directory into ``/path/to/pmtk3/python``,
run ``make html``, docs will be generated in ``/path/to/pmtk3/python/_build/html/``
   
You may also need to install some other packages. Just follow the instructions above.

How to run demos
------------------
All you need to do is setting the PYTHONPATH

  - On linux, just put this in your ~/.bashrc
    
      ``export PYTHONPATH=/path/to/pmtk3/python``
    
  - On windows, you need to open
      My Computer > Properties > Advanced System Settings > Environment Variables >
       
      .. image:: http://i.stack.imgur.com/ZGp36.png
    
      Then under system variables  create a new Variable called PYTHONPATH.
      Fill the variable value with ``/path/to/pmtk3/python``

Then change directory into each fold, run ``python script_name.py``
You can also double click the scripts on windows.

To view the scripts and figs in browser, see the html files in the fold ``/path/to/pmtk3/python/_build/html/``

In the future, maybe we can build a package to make things easier.
