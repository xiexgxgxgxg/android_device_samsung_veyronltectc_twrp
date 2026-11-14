# TWRP device config — Samsung W2017 (WIP)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

PRODUCT_DEVICE := veyronltectc
PRODUCT_NAME := omni_veyronltectc
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-W2017
PRODUCT_MANUFACTURER := samsung

# TWRP flags
TW_DEVICE_VERSION := veyronltectc-wip
