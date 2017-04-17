Changes
===============

[Fix] - bugfix

**[Breaking]** - breaking changes

[Feature] - new feature

[Improvement] - non-breaking improvement

Upstream Change Links
----------------------

* carbon-c-relay: https://github.com/grobian/carbon-c-relay/blob/master/ChangeLog.md
* go-carbon: https://github.com/lomik/go-carbon#changelog
* carbonzipper: https://github.com/go-graphite/carbonzipper/blob/master/CHANGES.md
* carbonapi: https://github.com/go-graphite/carbonapi/blob/master/CHANGES.md
* grafana: https://github.com/grafana/grafana/blob/master/CHANGELOG.md
* whisper.py: (commits log) https://github.com/grafana/grafana/blob/master/CHANGELOG.md
* carbonate: https://github.com/graphite-project/carbonate/blob/master/CHANGELOG.md

Changes
----------

**Master (not released)**

**0.1 (2017.04.17)**
  - carbon-c-relay:v3.0.
  - go-carbon:[017dfeb](https://github.com/lomik/go-carbon/commit/017dfeb42c5451dcb0e03e8e464d5c8c1badb142) (current master).
    The latest tagged version of carbonzipper and carbonapi requires protobuf3 support,
    however latest tagged version of go-carbon (v0.9.1) does not support protobuf3.
  - carbonzipper:0.63.
  - carbonapi:[8684aa1](https://github.com/go-graphite/carbonapi/commit/8684aa1).
    The latest tagged version (0.7.0) does not support setting internal metric prefix.
  - grafana:v4.1.2. Since phantomjs does not provide pre-built binary for alpine, phantomjs is removed.
    'Direct link rendered image' won't work.
  - tools: whisper:1.0.0 and carbonate:1.0.0.
  - Provides a quickstart [docker-compose.yml](https://github.com/openmetric/openmetric/blob/0.1/quickstart/docker-compose.yml)
    and configurations, can be used to deploy on a single server, for small scale production use.
