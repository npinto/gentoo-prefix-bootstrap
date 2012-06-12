# ============================================================================
# Gentoo Prefix Bootstrap
# ============================================================================
# see README.txt

.PHONY: default
default: system tools

include init.mk
include helpers.mk

include system.mk
include tools.mk
