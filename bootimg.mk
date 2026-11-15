LOCAL_PATH := $(call my-dir)

FLASH_IMAGE_TARGET ?= $(PRODUCT_OUT)/recovery.tar

# The vendor kernel helpers (vendor/omni/build/tasks/kernel.mk) are not part of
# this tree, so the prebuilt kernel has to be installed at the path the build
# system expects. recovery_kernel expands to $(PRODUCT_OUT)/kernel.
$(PRODUCT_OUT)/kernel: $(TARGET_PREBUILT_KERNEL)
	@echo "Copy prebuilt kernel: $@"
	$(hide) cp -f $< $@

# BOARD_KERNEL_SEPARATED_DT makes the build pass --dt $(PRODUCT_OUT)/dt.img, so
# the prebuilt QCDT image has to be installed under that name.
$(INSTALLED_DTIMAGE_TARGET): $(TARGET_PREBUILT_DTB)
	@echo "Copy prebuilt dt image: $@"
	$(hide) cp -f $< $@
	$(hide) truncate -s %4096 $@

# A boot image is only required because the recovery ramdisk depends on it. It
# is built from the same prebuilt kernel and dtb so the tree stays consistent.
$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(PRODUCT_OUT)/kernel $(INSTALLED_RAMDISK_TARGET) $(INSTALLED_DTIMAGE_TARGET)
	@echo "Making boot image: $@"
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE))

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(recovery_kernel) $(recovery_ramdisk) $(RECOVERYIMAGE_EXTRA_DEPS)
	@echo "----- Making recovery image ------"
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@ --ramdisk $(recovery_ramdisk)
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE),raw)
	$(hide) tar -C $(PRODUCT_OUT) -H ustar -c recovery.img > $(FLASH_IMAGE_TARGET)

.PHONY: recoverytar
recoverytar: $(FLASH_IMAGE_TARGET)
