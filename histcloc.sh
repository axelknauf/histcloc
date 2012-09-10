#!/bin/bash
# ----------------------------------------------------------------------
# This file is distributed under the GNU General Public License v2
# Please see
#   http://www.gnu.org/licenses/gpl-2.0.html
#   https://github.com/axelknauf/histcloc
# for details.
# ----------------------------------------------------------------------
# FIXME: add checking for necessary tools, git, sed, cloc
# FIXME: make script parameterizable from command line or config file
# FIXME: make output format generic for post-processing by other tools
# FIXME: optional output of graphical statistics with RRDTool or GNUPlot
# FIXME: code cleanup, extract function
# FIXME: support other SCMs like SVN, CVS, ..
# FIXME: add excludes to CLOC call
# ----------------------------------------------------------------------
# 
# ----------------------------------------------------------------------
# 1) Configuration options
# The code base under analysis, must be a git repo by now
#WD=/home/axe/code/tribler/release-5.5.x
WD=/cygdrive/c/dev/code/oss/istudy
# How many shapshots to take
SNAP_COUNT=3
# Which cloc utility to use (defaults to the shipped one)
CLOC=/cygdrive/c/dev/code/oss/histcloc/cloc/cloc-1.56.pl
# Define excluded directories for CLOC call
EXCLUDE_DIRS=".git,target,node_modules,.settings"
# The temporary directory
TMPDIR=/tmp

if [ ! -d ${WD} ]; then
  echo "Working copy does not exist or is not a directory."
  exit 1
fi

cd ${WD} && git status > /dev/null 2>&1
GIT_STATUS=$?
if [ ${GIT_STATUS} -ne 0 ]; then
  echo "Either not a git working copy, or not clean. Aborting."
  exit 1
fi

echo "Working copy is ${WD}."
echo "Desired snapshot count is ${SNAP_COUNT}."

# ----------------------------------------------------------------------
# 2) Internal variables and setup
# Determine which revisions to fetch from working copy
LOG=$(mktemp)
git checkout -q master
git log --reverse --format=%H ${WD} > ${LOG}
TOTAL=$(wc -l ${LOG} | cut -d" " -f1)
echo "Total number of revisions in working copy is ${TOTAL}."

if [ ${TOTAL} -lt ${SNAP_COUNT} ]; then
  echo "No enough revisions (${TOTAL})."
  exit 1
fi

declare -i EACH
EACH="${TOTAL} / ${SNAP_COUNT}"

echo "Using each ${EACH}th revision."

# ----------------------------------------------------------------------
# sed -n 'Xp' <file> will print the X'th line of the 'file'
# http://stackoverflow.com/a/448047
echo "Determining relevant revisions from full history."
REVS=$(mktemp)
sed -n "0~${EACH}p" ${LOG} > ${REVS}
echo "Extracted $(wc -l ${REVS} | cut -d" " -f1) relevant revisions."


# This is the master associative array containing all the statistics
# once collected from the source code. It will be used to generate the
# output at the end of the script.
declare -A stats

# ----------------------------------------------------------------------
# Fetch each relevant revision and determine stats.
counter=1
echo "Iterating over relevant revisions."
while read rev
do
  echo "----------------------------------------------------------------------"
  echo "${counter}/${SNAP_COUNT}) Checking out revision ${rev}."
  counter=$(( ${counter} + 1 ))
  git checkout -q ${rev}
  cur=$(mktemp)
  ${CLOC} --exclude-dir=${EXCLUDE_DIRS} --quiet --csv --progress-rate=0 ${WD}/ > ${cur}

  # remove head line from CSV
  csv=${TMPDIR}/${rev}.csv
  sed -n '3,$p' ${cur} > ${csv}

  while read line
  do
    echo ${line}
    typ=$(echo ${line} | cut -d, -f2 -)
    count_files=$(echo ${line} | cut -d, -f1 -)
    echo "Total ${count_files} ${typ} files."
  done < ${csv}

done < ${REVS}

echo "Done."
exit 0

