# Adapted from https://gist.github.com/777954


#
# this gist can be used to list all targets, or - more correctly - rules,
# that are defined in a Makefile (and possibly other included Makefiles)
# and is inspired by Jack Kelly's reply to a StackOverflow question:
#
#   http://stackoverflow.com/questions/3063507/list-goals-targets-in-gnu-make/3632592#3632592
#
# I also found this script - http://www.shelldorado.com/scripts/cmds/targets - which does
# something similar using awk, but it extracts targets from the "static" rules from a single
# Makefile, meaning it ignores any included Makefiles, as well as targets from "dynamic" rules
#
# Notes:
#
# (1) the sed expression is "scraping" the make output, and will hence break of the output format ever changes
# (2) the "-r" option excludes the built-in rules, as these are typically not relevant, but isn't required
# (3) to improve the readability of the output, "| egrep -v '^.PHONY:'" can be appended to the pipeline
# (4) implementation as a shell alias or as a Makefile target left as an exercise to the reader :-)
#

#
# in the directory containing your Makefile:
#
#make -rpn | sed -n -e '/^$/ { n ; /^[^ ]*:/p }'

#
# ... or add a touch of color by highlighting the targets in the rules:
#
make -rpn | sed -n -e '/^$/ { n ; /^[^ ]*:/p }' | egrep --color '^[^ ]*:'
