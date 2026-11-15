$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base_telephony.mk)
$(call inherit-product, vendor/omni/config/common.mk)

$(call inherit-product, device/samsung/veyronltectc_twrp/device.mk)

PRODUCT_DEVICE := veyronltectc
PRODUCT_NAME := omni_veyronltectc
PRODUCT_BRAND := samsung
PRODUCT_MODEL := SM-W2017
PRODUCT_MANUFACTURER := samsung
