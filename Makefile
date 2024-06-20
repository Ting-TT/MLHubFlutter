########################################################################
#
# Generic Makefile
#
# Time-stamp: <Saturday 2024-06-15 08:58:41 +1000 Graham Williams>
#
# Copyright (c) Graham.Williams@togaware.com
#
# License: Creative Commons Attribution-ShareAlike 4.0 International.
#
########################################################################

# App is often the current directory name.
#
# App version numbers
#   Major release
#   Minor update
#   Trivial update or bug fix

APP=$(shell pwd | xargs basename)
VER=
DATE=$(shell date +%Y-%m-%d)

# Identify a destination used by install.mk

DEST=/var/www/html/$(APP)

########################################################################
# Supported Makefile modules.

# Often the support Makefiles will be in the local support folder, or
# else installed in the local user's shares.

INC_BASE=$(HOME)/.local/share/make
INC_BASE=support

# Specific Makefiles will be loaded if they are found in
# INC_BASE. Sometimes the INC_BASE is shared by multiple local
# Makefiles and we want to skip specific makes. Simply define the
# appropriate INC to a non-existant location and it will be skipped.

INC_DOCKER=skip
INC_MLHUB=skip
INC_WEBCAM=skip

# Load any modules available.

INC_MODULE=$(INC_BASE)/modules.mk

ifneq ("$(wildcard $(INC_MODULE))","")
  include $(INC_MODULE)
endif

########################################################################
# HELP
#
# Help for targets defined in this Makefile.

define HELP
$(APP):

  local	     Install to $(HOME)/.local/share/$(APP)
  tgz	     Upload the installer to access.togaware.com

endef
export HELP

help::
	@echo "$$HELP"

########################################################################
# LOCAL TARGETS

# Install locally for linux.

local:
	tar zxvf installers/$(APP).tar.gz -C $(HOME)/.local/share/

# Upload to access.togaware.com.

tgz::
	chmod a+r installers/*.tar.gz
	rsync -avzh installers/*.tar.gz togaware.com:apps/access/
