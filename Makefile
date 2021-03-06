BOARD:=overlay
BOARD_DIR=$(BOARD)
DEFCONFIG=$(BOARD)_defconfig

# Board-agnostic settings
BUILDROOT = ./buildroot
CONFIG = $(OUTPUT)/.config
BOARD_DIR = ./$(BOARD)

# Build target
TARGET_NAME = rxos

# Build output files
OUTPUT = out
OUTPUT_DIR = ../$(OUTPUT)
IMAGES_DIR = $(OUTPUT)/images
KERNEL_IMAGE = $(IMAGES_DIR)/zImage
BUILD_STAMP = $(OUTPUT)/.stamp_built
IMG_FILE = $(IMAGES_DIR)/sdcard.img
PKG_FILE = $(IMAGES_DIR)/rxos.pkg

# External dir
EXTERNAL = .$(BOARD_DIR)
export BR2_EXTERNAL=$(EXTERNAL)

.PHONY: \
	default \
	version \
	build \
	rebuild \
	rebuild-with-linux \
	rebuild-everything \
	flash \
	update \
	menuconfig \
	linuxconfig \
	busyboxconfig \
	saveconfig \
	clean-rootfs \
	clean-linux \
	clean-deep \
	clean \
	config

default: build

build: $(BUILD_STAMP)

menuconfig: $(CONFIG)
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) menuconfig

linuxconfig: $(CONFIG)
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) linux-menuconfig

busyboxconfig: $(CONFIG)
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) busybox-menuconfig

saveconfig: $(CONFIG)
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) savedefconfig
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) linux-update-defconfig
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) busybox-update-config

config: $(CONFIG)

rebuild: clean-rootfs build

rebuild-with-linux: clean-linux build

rebuild-everything: clean-deep build

clean-rootfs:
	@-rm $(BUILD_STAMP)
	@-rm $(IMAGES_DIR)/rootfs.*
	@-rm $(IMAGES_DIR)/*.sqfs
	@-rm $(IMG_FILE)

clean-linux: clean-rootfs
	@-rm $(KERNEL_IMAGE)
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) linux-dirclean

clean-deep: config clean-linux
	@-rm -rf $(IMAGES_DIR)
	@-rm -rf `ls $(OUTPUT)/build | grep -v host-`
	@-rm -rf $(OUTPUT)/target
	@-rm $(OUTPUT)/staging
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) skeleton-rebuild

clean:
	-rm -rf $(OUTPUT)

config:
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) $(DEFCONFIG)

$(BUILD_STAMP): $(CONFIG)
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR)
	touch $@

$(CONFIG):
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) $(DEFCONFIG)

.DEFAULT:
	@make -C $(BUILDROOT) O=$(OUTPUT_DIR) $@
