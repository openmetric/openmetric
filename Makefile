BUILD_DATE = $(shell date "+%Y%m%d")

LOCAL_APK_MIRROR         ?= https://mirrors.ustc.edu.cn/alpine/
LOCAL_NPM_MIRROR         ?= https://registry.npm.taobao.org
LOCAL_NPM_DISTURL_MIRROR ?= https://npm.taobao.org/dist

CARBON_C_RELAY_VERSION   ?= $(if $(EDGE),edge,v3.2)
GO_CARBON_VERSION        ?= $(if $(EDGE),edge,v0.12.0-rc1)
CARBONAPI_VERSION        ?= $(if $(EDGE),edge,0.10.0.1)
GRAFANA_VERSION          ?= $(if $(EDGE),edge,v5.0.0)
WHISPER_VERSION          ?= $(if $(EDGE),edge,1.1.2)
CARBONATE_VERSION        ?= $(if $(EDGE),edge,1.1.2)
TOOLS_VERSION            ?= $(if $(EDGE),edge,$(BUILD_DATE))

MIRRORS    = APK NPM NPM_DISTURL
COMPONENTS = CARBON_C_RELAY GO_CARBON CARBONAPI GRAFANA WHISPER CARBONATE
IMAGES     = carbon-c-relay go-carbon carbonapi grafana tools

# if an image name is same as component name, use component's version for image tag, otherwise use build date
IMAGE_VERSION = $(or $($(shell echo $(IMAGE_TYPE) | tr a-z- A-Z_)_VERSION),$(BUILD_DATE))
TAGS          = openmetric/$(IMAGE_TYPE):$(IMAGE_VERSION) $(if $(LATEST),openmetric/$(IMAGE_TYPE):latest)

MIRROR_ARGS   = $(foreach m, $(MIRRORS), --build-arg LOCAL_$(m)_MIRROR=$(LOCAL_$(m)_MIRROR))
VERSION_ARGS  = $(foreach c, $(COMPONENTS), --build-arg $(c)_VERSION=$($(c)_VERSION))
TAG_ARGS      = $(foreach t, $(TAGS), -t $(t))
CACHE_ARGS    = $(if $(NOCACHE), --no-cache, )

.PHONY: help all $(IMAGES)
help:
	@echo "Usage:"
	@echo ""
	@echo "    make <image>|all [LATEST=1] [EDGE=1] [<COMPONENT>_VERSION=<VERSION>] [PUSH=1] [NOCACHE=1]"
	@echo "          <image>: specify image to build, available images: $(IMAGES)"
	@echo "              all: build all images"
	@echo "           LATEST: if defined, will also tag built image with ':latest'"
	@echo "             EDGE: if defined, will build with components' latest code (master branch)"
	@echo "          <COMPONENT>_VERSION: if specified, will build with this version, should be valid git ref"
	@echo "                               available components: $(COMPONENTS)"
	@echo "             PUSH: if defined, will run 'docker push' afterwards"
	@echo "          NOCACHE: if defined, will run 'docker build' with '--no-cache' option"

all: $(IMAGES)

$(IMAGES): IMAGE_TYPE = $@
$(IMAGES):
	docker build $(CACHE_ARGS) --build-arg IMAGE_TYPE=$(IMAGE_TYPE) $(MIRROR_ARGS) $(VERSION_ARGS) $(TAG_ARGS) .
	@if [ -n "$(PUSH)" ]; then for tag in $(TAGS); do docker push $$tag; done; fi
