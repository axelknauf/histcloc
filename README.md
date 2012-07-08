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
- plotting shall be done using either RRDTool or GNUPlot

Heuristic as follows:
- Check working copy compatibility
- Verify it is using a compatible SCM (only git)
- Check size of the history
- Make assumptions on how many snapshots to take (eventually
  parameterized from user input first)
- Check out snapshots, run cloc across the interim state, collect data
  from snapshot, collect into data model (associative array), plot data,
  done. 

License & Source code
- CLOC is licensed under the GPL v2 which can be accessed at
  http://www.gnu.org/licenses/gpl-2.0.html
- CLOC source code is available from SourceForge at
  http://cloc.sourceforge.net
- This tool shall also be licensed under the GPL v2.

