# This is free software, licensed under the Apache License, Version 2.0
#
# Copyright (C) 2024 Maizil <maizilpc7@gmail.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=blynk-lua
PKG_MAINTAINER:=Maizil <maizilpc7@gmail.com>
PKG_VERSION:=1.0
PKG_RELEASE:=beta
PKG_LICENSE:=Apache-2.0
PKG_ARCH:=all

PKG_DESCRIPTION:=Blynk Lua client library for OpenWrt integration, allowing control of IoT devices via Blynk.

PKG_DEPENDS:=+luasocket

include $(INCLUDE_DIR)/package.mk

$(eval $(call BuildPackage, $(PKG_NAME)))
