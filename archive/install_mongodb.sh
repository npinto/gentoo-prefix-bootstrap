#!/bin/bash

source $(dirname $0)/init.sh

(cd $EPREFIX/usr/local/portage && $EPREFIX/usr/portage/scripts/ecopy dev-db/mongodb)

echo "dev-db/mongodb v8" >> $EPREFIX/etc/portage/package.use/mongodb
echo "dev-lang/v8 **" >> $EPREFIX/etc/portage/package.keywords/mongodb
echo "dev-db/mongodb **" >> $EPREFIX/etc/portage/package.keywords/mongodb

LDFLAGS="-L /usr/lib -L $EPREFIX/usr/lib" CXXFLAGS="-I /usr/include -I $EPREFIX/usr/include" CXX=g++ emerge -v mongodb

# From:
# http://www.bitcetera.com/en/techblog/2011/02/15/nosql-on-mac-os-x

# alias mongo-start="mongod --fork --dbpath \$EPREFIX/var/lib/mongodb --logpath \$EPREFIX/var/log/mongodb.log"
# alias mongo-stop="killall -SIGTERM mongod 2>/dev/null"
# alias mongo-status="killall -0 mongod 2>/dev/null; if [ \$? -eq 0 ]; then echo 'started'; else echo 'stopped'; fi"

