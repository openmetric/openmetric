# About this project

Openmetric is a collection and combination of metric related tools (mainly the *graphite stack*),
we provide (and only provide) docker images to make the stack deployment easy.
In the long term, we will enhance the stack so it can scale more easily.

# Docker images

Currently only a graphite-stack image is provided.

**openmetric/graphite-stack** uses third-party implementation written in golang and C to replace the official one.
Currently they are
[carbon-c-relay](https://github.com/grobian/carbon-c-relay),
[go-carbon](https://github.com/lomik/go-carbon),
[carbonzipper](https://github.com/dgryski/carbonzipper),
[carbonapi](https://github.com/dgryski/carbonapi),

## Quick start

Start an openmetric instance:

```
docker run -d --name openmetric -p 2003:2003 -p 5000:5000 openmetric/graphite-stack standalone
```

carbon-c-relay by default listens on port 2003, receives metrics in plain text protocol.
carbonapi listens on port 5000, provides metric rendering api.

It's time to push metrics to openmetric. Let's generate a series of random int values at 10s interval:

```
while true; do
  echo "test.random.int ${RANDOM} $(date +%s)"
done | nc openmetric-host 2003
```

You can now read the data though api interface:

```
curl 'http://openmetric-host:5000/render/?target=test.random.int&format=json'
```

## Directory layout in images

To make it easy to maintain the containers, we try to make directory layout in a consistent way.

All runtime files (log, conf, data etc.) are all stored in ``/openmetric``, the layout is:

```
/openmetric/
  |- conf/
      |- relay.conf, carbon.conf, schemas.conf, zipper.conf
  |- log/
      |- relay.log, carbon.log, zipper.log, api.log, supervisord.log
  |- data/
      |- whisper
```

Although we provided a default set of configuration files, you are always encouraged to provide your own.

Runnable binaries, scripts, libraries are installed in the system location (i.e. ``/usr/bin``),
so there will be less problems with ``PATH`` env.


# Develop

## Build docker images

Since these images share common directories to `COPY` from, all `docker build` command should be run in the project root directory.
For example:

```
docker build -t openmetric/compiler -f dockerfiles/compiler .
```
