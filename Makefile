.PHONY: all print build xserver start start-vnc attach start-raw start-notebook \
	start-devcontainer push pull rm

all: print

PDK=ihp-sg13g2
SHARED_DIR=$(abspath ./shared_xserver)

#Based on https://stackoverflow.com/a/70663753
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

ifeq (,$(WEBSERVER_PORT))
WEBSERVER_PORT=80
endif

ifeq (,$(VNC_PORT))
VNC_PORT=5901
endif

ifeq (,$(JUPYTER_PORT))
JUPYTER_PORT=8888
endif

ifeq (,$(DOCKER_USER))
DOCKER_USER=isaiassh
endif

ifeq (,$(DOCKER_IMAGE))
DOCKER_IMAGE=unic-cass-tools
endif

ifeq (,$(DOCKER_TAG))
ifneq (,$(ENABLE_GUI))
DOCKER_TAG=1.2.3_vnc
else
DOCKER_TAG=1.2.3
endif
endif

DOCKER_IMAGE_TAG=$(DOCKER_USER)/$(DOCKER_IMAGE):$(DOCKER_TAG)

ifneq (,$(ROOT))
_DOCKER_ROOT_USER=--user root
endif

ifneq (,$(NO_CACHE))
_DOCKER_NO_CACHE=--no-cache
endif

# Windows Specific Configuration
################################
ifeq (Windows_NT,$(OS))

SHARED_DIR_HASH := $(shell echo | set /p="$(SHARED_DIR)" > %TMP%/hash.txt | certutil -hashfile %TMP%/hash.txt SHA256 | findstr /v "hash")
CONTAINER_NAME  := unic-cass-tools-$(SHARED_DIR_HASH)
CONTAINER_ID    := $(shell docker container ls -a -q -f "name=$(CONTAINER_NAME)")

USER_ID=1000
USER_GROUP=1000
DOCKER_RUN=docker run -it $(_DOCKER_ROOT_USER) \
	--mount type=bind,source=$(SHARED_DIR),target=/home/designer/shared \
	--user $(USER_ID):$(USER_GROUP) \
	-e SHELL=/bin/bash \
	-e PDK=$(PDK) \
	-e DISPLAY=host.docker.internal:0 \
	-e LIBGL_ALWAYS_INDIRECT=1 \
	-e XDG_RUNTIME_DIR \
	-e PULSE_SERVER \
	-p $(JUPYTER_PORT):8888 \
	--name $(CONTAINER_NAME)

_XSERVER_EXISTS := $(shell powershell -noprofile Get-Process vcxsrv -ErrorAction SilentlyContinue)
START_XSERVER   := powershell -ExecutionPolicy Bypass -File "$(CURDIR)/start_vcxsrv.ps1"

else

UNAME_S := $(shell uname -s)
USER_ID=$(shell id -u)
USER_GROUP=$(shell id -g)

# Linux Specific Configuration
##############################
ifeq (Linux,$(UNAME_S))

SHARED_DIR_HASH := $(shell echo -n $(SHARED_DIR) | md5sum | awk '{print $$1}')
CONTAINER_NAME  := unic-cass-tools-$(SHARED_DIR_HASH)
CONTAINER_ID    := $(shell docker container ls -a -q -f "name=$(CONTAINER_NAME)")

# Detect XAUTHORITY location - use environment variable if set, otherwise try common locations
# Check multiple possible locations and use the first one that exists
XAUTHORITY_HOST := $(shell if [ -n "$$XAUTHORITY" ] && [ -f "$$XAUTHORITY" ]; then echo "$$XAUTHORITY"; elif [ -f "$$HOME/.Xauthority" ]; then echo "$$HOME/.Xauthority"; elif [ -f "/home/$(USER)/.Xauthority" ]; then echo "/home/$(USER)/.Xauthority"; fi)
XAUTHORITY_CONTAINER := /tmp/.Xauthority

# Build XAUTHORITY mount option only if file exists
XAUTHORITY_MOUNT := $(if $(XAUTHORITY_HOST),-v $(XAUTHORITY_HOST):$(XAUTHORITY_CONTAINER):rw,)

# Build XAUTHORITY environment variable only if mount exists
XAUTHORITY_ENV := $(if $(XAUTHORITY_HOST),-e XAUTHORITY=$(XAUTHORITY_CONTAINER),)

# Since it uses local xserver, --net=host is required and DISPLAY should be equal to host

DOCKER_RUN=docker run -it $(_DOCKER_ROOT_USER) \
	--mount type=bind,source=$(SHARED_DIR),target=/home/designer/shared \
	-v /tmp/.X11-unix:/tmp/.X11-unix:ro \
	$(XAUTHORITY_MOUNT) \
	--net=host \
	-e SHELL=/bin/bash \
	-e PDK=$(PDK) \
	-e DISPLAY=$(DISPLAY) \
	$(XAUTHORITY_ENV) \
	-e LIBGL_ALWAYS_INDIRECT=1 \
	-e XDG_RUNTIME_DIR=/tmp/runtime-default \
	-e PULSE_SERVER \
	-e USER_ID=$(USER_ID) \
	-e USER_GROUP=$(USER_GROUP) \
	--device=/dev/dri:/dev/dri \
	-p $(VNC_PORT):5901 \
	-p $(WEBSERVER_PORT):80 \
	--name $(CONTAINER_NAME) 

# _XSERVER_EXISTS and START_XSERVER are not required

