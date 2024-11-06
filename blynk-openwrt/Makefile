# This is free software, licensed under the Apache License, Version 2.0
#
# Copyright (C) 2024 Maizil <maizilpc7@gmail.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=blynk-lua
PKG_MAINTAINER:=Maizil <maizilpc7@gmail.com>
PKG_VERSION:=2.6
PKG_RELEASE:=beta
PKG_LICENSE:=Apache-2.0
PKG_ARCH:=all

PKG_DESCRIPTION:=Blynk Lua client library for OpenWrt integration, allowing control of IoT devices via Blynk.

PKG_DEPENDS:=+luasocket

ifeq ($(PKG_NAME), blynk-lua)
  DOWNLOAD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
  TAR_FILE:=$(DL_DIR)/$(PKG_NAME)-$(PKG_VERSION).tar.gz
  ifneq ($(wildcard $(TAR_FILE)),)
    $(info Paket sudah ada di $(TAR_FILE))
  else
    $(info Mendownload paket $(TAR_FILE)...)
    $(call Download, $(TAR_FILE), https://example.com/path/to/blynk-lua-$(PKG_VERSION).tar.gz)
  endif
endif

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage, $(PKG_NAME)))
