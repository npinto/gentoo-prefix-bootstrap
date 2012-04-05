ifndef SYSTEM_MK
SYSTEM_MK=system.mk

include init.mk

include stage0.mk
include stage1.mk
include stage2.mk
include stage3.mk
include stage4.mk

system: \
	install/stage0 \
	install/stage1 \
	install/stage2 \
	install/stage3 \
	install/stage4

endif
