This is an experimental directory containing translations of a few 
pmtk3 demos from Matlab to python. Over time, we hope to port
more and more functionality.

--------

Below I include some notes based on Kevin Murphy's experience
getting python 2.6 to work on a Mac OS X
(written from the perspective of a matlab user and someone interested
in data analysis/ scientific computing)

- diveintopython.org is a free 300 page book (pdf format) which is not too basic
  but not too advanced. Sometimes reading a pdf is easier than reading
  many small html pages.

- The site below contains ipython, numpy, scipy and matplotlib all bundled
together for Mac OS X 10.6
  http://stronginference.com/scipy-superpack

- The site below sells ($200 per year per user) a bundle of 75 of the
  latest packages, focussing on scientific comptuation
http://www.enthought.com/

- to install packages do this:
1. Download setuptools from http://pypi.python.org/pypi/setuptools#downloads
2. sudo sh setuptools-0.6c11-py2.6.egg
3. Stores it in/ Library/Python/2.6/site-packages
4. Run something like this:  sudo easy_install-2.6 networkx

- the networkx package (http://networkx.lanl.gov) supports graph
  operations.

- to automatically execute a startup file,
put this in your .bashrc
  export PYTHONSTARTUP=/Users/kpmurphy/pystart.py
