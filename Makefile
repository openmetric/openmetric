BUILD_DATE = $(shell date "+%Y%m%d")
LOCAL_APK_MIRROR = https://mirrors.ustc.edu.cn/alpine/
LOCAL_NPM_MIRROR = https://registry.npm.taobao.org
LOCAL_NPM_DISTURL_MIRROR = https://npm.taobao.org/dist

CARBON_C_RELAY_VERSION = v3.0
GO_CARBON_VERSION = $(shell git ls-remote https://github.com/lomik/go-carbon HEAD | awk '{print substr($$1, 0, 7)}')
CARBONZIPPER_VERSION = $(shell git ls-remote https://github.com/go-graphite/carbonzipper HEAD | awk '{print substr($$1, 0, 7)}')
CARBONAPI_VERSION = $(shell git ls-remote https://github.com/go-graphite/carbonapi HEAD | awk '{print substr($$1, 0, 7)}')
GRAFANA_VERSION = v4.1.2
WHISPER_VERSION = 1.0.0
CARBONATE_VERSION = 1.0.0

build-carbon-c-relay:
	docker build \
		--build-arg IMAGE_TYPE=carbon-c-relay \
		--build-arg LOCAL_APK_MIRROR=$(LOCAL_APK_MIRROR) \
		--build-arg CARBON_C_RELAY_VERSION=$(CARBON_C_RELAY_VERSION) \
		-t openmetric/carbon-c-relay:$(CARBON_C_RELAY_VERSION) \
		-t openmetric/carbon-c-relay:latest \
		dockerfiles/graphite-stack/

build-go-carbon:
	docker build \
		--build-arg IMAGE_TYPE=go-carbon \
		--build-arg LOCAL_APK_MIRROR=$(LOCAL_APK_MIRROR) \
		--build-arg GO_CARBON_VERSION=$(GO_CARBON_VERSION) \
		-t openmetric/go-carbon:$(GO_CARBON_VERSION) \
		-t openmetric/go-carbon:latest \
		dockerfiles/graphite-stack/

build-carbonzipper:
	docker build \
		--build-arg IMAGE_TYPE=carbonzipper \
		--build-arg LOCAL_APK_MIRROR=$(LOCAL_APK_MIRROR) \
		--build-arg CARBONZIPPER_VERSION=$(CARBONZIPPER_VERSION) \
		-t openmetric/carbonzipper:$(CARBONZIPPER_VERSION) \
		-t openmetric/carbonzipper:latest \
		dockerfiles/graphite-stack/

build-carbonapi:
	docker build \
		--build-arg IMAGE_TYPE=carbonapi \
		--build-arg LOCAL_APK_MIRROR=$(LOCAL_APK_MIRROR) \
		--build-arg CARBONAPI_VERSION=$(CARBONAPI_VERSION) \
		-t openmetric/carbonapi:$(CARBONAPI_VERSION) \
		-t openmetric/carbonapi:latest \
		dockerfiles/graphite-stack/

build-grafana:
	docker build \
		--build-arg IMAGE_TYPE=grafana \
		--build-arg LOCAL_APK_MIRROR=$(LOCAL_APK_MIRROR) \
		--build-arg LOCAL_NPM_MIRROR=$(LOCAL_NPM_MIRROR) \
		--build-arg LOCAL_NPM_DISTURL_MIRROR=$(LOCAL_NPM_DISTURL_MIRROR) \
		--build-arg GRAFANA_VERSION=$(GRAFANA_VERSION) \
		-t openmetric/grafana:$(GRAFANA_VERSION) \
		-t openmetric/grafana:latest \
		dockerfiles/graphite-stack/

build-tools:
	docker build \
		--build-arg IMAGE_TYPE=tools \
		--build-arg LOCAL_APK_MIRROR=$(LOCAL_APK_MIRROR) \
		--build-arg WHISPER_VERSION=$(WHISPER_VERSION) \
		--build-arg CARBONATE_VERSION=$(CARBONATE_VERSION) \
		-t openmetric/tools:$(BUILD_DATE) \
		-t openmetric/tools:latest \
		dockerfiles/graphite-stack/
