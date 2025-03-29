#!/bin/env make -f

PACKAGE = $(shell basename $(shell pwd))
VERSION = $(shell bash scripts/set-version)

MAINTAINER = $(shell git config user.name) <$(shell git config user.email)>

INSTALL = plasma-desktop
BUILD = debhelper (>= 11), git, make (>= 4.1), dpkg-dev

HOMEPAGE = https://github.com/MichaelSchaecher/$(PACKAGE)

PACKAGE_DIR = package

ARCH = $(shell dpkg --print-architecture)

export PACKAGE_DIR PACKAGE VERSION MAINTAINER INSTALL BUILD HOMEPAGE ARCH

# Phony targets
.PHONY: all debian clean help

# Default target
all: debian

debian:

	@echo "Building package $(PACKAGE) version $(VERSION)"

	@echo "$(VERSION)" > $(PACKAGE_DIR)/usr/share/doc/$(PACKAGE)/version

	@scripts/set-control
	@scripts/sum

	@dpkg-changelog $(PACKAGE_DIR)/DEBIAN/changelog
	@dpkg-changelog $(PACKAGE_DIR)/usr/share/doc/$(PACKAGE)/changelog
	@gzip -d $(PACKAGE_DIR)/DEBIAN/*.gz
	@mv $(PACKAGE_DIR)/DEBIAN/changelog.DEBIAN $(PACKAGE_DIR)/DEBIAN/changelog

	@scripts/mkdeb

install:

	@dpkg -i $(PACKAGE)_$(VERSION)_$(ARCH).deb

clean:
	@rm -vf $(PACKAGE_DIR)/DEBIAN/control \
		$(PACKAGE_DIR)/DEBIAN/changelog \
		$(PACKAGE_DIR)/DEBIAN/md5sums \
		$(PACKAGE_DIR)/usr/share/doc/$(PACKAGE)/*.gz

help:
	@echo "Usage: make [target] <variables>"
	@echo ""
	@echo "Targets:"
	@echo "  all       - Build the debian package and install it"
	@echo "  debian    - Build the debian package"
	@echo "  install   - Install the debian package"
	@echo "  clean     - Clean up build files"
	@echo "  help      - Display this help message"
	@echo ""
