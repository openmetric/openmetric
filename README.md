# About this project

Openmetric is a collection and combination of metric related tools (mainly the *graphite stack*),
we provide (and only provide) docker images to make the stack deployment easy.
In the long term, we will enhance the stack so it can scale more easily.

Currently, we choose the following components for the graphite stack:

* [carbon-c-relay](https://github.com/grobian/carbon-c-relay)
* [go-carbon](https://github.com/lomik/go-carbon)
* [carbonapi](https://github.com/go-graphite/carbonapi)
* [grafana](https://github.com/grafana/grafana)

# Docker images

A docker image is provided for each component, named as `openmetric/$component` .
Image version is based on upstream tag or sha (if build against a branch other than a tag).

The following images are available:

* `openmetric/carbon-c-relay`
* `openmetric/go-carbon`
* `openmetric/carbonapi`
* `openmetric/grafana`
* `openmetric/tools` This image contains several management tools, currently only
  [carbonate](https://github.com/graphite-project/carbonate) is included.

All images does not provide default configuration file, as these components depends on each other,
it's hard to provide sensible default configuration.

## Quick start

A quickstart docker compose file is provided, you can start the stack easily with:

```
docker-compose -f quickstart/docker-compose.yml up
```

`2003/tcp` is exposed to receive metrics in plain text protocol, and `5000/tcp` for api requests.

It's time to push metrics to the stack. Let's generate a series of random int values at 10s interval:

```
while true; do
  echo "test.random.int ${RANDOM} $(date +%s)"
  sleep 10
done | nc localhost 2003
```

You can now read the data though api interface:

```
curl 'http://localhost:5000/render/?target=test.random.int&format=json'
```

You can also try out grafana, browse http://localhost:3000 , login with `admin:admin` .

## Directory layout in images

To make it easy to maintain the containers, we try to make directory layout in a consistent way.

All runtime files (log, conf, data etc.) are all stored in ``/openmetric``, the layout is:

```
/openmetric/
  |- conf/
  |   |- relay.conf, carbon.conf, schemas.conf, api.yaml, grafana.conf
  |- data/
  |   |- whisper
  |   |- grafana
  |   |- grafana-plugins
```

## Development

All images are built using a single Dockerfile, controlled by build args,
see [Makefile](https://github.com/openmetric/openmetric/blob/master/Makefile) for details.

All images are built from alpine, so the images' size are significantly small.
In an environment without internet access and private docker registry, it's easy to save the image
and copy to production server.

## `:edge` images

All images with `:edge` tag are built with components' latest code. These images are meant to be used for testing purpose.

## Changes and versioning

Component images are versioned by upstream valid git ref, usually will be tags.

See [CHANGES.md](https://github.com/openmetric/openmetric/blob/master/CHANGES.md) for build scripts and other changes.
