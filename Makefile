image-exists-base:
	@docker inspect openmetric/base:centos >/dev/null
build-image-base:
	docker build -t openmetric/base:centos -f dockerfiles/base/Dockerfile .

build-image-tools:
	docker build -t openmetric/tools:latest -f dockerfiles/tools/Dockerfile .

build-image-openmetric:
	docker build -t openmetric/openmetric:latest -f dockerfiles/openmetric/Dockerfile .
