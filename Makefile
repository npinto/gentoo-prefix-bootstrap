# ============================================================================
# Bootstrap a Scientific Gentoo Prefix
# ============================================================================
# see README.txt

include helpers.mk

include system.mk
include tools.mk
include scientific.mk

default: system tools scientific
