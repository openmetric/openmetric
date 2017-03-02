image-exists-compiler:
	@docker inspect openmetric/compiler:latest >/dev/null

build-image-compiler:
	docker build -t openmetric/compiler:latest -f dockerfiles/compiler/Dockerfile .


build-image-go-carbon:
	docker build -t openmetric/go-carbon:latest -f dockerfiles/go-carbon/Dockerfile .

build-image-carbon-c-relay:
	docker build -t openmetric/carbon-c-relay:latest -f dockerfiles/carbon-c-relay/Dockerfile .

build-image-carbonapi:
	docker build -t openmetric/carbonapi:latest -f dockerfiles/carbonapi/Dockerfile .


compile-carbon-c-relay: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler carbon-c-relay v2.6

compile-go-carbon: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler go-carbon v0.9.1

compile-carbonzipper: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler carbonzipper

compile-carbonapi: image-exists-compiler
	docker run -it --rm -v ${PWD}/binary:/binary openmetric/compiler carbonapi

compile-all: compile-carbon-c-relay compile-go-carbon compile-carbonzipper compile-carbonapi
