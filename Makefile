# ============================================================================
# Gentoo Prefix Bootstrap
# ============================================================================
# see README.txt

.PHONY: default
default: system

include init.mk
include helpers.mk

include system.mk
