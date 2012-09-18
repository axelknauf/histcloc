histcloc
========

Graphical representation of count-lines-of-code data across SCM history

This tool tries to use cloc[0] in order to determine code statistics
from a given filesystem location. In order to represent the historical
development of the codebase, the history will be evaluated and different
states from it shall be snapshotted. 

[0] http://cloc.sourceforge.net

Planned so far:
- git source code management tool (maybe svn later on, or even
  pluggable)
- cloc 1.5.6 as coming from Sourceforge (see link above)
- plotting shall be done using GNUPlot

Processing takes place as follows:
- Check working copy compatibility: is it a git working copy? 
- Check size of the history: do we have enough revisions for making
  snapshots? 
- Use user input for snapshot count, working copy path, output file..
- Check out snapshots, run cloc across the revision, collect data from
  snapshot, collect into data model (temporary file), plot data,
  done. 

Requirements
- CLOC (Perl version for Linux is included)
- Perl for running CLOC
- Bash v4 or later
- Unix tools: sed, cut, grep, tr 
- git 1.7.9 or later, possibly earlier versions (not tested)
- gnuplot, tested with 4.4.4

License & Source code
- CLOC is licensed under the GPL v2 which can be accessed at
  http://www.gnu.org/licenses/gpl-2.0.html
- CLOC source code is available from SourceForge at
  http://cloc.sourceforge.net
- This tool is licensed under the GPL v2.

