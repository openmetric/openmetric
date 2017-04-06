image-exists-base:
	@docker inspect openmetric/base:centos >/dev/null
build-image-base:
	docker build -t openmetric/base:centos -f dockerfiles/base/Dockerfile .

build-image-tools:
	docker build -t openmetric/tools:latest -f dockerfiles/tools/Dockerfile .

build-image-openmetric:
	docker build -t openmetric/openmetric:latest -f dockerfiles/openmetric/Dockerfile .

###################################################
image-exists-compiler:
	@docker inspect openmetric/compiler:latest >/dev/null
build-image-compiler:
	docker build -t openmetric/compiler:latest -f dockerfiles/compiler/Dockerfile .

compile-carbon-c-relay: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler carbon-c-relay v2.6

compile-go-carbon: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler go-carbon v0.9.1

compile-carbonzipper: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler carbonzipper openmetric

compile-carbonapi: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler carbonapi openmetric

compile-all: compile-carbon-c-relay compile-go-carbon compile-carbonzipper compile-carbonapi
