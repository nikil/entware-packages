#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Package/python-setuptools
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) setuptools module
  DEPENDS:=+python
endef

define PyPackage/python-setuptools/install
	$(INSTALL_DIR) $(1)/opt/bin $(1)/opt/lib/python$(PYTHON_VERSION)/site-packages
	# Adjust shebang to proper python location on target
	sed "1s/.*/#\!\/opt\/bin\/python$(PYTHON_VERSION)/" -i $(PKG_BUILD_DIR)/install-setuptools/bin/*
	$(CP) $(PKG_BUILD_DIR)/install-setuptools/bin/* $(1)/opt/bin
	$(CP) \
		$(PKG_BUILD_DIR)/install-setuptools/lib/python$(PYTHON_VERSION)/site-packages/pkg_resources \
		$(PKG_BUILD_DIR)/install-setuptools/lib/python$(PYTHON_VERSION)/site-packages/setuptools \
		$(PKG_BUILD_DIR)/install-setuptools/lib/python$(PYTHON_VERSION)/site-packages/easy_install.py \
		$(1)/opt/lib/python$(PYTHON_VERSION)/site-packages
endef

$(eval $(call PyBasePackage,python-setuptools, \
	, \
	DO_NOT_ADD_TO_PACKAGE_DEPENDS \
))
