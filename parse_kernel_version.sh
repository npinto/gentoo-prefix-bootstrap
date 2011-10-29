#!/bin/bash

uname -r
#2.6.38-12-generic

uname -r | sed -e 's,\..*,,'
#2

uname -r | sed  -e 's,[^\.]*\.,,' -e 's,\..*,,'
#6

uname -r | sed -e 's,[^\.]*\.,,' -e 's,[^\.]*\.,,' -e 's,\-.*,,'
#38

# XXX: for KERNEL 3.0, see:
# http://sourceforge.net/tracker/index.php?func=detail&aid=3405532&group_id=58425&atid=487692
