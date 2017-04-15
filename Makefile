BUILD_DATE = $(shell date "+%Y%m%d")
LOCAL_APK_MIRROR = https://mirrors.ustc.edu.cn/alpine/v3.5/main

CARBON_C_RELAY_VERSION = v3.0
GO_CARBON_VERSION = $(shell git ls-remote https://github.com/lomik/go-carbon HEAD | awk '{print substr($$1, 0, 7)}')
CARBONZIPPER_VERSION = $(shell git ls-remote https://github.com/go-graphite/carbonzipper HEAD | awk '{print substr($$1, 0, 7)}')
CARBONAPI_VERSION = $(shell git ls-remote https://github.com/go-graphite/carbonapi HEAD | awk '{print substr($$1, 0, 7)}')

build-carbon-c-relay:
	docker build \
		--build-arg LOCAL_APK_MIRROR=$(LOCAL_APK_MIRROR) \
		--build-arg CARBON_C_RELAY_VERSION=$(CARBON_C_RELAY_VERSION) \
		-t openmetric/carbon-c-relay:$(BUILD_DATE)-$(CARBON_C_RELAY_VERSION) \
		dockerfiles/graphite-stack/
	docker tag openmetric/carbon-c-relay:$(BUILD_DATE)-$(CARBON_C_RELAY_VERSION) openmetric/carbon-c-relay:latest

build-go-carbon:
	docker build \
		--build-arg LOCAL_APK_MIRROR=$(LOCAL_APK_MIRROR) \
		--build-arg GO_CARBON_VERSION=$(GO_CARBON_VERSION) \
		-t openmetric/go-carbon:$(BUILD_DATE)-$(GO_CARBON_VERSION) \
		dockerfiles/graphite-stack/
	docker tag openmetric/go-carbon:$(BUILD_DATE)-$(GO_CARBON_VERSION) openmetric/go-carbon:latest

build-carbonzipper:
	docker build \
		--build-arg LOCAL_APK_MIRROR=$(LOCAL_APK_MIRROR) \
		--build-arg CARBONZIPPER_VERSION=$(CARBONZIPPER_VERSION) \
		-t openmetric/carbonzipper:$(BUILD_DATE)-$(CARBONZIPPER_VERSION) \
		dockerfiles/graphite-stack/
	docker tag openmetric/carbonzipper:$(BUILD_DATE)-$(CARBONZIPPER_VERSION) openmetric/carbonzipper:latest

build-carbonapi:
	docker build \
		--build-arg LOCAL_APK_MIRROR=$(LOCAL_APK_MIRROR) \
		--build-arg CARBONAPI_VERSION=$(CARBONAPI_VERSION) \
		-t openmetric/carbonapi:$(BUILD_DATE)-$(CARBONAPI_VERSION) \
		dockerfiles/graphite-stack/
	docker tag openmetric/carbonapi:$(BUILD_DATE)-$(CARBONAPI_VERSION) openmetric/carbonapi:latest

build-all: build-carbon-c-relay build-go-carbon build-carbonzipper build-carbonapi

image-exists-base:
	@docker inspect openmetric/base:centos >/dev/null
build-image-base:
	docker build -t openmetric/base:centos -f dockerfiles/base/Dockerfile .

build-image-tools:
	docker build -t openmetric/tools:latest -f dockerfiles/tools/Dockerfile .

build-image-openmetric:
	docker build -t openmetric/openmetric:latest -f dockerfiles/openmetric/Dockerfile .
