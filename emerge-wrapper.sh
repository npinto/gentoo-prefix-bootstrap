#!/bin/bash

set -e
set -x

cd ${REAL_HOME} && emerge $*
