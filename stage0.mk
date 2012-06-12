ifndef STAGE0_MK
STAGE0_MK=stage0.mk

include init.mk

stage0: install/stage0
install/stage0: bootstrap-prefix.sh
	mkdir -p install
	touch $@

bootstrap-prefix.sh:
	wget -O bootstrap-prefix.sh http://overlays.gentoo.org/proj/alt/browser/trunk/prefix-overlay/scripts/bootstrap-prefix.sh?format=txt
	chmod 755 bootstrap-prefix.sh

endif
