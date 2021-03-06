#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

# For PYTHON_VERSION
include ./files/python-version.mk

PKG_NAME:=python
PKG_VERSION:=$(PYTHON_VERSION).$(PYTHON_VERSION_MICRO)
PKG_RELEASE:=4

PKG_SOURCE:=Python-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.python.org/ftp/python/$(PKG_VERSION)
PKG_MD5SUM:=53b43534153bb2a0363f08bae8b9d990
PKG_HASH:=35d543986882f78261f97787fd3e06274bfa6df29fac9b4a94f73930ff98f731

PKG_LICENSE:=PSF
PKG_LICENSE_FILES:=LICENSE Modules/_ctypes/libffi_msvc/LICENSE Modules/_ctypes/darwin/LICENSE Modules/_ctypes/libffi/LICENSE Modules/_ctypes/libffi_osx/LICENSE Tools/pybench/LICENSE

# This file provides the necsessary host build variables
include ./files/python-host.mk

# For PyPackage
include ./files/python-package.mk

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
HOST_BUILD_PARALLEL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/Python-$(PKG_VERSION)
HOST_BUILD_DIR:=$(BUILD_DIR_HOST)/Python-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=python/host
HOST_BUILD_DEPENDS:=bzip2/host expat/host

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/python/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python $(PYTHON_VERSION) programming language
  URL:=https://www.python.org/
  MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
endef

define Package/python/Default/description
 Python is a dynamic object-oriented programming language that can be used
 for many kinds of software development. It offers strong support for
 integration with other languages and tools, comes with extensive standard
 libraries, and can be learned in a few days. Many Python programmers
 report substantial productivity gains and feel the language encourages
 the development of higher quality, more maintainable code.
endef

define Package/python-pip-conf
$(call Package/python/Default)
  TITLE:=Configuration file for pip/pip3
  URL:=https://pip.pypa.io
endef

define Package/python-pip-conf/description
 Configuration file for pip/pip3
endef

define Package/python-base
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) interpreter
  DEPENDS:=+libpthread +zlib
endef

define Package/python-base/description
  This package contains only the interpreter and the bare minimum
  for the interpreter to start.
endef

define Package/python-light
$(call Package/python/Default)
  TITLE:=Python $(PYTHON_VERSION) light installation
  DEPENDS:=+python-base +libffi +libbz2
endef

define Package/python-light/description
  This package is essentially the python-base package plus
  a few of the rarely used (and big) libraries stripped out
  into separate packages.
endef

PYTHON_LIB_FILES_DEL:=
PYTHON_PACKAGES:=
PYTHON_PACKAGES_DEPENDS:=
define PyBasePackage
  PYTHON_PACKAGES+=$(1)
  ifeq ($(3),)
    PYTHON_PACKAGES_DEPENDS+=$(1)
  endif
  PYTHON_LIB_FILES_DEL+=$(2)
  define PyPackage/$(1)/filespec
    ifneq ($(2),)
      $(subst $(space),$(newline),$(foreach lib_file,$(2),+|$(lib_file)))
    endif
  endef
endef

include ./files/python-package-*.mk

define Package/python
$(call Package/python/Default)
  DEPENDS:=+python-light $(foreach package,$(PYTHON_PACKAGES_DEPENDS),+$(package))
endef

define Package/python/description
  This package contains the (almost) full Python install.
  It's python-light + all other packages.
endef

MAKE_FLAGS+=\
	CROSS_COMPILE=yes \
	LD="$(TARGET_CC)" \
	PGEN=pgen2

EXTRA_CFLAGS+= \
	-DNDEBUG -fno-inline
EXTRA_LDFLAGS+= \
	-L$(PKG_BUILD_DIR)

ENABLE_IPV6:=
ifeq ($(CONFIG_IPV6),y)
	ENABLE_IPV6 += --enable-ipv6
endif

PYTHON_FOR_BUILD:= \
	_PYTHON_PROJECT_BASE=$(PKG_BUILD_DIR) \
	_PYTHON_HOST_PLATFORM=linux2 \
	PYTHONPATH="$(PKG_BUILD_DIR)/Lib:$(PKG_BUILD_DIR)/build/lib.linux2-$(PYTHON_VERSION)" \
	_PYTHON_SYSCONFIGDATA_NAME=_sysconfigdata \
	$(HOST_PYTHON_BIN)

