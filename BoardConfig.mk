# TWRP 3.7.0 board config — Samsung W2017 (SM-W2017, veyronltectc)
# Values for boot image layout were read from the stock recovery.img of
# W2017KEU1ARG1 (identical in W2017KEU1APJ7).

DEVICE_PATH := device/samsung/veyronltectc_twrp

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := kryo
TARGET_CPU_SMP := true
TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := cortex-a53

TARGET_BOARD_PLATFORM := msm8996
TARGET_BOOTLOADER_BOARD_NAME := msm8996
TARGET_NO_BOOTLOADER := true
TARGET_NO_RADIOIMAGE := true
TARGET_OTA_ASSERT_DEVICE := veyronltectc,veyronlte,SM-W2017

# Kernel / dtb — taken from stock recovery.img (W2017KEU1ARG1)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image.gz
TARGET_PREBUILT_DTB := $(DEVICE_PATH)/prebuilt/dtb.img
BOARD_KERNEL_IMAGE_NAME := Image.gz
BOARD_KERNEL_SEPARATED_DT := true

# Boot image layout (from stock recovery.img header)
BOARD_KERNEL_CMDLINE := console=null androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 ehci-hcd.park=3 lpm_levels.sleep_disabled=1 cma=24M@0-0xffffffff rcupdate.rcu_expedited=1
BOARD_KERNEL_BASE := 0x80000000
BOARD_KERNEL_PAGESIZE := 4096
BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x00008000 --ramdisk_offset 0x02200000 --tags_offset 0x02000000 --board RILPF15A000RU
BOARD_CUSTOM_BOOTIMG_MK := $(DEVICE_PATH)/bootimg.mk

# Partitions — read from the device with `blockdev --getsize64`
# /dev/block/bootdevice/by-name/<name> (SM-W2017, 64 GB, W2017KEU1ARG1).
BOARD_BOOTIMAGE_PARTITION_SIZE := 0x4C00000
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 0x4C00000
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 0x157C00000
BOARD_CACHEIMAGE_PARTITION_SIZE := 0xC800000
BOARD_FLASH_BLOCK_SIZE := 131072

# Recovery
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
BOARD_SUPPRESS_SECURE_ERASE := true
TW_THEME := portrait_hdpi
TW_INCLUDE_CRYPTO := false
TW_EXCLUDE_DEFAULT_USB_INIT := false
TW_HAS_DOWNLOAD_MODE := true
TW_USE_TOOLBOX := true
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 128
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true
