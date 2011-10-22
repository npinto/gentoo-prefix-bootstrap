ifndef HELPERS_MK
HELPERS_MK=helpers.mk

# ============================================================================
# -- Helpers
# ============================================================================

debug:
	export EPREFIX=${EPREFIX}-debug

clean:
	rm -f bootstrap-prefix-patched.sh
	rm -f bootstrap-prefix-*.patch
	rm -f install/stage*

uninstall: uninstall-ask uninstall-force

uninstall-ask:
	@echo "*************************************************************"
	@echo "** WARNING WARNING WARNING WARNING WARNING WARNING WARNING **"
	@echo "*************************************************************"
	@echo "Are you sure you want to uninstall ${EPREFIX} ??"
	@echo "Press any key to continue or CTRL-C to cancel."
	@echo
	@read null
	@echo "*************************************************************"
	@echo "Are you really really sure ???"
	@echo "Press any key to continue or CTRL-C to cancel."
	@echo
	@read null

uninstall-force: clean
	mv -f ${EPREFIX} ${EPREFIX}.deleteme 2> /dev/null || exit 0
	rm -rf ${EPREFIX}.deleteme

backup: ${EPREFIX}
	mv -vf ${EPREFIX} ${EPREFIX}-backup-$(shell date +"%Y-%m-%d_%Hh%Mm%Ss")

help:
	@cat README.txt
	@echo
	@echo "Available actions (targets):"
	@echo "----------------------------"
	@./utils/list_make_targets.sh
	@echo
	@echo "To see which commands will be executed by each action, use:"
	@echo "\$$ make -n action"
	@echo
	@echo "To debug an action in a ${EPREFIX}-debug, use:"
	@echo "\$$ make debug action"
	@echo

endif