DOCKER_RUN_VNC=docker run -d $(_DOCKER_ROOT_USER) \
	--mount type=bind,source=$(SHARED_DIR),target=/home/designer/shared \
	-e SHELL=/bin/bash \
	-e PDK=$(PDK) \
	-e DISPLAY=:1 \
	-e USER_ID=$(USER_ID) \
	-e USER_GROUP=$(USER_GROUP) \
	-p $(JUPYTER_PORT):8888 \
	-p $(VNC_PORT):5901 \
	-p $(WEBSERVER_PORT):80 \
	--name $(CONTAINER_NAME)

endif

# Mac Specific Configuration
############################
ifeq (Darwin,$(UNAME_S))

DOCKER_RUN=docker run -it --rm $(_DOCKER_ROOT_USER) \
	--mount type=bind,source=$(SHARED_DIR),target=/home/designer/shared \
	-e SHELL=/bin/bash \
	-e PDK=$(PDK) \
	-e DISPLAY=host.docker.internal:0 \
	-e LIBGL_ALWAYS_INDIRECT=1 \
	-e XDG_RUNTIME_DIR \
	-e PULSE_SERVER \
	-e USER_ID=$(USER_ID) \
	-e USER_GROUP=$(USER_GROUP) \
	-p 8888:8888

# _XSERVER_EXISTS:=$(shell ?)
# START_XSERVER=xquartz ... ?

endif # Linux/Mac differenciation
endif # Windows differenciation


########################
# Docker Image Commands
########################


print:
	@echo DOCKER_IMAGE_TAG ........ $(DOCKER_IMAGE_TAG)
	@echo DEV ..................... $(DEV)
	@echo SHARED_DIR .............. $(SHARED_DIR)
	@echo CONTAINER_NAME........... $(CONTAINER_NAME)
	@echo CONTAINER_ID............. $(CONTAINER_ID)
	@echo OS ...................... $(OS)
	@echo UNAME_S ................. $(UNAME_S)
	@echo STAGE ................... $(STAGE)
	@echo CACHE ................... $(_DOCKER_NO_CACHE)
	@echo _DOCKER_ROOT_USER ....... $(_DOCKER_ROOT_USER)
	@echo _XSERVER_EXISTS ......... $(_XSERVER_EXISTS)
	@echo DOCKER_RUN .............. $(DOCKER_RUN)


build:
ifeq (,$(STAGE))
	DOCKER_USER="$(DOCKER_USER)" DOCKER_IMAGE="$(DOCKER_IMAGE)" DOCKER_TAG="$(DOCKER_TAG)" ENABLE_GUI="$(ENABLE_GUI)" MAX_BUILD_JOBS="$(MAX_BUILD_JOBS)" NO_CACHE="$(NO_CACHE)" ./build/build-image.sh
else
	DOCKER_USER="$(DOCKER_USER)" DOCKER_IMAGE="$(DOCKER_IMAGE)" DOCKER_TAG="$(DOCKER_TAG)" ENABLE_GUI="$(ENABLE_GUI)" MAX_BUILD_JOBS="$(MAX_BUILD_JOBS)" NO_CACHE="$(NO_CACHE)" ./build/build-stage.sh "$(STAGE)"
endif


xserver:
ifeq (Windows_NT,$(OS))
	@powershell -NoProfile -Command "if (-not (Get-Process vcxsrv -ErrorAction SilentlyContinue)) { Start-Process -FilePath 'C:\Program Files\VcXsrv\vcxsrv.exe' -ArgumentList ':0 -multiwindow -clipboard -primary -wgl' } else { Write-Host 'VcXsrv is already running.' }"
else
ifeq (,$(_XSERVER_EXISTS))
	$(START_XSERVER)
endif
endif


start: xserver pull
	$(DOCKER_RUN) --rm $(DOCKER_IMAGE_TAG)

start-vnc:
	$(DOCKER_RUN_VNC) $(DOCKER_IMAGE_TAG) --vnc --wait


attach: xserver pull
ifeq (,$(CONTAINER_ID))
	$(DOCKER_RUN) $(DOCKER_IMAGE_TAG)
else
	docker container start -ai $(CONTAINER_ID)
endif


start-raw:
	docker run -it --rm $(_DOCKER_ROOT_USER) $(DOCKER_IMAGE_TAG)


# Some flags that might be useful
# --NotebookApp.password=''
# --KernelSpecManager.ensure_native_kernel=False
# --NotebookApp.allow_origin='*'

start-notebook: xserver pull
	$(DOCKER_RUN) $(DOCKER_IMAGE_TAG) "jupyter-lab --no-browser --notebook-dir=./shared --ip 0.0.0.0 --NotebookApp.token=''"


start-devcontainer: xserver pull
	code $(SHARED_DIR)


push:
	docker image push $(DOCKER_IMAGE_TAG)


pull:
ifeq (,$(NO_PULL))
ifeq (Windows_NT,$(OS))
	@docker image inspect $(DOCKER_IMAGE_TAG) >NUL 2>&1 || docker image pull $(DOCKER_IMAGE_TAG)
else
	@docker image inspect $(DOCKER_IMAGE_TAG) >/dev/null 2>&1 || docker image pull $(DOCKER_IMAGE_TAG)
endif
endif


rm:
ifneq (,$(CONTAINER_ID))
	docker container rm $(CONTAINER_ID)
endif
