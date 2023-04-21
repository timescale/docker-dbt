#!/usr/bin/env bash
#
# Given a version and adapter, builds a docker image for it locally.
# Useful for testing changes to images without pushing them to ghcr (note that
# you may need to comment out the logic in dbt-server that pulls the images on
# startup, if images for the specified adapter/version already exist in gchr).

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASE_DIR=${SCRIPT_DIR}/..

version=$1
adapter=$2

"${SCRIPT_DIR}"/generate_requirements.sh "${version}" "${adapter}"

docker build \
    --build-arg DBT_VERSION="${version}" \
    --build-arg DBT_ADAPTER="${adapter}" \
    --tag "ghcr.io/popsql/dbt-${adapter}:${version}" \
    "${BASE_DIR}"
