#!/bin/bash
# ----------------------------------------------------------------------
# This file is distributed under the GNU General Public License v2
# Please see
#   http://www.gnu.org/licenses/gpl-2.0.html
#   https://github.com/axelknauf/histcloc
# for details.
# ----------------------------------------------------------------------
# 1) Configuration options
# TODO extract as command line arguments

# The code base under analysis, just using an open source project I
# find interesting.
WD=/home/axe/code/tribler/release-5.5.x
# How many shapshots to take
SNAP_COUNT=10

# 2) Internal variables and setup
# Determine which revisions to fetch from working copy
LOG=$(mktemp)
git log --reverse --format=%H ${WD} > ${LOG}
TOTAL=$(wc -l ${LOG})
if [ ${TOTAL} < ${SNAP_COUNT} ]; then
  echo "No enough revisions (${TOTAL})."
  exit 1
fi

# sed -n 'Xp' file
# will print the X'th line of the 'file'


# Initialize array for data collection

# 3) Logic to fetch data 
# - iterate over revisions
# - check out revision
# - run CLOC with --quiet and --csv parameters
# - fetch data from CLOC output and collect it into an array

# 4) Output and summary
# - output the results

