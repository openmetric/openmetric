image-exists-base:
	@docker inspect openmetric/base:centos >/dev/null
build-image-base:
	docker build -t openmetric/base:centos -f dockerfiles/base/Dockerfile .

build-image-tools:
	docker build -t openmetric/tools:latest -f dockerfiles/tools/Dockerfile .

build-image-go-carbon: image-exists-base
	docker build -t openmetric/go-carbon:latest -f dockerfiles/go-carbon/Dockerfile .

build-image-carbon-c-relay: image-exists-base
	docker build -t openmetric/carbon-c-relay:latest -f dockerfiles/carbon-c-relay/Dockerfile .

build-image-carbonapi: image-exists-base
	docker build -t openmetric/carbonapi:latest -f dockerfiles/carbonapi/Dockerfile .

build-image-grafana: image-exists-base
	docker build -t openmetric/grafana:latest -f dockerfiles/grafana/Dockerfile .

build-image-all: build-image-base build-image-carbon-c-relay build-image-go-carbon build-image-carbonapi build-image-grafana build-image-tools

###################################################
image-exists-compiler:
	@docker inspect openmetric/compiler:latest >/dev/null
build-image-compiler:
	docker build -t openmetric/compiler:latest -f dockerfiles/compiler/Dockerfile .

compile-carbon-c-relay: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler carbon-c-relay master

compile-go-carbon: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler go-carbon v0.9.1

compile-carbonzipper: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler carbonzipper

compile-carbonapi: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler carbonapi

compile-grafana: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler grafana v4.1.2

compile-all: compile-carbon-c-relay compile-go-carbon compile-carbonzipper compile-carbonapi compile-grafana
