# `popsql/dbt` docker images

This repo contains the code for generating our dbt Docker images, which are located on
the GitHub container registry.

Based off of the official python image, we then add:

- `dbt-core`
- `dbt-rpc`
- one of the `dbt` adapters (e.g. `dbt-postgres`)

Where each image is available for dbt 0.19 onward.

## Use

Images are published to the GitHub container registry.

```bash
docker pull ghcr.io/popsql/dbt-${ADAPTER}:${VERSION}
```

## Development

The repo is structured such that under the `./requirements` folder, there is a folder
that contains each version of dbt we support. Within each folder, there is then
`pyproject.toml` and `poetry.lock` files. Within each `pyproject.toml`, there is then
the list of adapters we support for that given version, along with the shared
dependencies (e.g. `dbt-core` and `dbt-rpc`). After changing something within the
`pyproject.toml` file, you will need to run `poetry lock` to update the `poetry.lock`
file.

As part of our CD process, we then handle generating a per adapter requirements file
from these two files.

## Docker Platforms

Most of the produced images should support the following platforms:

- linux/amd64
- linux/arm64

Some images may not have a `linux/arm64` target if building for it is not possible, or very ardous.
For example, `dbt-snowflake <= 1.1` requires building pyarrow from source which requires a bunch of
additional packages and time, so we only have `linux/amd64` platforms available there.

The information on which platforms to build for a given image is captured within our `deploy.yml`
CD script.
