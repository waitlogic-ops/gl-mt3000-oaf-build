# Diagnostic/build targets using the configured OpenWrt kernel recipe.
# The separate apply-vendor-hash.py script records the requested hash override.
.PHONY: audit-kernel-config
audit-kernel-config: $(STAMP_CONFIGURED)
	@echo "Native kernel configuration: $(LINUX_DIR)"
	@cat $(LINUX_DIR)/.vermagic

.PHONY: build-kernel-modules
build-kernel-modules: $(LINUX_DIR)/.modules