CONFIGURE_ARGS+= \
	--sysconfdir=/opt/etc \
	--enable-shared \
	--without-cxx-main \
	--with-threads \
	--with-system-ffi \
	--with-ensurepip=no \
	--without-pymalloc \
	PYTHON_FOR_BUILD="$(PYTHON_FOR_BUILD)" \
	$(ENABLE_IPV6) \
	CONFIG_SITE="$(PKG_BUILD_DIR)/config.site" \
	OPT="$(TARGET_CFLAGS)"

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) ./files/config.site $(PKG_BUILD_DIR)/config.site
endef

ifdef CONFIG_PACKAGE_python-setuptools
define Build/Compile/python-setuptools
	$(STAGING_DIR_HOSTPKG)/bin/pip install \
		--ignore-installed \
		--root=$(PKG_BUILD_DIR)/install-setuptools --prefix=. \
		$(PKG_BUILD_DIR)/Lib/ensurepip/_bundled/setuptools-*.whl
endef
endif # CONFIG_PACKAGE_python-setuptools

ifdef CONFIG_PACKAGE_python-pip
define Build/Compile/python-pip
	$(STAGING_DIR_HOSTPKG)/bin/pip install \
		--ignore-installed \
		--root=$(PKG_BUILD_DIR)/install-pip --prefix=. \
		$(PKG_BUILD_DIR)/Lib/ensurepip/_bundled/pip-*.whl
endef
endif # CONFIG_PACKAGE_python-pip

define Build/Compile
	$(call Build/Compile/Default)
	# Use host pip to install python-setuptools
	$(call Build/Compile/python-setuptools)
	$(call Build/Compile/python-pip)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/mk/
	$(INSTALL_DIR) $(1)/opt/include/ $(1)/opt/lib/ $(1)/opt/lib/pkgconfig
	$(INSTALL_DIR) $(1)/opt/lib/python$(PYTHON_VERSION)/
	$(INSTALL_DATA) \
		./files/python-package.mk \
		./files/python-host.mk \
		./files/python-version.mk \
		$(STAGING_DIR)/mk/
	$(CP) \
		$(PKG_INSTALL_DIR)/opt/include/python$(PYTHON_VERSION) \
		$(1)/opt/include/
	$(CP) \
		$(HOST_PYTHON_LIB_DIR) \
		$(PKG_INSTALL_DIR)/opt/lib/libpython$(PYTHON_VERSION).so* \
		$(1)/opt/lib/
	$(CP) \
		$(HOST_PYTHON_DIR)/lib/pkgconfig/python.pc \
		$(HOST_PYTHON_DIR)/lib/pkgconfig/python2.pc \
		$(HOST_PYTHON_DIR)/lib/pkgconfig/python-$(PYTHON_VERSION).pc \
		$(1)/opt/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/opt/lib/python$(PYTHON_VERSION)/config \
		$(1)/opt/lib/python$(PYTHON_VERSION)/
endef

PYTHON_BASE_LIB_FILES:= \
	/opt/lib/python$(PYTHON_VERSION)/_abcoll.py \
	/opt/lib/python$(PYTHON_VERSION)/_sysconfigdata.py \
	/opt/lib/python$(PYTHON_VERSION)/_weakrefset.py \
	/opt/lib/python$(PYTHON_VERSION)/abc.py \
	/opt/lib/python$(PYTHON_VERSION)/copy_reg.py \
	/opt/lib/python$(PYTHON_VERSION)/genericpath.py \
	/opt/lib/python$(PYTHON_VERSION)/linecache.py \
	/opt/lib/python$(PYTHON_VERSION)/posixpath.py \
	/opt/lib/python$(PYTHON_VERSION)/os.py \
	/opt/lib/python$(PYTHON_VERSION)/re.py \
	/opt/lib/python$(PYTHON_VERSION)/site.py \
	/opt/lib/python$(PYTHON_VERSION)/sre_compile.py \
	/opt/lib/python$(PYTHON_VERSION)/sre_constants.py \
	/opt/lib/python$(PYTHON_VERSION)/sre_parse.py \
	/opt/lib/python$(PYTHON_VERSION)/sysconfig.py \
	/opt/lib/python$(PYTHON_VERSION)/stat.py \
	/opt/lib/python$(PYTHON_VERSION)/traceback.py \
	/opt/lib/python$(PYTHON_VERSION)/types.py \
	/opt/lib/python$(PYTHON_VERSION)/UserDict.py \
	/opt/lib/python$(PYTHON_VERSION)/warnings.py

