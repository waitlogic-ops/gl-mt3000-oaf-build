# A diagnostic target using OpenWrt's unmodified native configuration recipe.
# This adds a target, but does not override any build or ABI variable.
.PHONY: audit-kernel-config
audit-kernel-config: $(STAMP_CONFIGURED)
	@echo "Native kernel configuration: $(LINUX_DIR)"
	@cat $(LINUX_DIR)/.vermagic
