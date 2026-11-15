LOCAL_PATH := $(call my-dir)

FLASH_IMAGE_TARGET ?= $(PRODUCT_OUT)/recovery.tar

# The vendor kernel helpers (vendor/omni/build/tasks/kernel.mk) are not part of
# this tree, so the prebuilt kernel has to be installed at the path the build
# system expects. recovery_kernel expands to $(PRODUCT_OUT)/kernel.
$(PRODUCT_OUT)/kernel: $(TARGET_PREBUILT_KERNEL)
	@echo "Copy prebuilt kernel: $@"
	$(hide) cp -f $< $@

# A boot image is only required because the recovery ramdisk depends on it. It
# is built from the same prebuilt kernel and dtb so the tree stays consistent.
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(PRODUCT_OUT)/kernel $(INSTALLED_RAMDISK_TARGET) $(TARGET_PREBUILT_DTB)
	@echo "Making boot image: $@"
	$(hide) $(MKBOOTIMG) --kernel $(PRODUCT_OUT)/kernel \
		--ramdisk $(INSTALLED_RAMDISK_TARGET) \
		--base $(BOARD_KERNEL_BASE) \
		--pagesize $(BOARD_KERNEL_PAGESIZE) \
		--kernel_offset 0x00008000 \
		--ramdisk_offset 0x02200000 \
		--tags_offset 0x02000000 \
		--board RILPF15A000KU \
		--cmdline "$(BOARD_KERNEL_CMDLINE)" \
		--dt $(TARGET_PREBUILT_DTB) \
		--output $@

ifdef TARGET_PREBUILT_DTB
    BOARD_MKBOOTIMG_ARGS += --dt $(TARGET_PREBUILT_DTB)
endif

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_kernel) $(recovery_ramdisk)
	@echo "----- Making recovery image ------"
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@ --ramdisk $(recovery_ramdisk)
	@echo "----- Lying about SEAndroid state to Samsung bootloader ------"
	$(hide) echo -n "SEANDROIDENFORCE" >> $(INSTALLED_RECOVERYIMAGE_TARGET)
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	$(hide) tar -C $(PRODUCT_OUT) -H ustar -c recovery.img > $(FLASH_IMAGE_TARGET)

.PHONY: recoverytar
recoverytar: $(FLASH_IMAGE_TARGET)
