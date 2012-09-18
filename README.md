histcloc
========

Graphical representation of count-lines-of-code data across SCM history

This tool tries to use [cloc](http://cloc.sourceforge.net) in order to determine code statistics
from a given filesystem location. In order to represent the historical
development of the codebase, the history will be evaluated and different
states from it shall be snapshotted. 

Example
-------

The following data and image have been generated from an actual project
working copy:

![histcloc example image](https://github.com/axelknauf/histcloc/blob/master/test/stats.png)

And here is the [data file](https://github.com/axelknauf/histcloc/blob/master/test/test.dat) for this image.


Processing
----------

Processing takes place as follows:
- Check working copy compatibility: is it a git working copy? 
- Check size of the history: do we have enough revisions for taking
  snapshots?
- Use user input for snapshot count, working copy path, output file..
- Check out snapshots, run cloc across the revision, collect data from
  snapshot, collect into data model (temporary file), plot data,
  done. 

Requirements
------------

- CLOC (Perl version for Linux is included)
- Perl for running CLOC
- Bash v4 or later
- Unix tools: sed, cut, grep, tr 
- git 1.7.9 or later, possibly earlier versions (not tested)
- gnuplot, tested with 4.4.4

This version has been tested on Cygwin (Bash 4.1.10) with GNUPlot 4.4.4
and the embedded CLOC version (1.5.6).

License & Source code
---------------------

- CLOC is licensed under the GPL v2 which can be accessed at
  http://www.gnu.org/licenses/gpl-2.0.html
- CLOC source code is available from SourceForge at
  http://cloc.sourceforge.net
- This tool is licensed under the GPL v2.

