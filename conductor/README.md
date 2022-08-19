# Conductor

- [Conductor](#conductor)
  - [Quick reference](#quick-reference)
  - [What is Conductor?](#what-is-conductor)
  - [Why does this repository exist?](#why-does-this-repository-exist)
  - [How to use](#how-to-use)

## Quick reference

- Maintained by [Kien Nguyen-Tuan](https://github.com/ntk148v)

## What is Conductor?

- Conductor is a platform created by Netflix to orchestrate workflows that span across microservices.

![conductor](https://raw.githubusercontent.com/Netflix/conductor/main/docs/docs/img/logo.png)

- [Conductor's documentation](http://conductor.netflix.com/).

## Why does this repository exist?

- Netflix Conductor has Dockerfiles for building but I can't find any images in Docker Hub.
- Therefore, I create this repository which leverages Github action to check and build Conductor's image.
- Checkout [build script](https://github.com/ntk148v/dockerfiles/blob/master/conductor/build-images.sh).

## How to use

- There are three images:
  - netflix-conductor-server
  - netflix-conductor-ui
  - netflix-conductor-aio
- Check the [sample compose files](https://github.com/ntk148v/dockerfiles/tree/master/conductor).
- By default `docker-compose.yaml` uses `config-local.properties`. This configures the `memory` database, where data is lost when the server terminates. This configuration is useful for testing or demo only.
- A selection of `docker-compose-*.yaml` and `config-*.properties` files are provided demonstrating the use of alternative persistence engines.

| File                           | Containers                                                                                                 |
| ------------------------------ | ---------------------------------------------------------------------------------------------------------- |
| docker-compose.yaml            | <ol><li>In Memory Conductor Server</li><li>Elasticsearch</li><li>UI</li></ol>                              |
| docker-compose-dynomite.yaml   | <ol><li>Conductor Server</li><li>Elasticsearch</li><li>UI</li><li>Dynomite Redis for persistence</li></ol> |
| docker-compose-postgres.yaml   | <ol><li>Conductor Server</li><li>Elasticsearch</li><li>UI</li><li>Postgres persistence</li></ol>           |
| docker-compose-prometheus.yaml | Brings up Prometheus server                                                                                |

- For example this will start the server instance backed by a PostgreSQL DB.

```bash
docker-compose -f docker-compose.yaml -f docker-compose-postgres.yaml up
```

- You can follow [Conductor's getting started](https://conductor.netflix.com/gettingstarted/docker.html).
