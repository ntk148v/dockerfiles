# Conductor

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
- You can follow [Conductor's getting started](https://conductor.netflix.com/gettingstarted/docker.html).

## Sample compose files

- **WIP**
