# `popsql/dbt` docker images

This repo contains the Docker images we use for dbt.

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

The repo is structured such that we have a branch per supported dbt version. The branch names are
named as `${major}.${minor}` of a given dbt version. Any push to these branches will produce images
in the container registry for that version, with one image per supported adapter.

Within each branch, the file structure is that we have one Dockerfile that used by all adapters,
which dynamically then uses one of the `requirements.txt` files based on the passed in
`DBT_ADAPTER` build argument. These requirements files are generated via the
[poetry](https://python-poetry.org/) tool. The expected workflow is that you will edit the
`pyproject.toml` file, and then from within the `requirements` directory run:

```bash
poetry lock
../bin/generate_requirements.sh
```

This will generate a `requirements.txt` file per adapter, leaving off the dependencies for other
adapters.

## Targets

- linux/amd64
- linux/arm64
