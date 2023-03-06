#!/usr/bin/env bash

set -e

cleanup() {
  if [ -n "${tmpdir}" ]; then
    rm -rf "${tmpdir}"
  fi
}

trap cleanup INT TERM EXIT

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REQUIREMENTS_DIR=${SCRIPT_DIR}/../requirements

ADAPTERS=(bigquery postgres snowflake redshift)

for adapter in "${ADAPTERS[@]}"; do
  echo "Generating requirements for ${adapter}"
  tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'docker-dbt')
  # note, we break ${adapter} out of the single quotes into its own double
  # quotes section, as we want it to be expanded, but we also don't want
  # bash expansion on the other parts of the string
  perl -p -e 's/^dbt-(?!core|'"${adapter}"'|rpc).*\n$//' "${REQUIREMENTS_DIR}"/pyproject.toml > "${tmpdir}"/pyproject.toml
  cp "${REQUIREMENTS_DIR}"/poetry.lock "${tmpdir}"/poetry.lock
  pushd "${tmpdir}" > /dev/null
  poetry -q lock
  poetry export -o "${REQUIREMENTS_DIR}"/requirements-"${adapter}".txt
  popd > /dev/null
  rm -rf "${tmpdir}"
done
