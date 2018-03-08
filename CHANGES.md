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

**0.2 (2018.03.08)**

Components Versions:

| components | version | note |
| :---       | :---    | ---  |
| carbon-c-relay | [v3.2](https://github.com/grobian/carbon-c-relay/tree/v3.2) | |
| go-carbon      | [v0.12.0-rc1](https://github.com/lomik/go-carbon/tree/v0.12.0-rc1) | |
| carbonapi      | [v0.10.0.1](https://github.com/go-graphite/tree/v0.10.0.1) | |
| grafana        | [v5.0.0](https://github.com/grafana/grafana/tree/v5.0.0) | Since phantomjs does not provide pre-built binary for alpine, phantomjs is removed, thus 'Direct link rendered image' won't work. |
| whisper        | [1.1.2](https://github.com/graphite-project/whisper/tree/1.1.2) | |
| carbonate      | [1.1.2](https://github.com/graphite-project/carbonate/tree/1.1.2) | |

Changes and Notes:

  - Build (possibly daily) `:edge` images with components' latest code.
  - Build remove carbonzipper, it has been builtin into carbonapi.

**0.1 (2017.04.17)**

Components Versions:

| components | version | note |
| :---       | :---    | ---  |
| carbon-c-relay | [v3.0](https://github.com/grobian/carbon-c-relay/tree/v3.0) |  |
| go-carbon      | [017dfeb](https://github.com/lomik/go-carbon/tree/017dfeb) | The latest tagged version of carbonzipper requires protobuf3 support, however latest tagged version of [v0.9.1](https://github.com/lomik/go-carbon/tree/v0.9.1) does not support protobuf3. |
| carbonzipper   | [0.63](https://github.com/go-graphite/carbonzipper/tree/0.63) | |
| carbonapi      | [8684aa1](https://github.com/go-graphite/tree/8684aa1) | The latest tagged version [0.7.0](https://github.com/go-graphite/carbonapi/tree/0.7.0) does not support settings internal metric prefix. |
| grafana        | [v4.1.2](https://github.com/grafana/grafana/tree/v4.1.2) | Since phantomjs does not provide pre-built binary for alpine, phantomjs is removed, thus 'Direct link rendered image' won't work. |
| whisper        | [1.0.0](https://github.com/graphite-project/whisper/tree/1.0.0) | |
| carbonate      | [1.0.0](https://github.com/graphite-project/carbonate/tree/1.0.0) | |

Changes and Notes:

  - Provides a quickstart [docker-compose.yml](https://github.com/openmetric/openmetric/blob/0.1/quickstart/docker-compose.yml)
    and configurations, can be used to deploy on a single server, for small scale production use.
