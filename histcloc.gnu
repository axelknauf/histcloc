# ---------------------------------------------------------------------
# GNUPlot definition for use with histcloc.sh
# Distributed unter the GPL v2.0 or later
# Please see
#   http://www.gnu.org/licenses/gpl-2.0.html
#   https://github.com/axelknauf/histcloc
# for details.
# ---------------------------------------------------------------------
# Example format of a single block from the data file:
# #0ca5a42e2ea5bf0a1c07c39eb4560a7d65a5d689
# Java,91,5006,2037,1561
# Javascript,58,3248,3957,979
# CSS,1,2267,484,87
# JSP,35,2019,19,155
# HTML,13,1909,4,152
# XML,45,1612,232,244
# SQL,4,286,114,90
# Ruby,1,6,3,0

set terminal png
set output "stats.png"

set auto x
set autoscale
set style data histogram
set style histogram cluster gap 2
set style fill solid border -1
set boxwidth 0.9

#set ylabel "Code Statistics"
set xlabel "Revision"
set title "Code Statistics"
set xtics rotate
set key off

set datafile separator ","
plot "test/test.dat" using 4:xtic(1) ti col, "" u 5 ti col
