pmtkdata
========

A collection of MATLAB data sets used by <a href="https://github.com/probml/pmtk3">PMTK</a>.
For a list of the data sets, see <a href="http://pmtkdata.googlecode.com/svn/trunk/docs/dataTable.html">here</a>.
Each folder contains a datafile in matlab format, a text 'meta file' describing the data,
and possibly other auxiliary files e.g., the data in its original text or binary format, parsing functions, etc.

You do not need pmtk to use this data.
However,  the pmtk function
<a href="http://pmtk3.googlecode.com/svn/trunk/pmtkTools/dataTools/loadData.m">loadData.m</a> 
can automatically download data on demand from this web site, avoiding the need to manually download anything.  
You can also use the command
<a href="http://code.google.com/p/pmtk3/source/browse/trunk/pmtkTools/dataTools/downloadAllData.m">downloadAllData.m</a>
to download all of the data sets at once, although this is slow.
If you do download directly, you should edit the
<a href="http://pmtk3.googlecode.com/svn/trunk/config.txt">config.txt</a> file (or create local-config.txt)
to specify the location of the data directories. 

Contributors of data to this site should follow the guidelines
<a href="http://code.google.com/p/pmtkdata/wiki/GuidelinesForContributors">here</a>
to ensure their data is easily accessible by others.