PYTHON_LIB_FILES_DEL+=$(PYTHON_BASE_LIB_FILES)

define PyPackage/python-base/filespec
+|/opt/bin/python$(PYTHON_VERSION)
$(subst $(space),$(newline),$(foreach lib_file,$(PYTHON_BASE_LIB_FILES),+|$(lib_file)))
endef

define PyPackage/python-light/filespec
+|/opt/lib/python$(PYTHON_VERSION)
-|/opt/lib/python$(PYTHON_VERSION)/distutils/cygwinccompiler.py
-|/opt/lib/python$(PYTHON_VERSION)/distutils/command/wininst*
-|/opt/lib/python$(PYTHON_VERSION)/ensurepip
-|/opt/lib/python$(PYTHON_VERSION)/idlelib
-|/opt/lib/python$(PYTHON_VERSION)/lib-tk
-|/opt/lib/python$(PYTHON_VERSION)/lib-dynload/_testcapi.so
-|/opt/lib/python$(PYTHON_VERSION)/pdb.doc
-|/opt/lib/python$(PYTHON_VERSION)/test
-|/opt/lib/python$(PYTHON_VERSION)/webbrowser.py
-|/opt/lib/python$(PYTHON_VERSION)/*/test
-|/opt/lib/python$(PYTHON_VERSION)/*/tests
-|/opt/lib/python$(PYTHON_VERSION)/lib-dynload/readline.so
$(subst $(space),$(newline),$(foreach lib_file,$(PYTHON_LIB_FILES_DEL),-|$(lib_file)))
endef

define PyPackage/python-base/install
	$(LN) python$(PYTHON_VERSION) $(1)/opt/bin/python
	$(LN) python$(PYTHON_VERSION) $(1)/opt/bin/python2
	$(CP) $(PKG_INSTALL_DIR)/opt/lib/libpython$(PYTHON_VERSION).so* $(1)/opt/lib/
endef

define PyPackage/python/filespec
-|$(PYTHON_PKG_DIR)
endef

define Package/python-pip-conf/install
	$(INSTALL_DIR) $(1)/opt/etc
	$(CP) ./files/pip.conf $(1)/opt/etc
endef

HOST_LDFLAGS += \
	$$$$(pkg-config --static --libs libcrypto libssl)

HOST_CONFIGURE_ARGS+= \
	--without-cxx-main \
	--without-pymalloc \
	--with-threads \
	--prefix=$(HOST_PYTHON_DIR) \
	--exec-prefix=$(HOST_PYTHON_DIR) \
	--with-system-expat=$(STAGING_DIR_HOSTPKG) \
	--with-system-ffi=no \
	--with-ensurepip=install \
	CONFIG_SITE=

define Host/Install
	$(MAKE) -C $(HOST_BUILD_DIR) install
	$(INSTALL_DIR) $(HOST_PYTHON_DIR)/bin/
	$(INSTALL_BIN) $(HOST_BUILD_DIR)/Parser/pgen $(HOST_PYTHON_DIR)/bin/pgen2
endef

$(eval $(call HostBuild))

$(foreach package, $(PYTHON_PACKAGES),  \
	$(eval $(call PyPackage,$(package))) \
	$(eval $(call BuildPackage,$(package))) \
)

$(eval $(call PyPackage,python-base))
$(eval $(call PyPackage,python-light))
$(eval $(call PyPackage,python))

$(eval $(call BuildPackage,python-pip-conf))

$(eval $(call BuildPackage,python-base))
$(eval $(call BuildPackage,python-light))
$(eval $(call BuildPackage,python))
