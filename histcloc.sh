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
CLOC=$(pwd)/cloc/cloc-1.56.pl
# Define excluded directories for CLOC call
EXCLUDE_DIRS=".git,target,node_modules,.settings"
# The temporary directory
TMPDIR=/tmp
# Output image file name
OUTFILE=$(pwd)/stats.png

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
TMPREVS=$(mktemp)
sed -n "0~${EACH}p" ${LOG} > ${TMPREVS}
echo "Extracted $(wc -l ${TMPREVS} | cut -d" " -f1) relevant revisions."
revs=($(cat ${TMPREVS}))


# Constant qualifiers for collected numbers
VALS=(files blank comment code)

# ----------------------------------------------------------------------
# Fetch each relevant revision and determine stats.
echo "Iterating over relevant revisions."
max_index=${#revs[*]}
# Format is: "Index,Revision,Type,Files,Code,Comment,Blank"
statfile=$(mktemp)

for ((i = 0; i < ${max_index}; i++))
do
  rev=${revs[${i}]}
  echo "----------------------------------------------------------------------"
  echo "$((i + 1))/${SNAP_COUNT}) Checking out revision ${rev}."
  git checkout -q ${rev}
  cur=$(mktemp)
  ${CLOC} --exclude-dir=${EXCLUDE_DIRS} --quiet --csv --csv-delimiter=" " --progress-rate=0 ${WD}/ > ${cur}

  # remove head line from CSV
  csv=${TMPDIR}/${rev}.csv
  sed -n '3,$p' ${cur} > ${csv}
  rm ${cur}

  while read -r files typ blank comment code
  do
    echo "${i},${rev},${typ},${files},${code},${comment},${blank}" >> ${statfile}
    echo "${i},${rev},${typ},${files},${code},${comment},${blank}" 
  done < ${csv}
  echo -en "\n\n" >> ${statfile}
  rm ${csv}

done
echo "Wrote ${statfile}."

# ----------------------------------------------------------------------
# Make plottable output file from data, so that we 
# can use it in GNUPlot.
plottable=$(mktemp)
declare -a types
types=($(cut -d, -f3 ${statfile} | sort | uniq | tr -s "\r\n" "  "))
type_count=${#types[*]}
echo -n "Revision " > ${plottable}
echo -n "Revision " 
for ((i = 0; i < ${type_count}; i++))
do
  echo -n "${types[${i}]} " >> ${plottable}
  echo -n "${types[${i}]} " 
done
echo -en "\n" >> ${plottable}
echo -en "\n"

for ((i = 0; i < ${max_index}; i++))
do
  rev=${revs[${i}]}
  echo -n "${rev:0:6} " >> ${plottable}
  echo -n "${rev:0:6} " 
  for ((j = 0; j < ${type_count}; j++))
  do
    typ=${types[${j}]}
    num_files=$(grep "${rev},${typ}," ${statfile} | cut -d, -f5 | tr -s "\r\n" "  ")
    if [ -n "${num_files}" ];
    then
      echo -n "${num_files}" >> ${plottable}
      echo -n "${num_files}" 
    else
      echo -n "-" >> ${plottable}
      echo -n "-" 
    fi
  done
  echo -en "\n" >> ${plottable}
  echo -en "\n" 
done
echo "Wrote data to ${plottable}."

gnuplot <<PLOTSCR
set terminal png size 800,500
set output "${OUTFILE}"

set autoscale
set style data linespoints

set datafile missing "-"

set xlabel "Revision"
set ylabel "Lines of code"
set title "Code stats for project"
set key default outside 

set xtics nomirror rotate

plot '${plottable}' using 2:xtic(1) title columnheader(2), \
  for [i=3:${type_count}] '' using i title columnheader(i)
PLOTSCR
echo "Generated plot as ${OUTFILE}."

# Some cleanup
rm ${TMPREVS}
rm ${LOG}
rm ${statfile}
rm ${plottable}
echo "Removed temporary files."

echo "Done."
exit 0

