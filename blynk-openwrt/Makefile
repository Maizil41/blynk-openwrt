# This is free software, licensed under the Apache License, Version 2.0
#
# Copyright (C) 2024 Maizil <maizilpc7@gmail.com>

include $(TOPDIR)/rules.mk

PKG_NAME:=blynk-openwrt
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Maizil <https://github.com/Maizil41>

include $(INCLUDE_DIR)/package.mk

define Package/$(PKG_NAME)
  SECTION:=net
  CATEGORY:=Network
  TITLE:=blynk-openwrt
  URL:=https://github.com/Maizil41/blynk-openwrt
  PKGARCH:=all
  DEPENDS:=+luasocket
endef

define Package/$(PKG_NAME)/description
  Blynk Lua client library for OpenWrt integration, allowing control of IoT devices via Blynk.
endef

define Package/$(PKG_NAME)/conffiles
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/$(PKG_NAME)/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share

	$(CP) -r ./files/etc/init.d/* $(1)/etc/init.d/
	$(CP) -r ./files/usr/bin/* $(1)/usr/bin/
	$(CP) -r ./files/usr/share/* $(1)/usr/share/
	$(CP) ./files/postinst $(1)/etc/
endef

$(eval $(call BuildPackage,$(PKG_NAME)))
