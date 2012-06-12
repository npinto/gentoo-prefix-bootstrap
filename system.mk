ifndef SYSTEM_MK
SYSTEM_MK=system.mk

include init.mk

include stage0.mk
include stage1.mk
include stage2.mk
include stage3.mk
include stage4.mk

system: \
	stage0 \
	stage1 \
	stage2 \
	stage3 \
	stage4

endif
