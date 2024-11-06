# This is free software, licensed under the Apache License, Version 2.0
#
# Copyright (C) 2024 Maizil <maizilpc7@gmail.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=blynk-openwrt
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Maizil <https://github.com/Maizil41>

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Maizil41/blynk-openwrt.git
PKG_SOURCE_VERSION:=master
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Blynk Lua client library for OpenWrt
  URL:=https://github.com/Maizil41/blynk-openwrt
  PKGARCH:=all
endef

define Package/$(PKG_NAME)/description
  Blynk Lua client library for OpenWrt integration, allowing control of IoT devices via Blynk.
endef

define Package/$(PKG_NAME)/conffiles
endef

define Build/Prepare
  $(CP) -r $(PKG_BUILD_DIR)/files/* $(1)
endef

define Build/Compile

endef

define Package/$(PKG_NAME)/install
    $(INSTALL_DIR) $(1)/etc/init.d
    $(INSTALL_DIR) $(1)/usr/bin
    $(INSTALL_DIR) $(1)/usr/share

    $(CP) -r $(PKG_BUILD_DIR)/files/etc/init.d/* $(1)/etc/init.d/
    $(CP) -r $(PKG_BUILD_DIR)/files/usr/bin/* $(1)/usr/bin/
    $(CP) -r $(PKG_BUILD_DIR)/files/usr/share/* $(1)/usr/share/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
