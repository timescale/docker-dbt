#!/usr/bin/env bash

# Given a version and adapter, generate the requirements.txt file for it within
# the ./requirements/${version} folder

set -e

cleanup() {
  if [ -n "${tmpdir}" ]; then
    rm -rf "${tmpdir}"
  fi
}

trap cleanup INT TERM EXIT

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASE_REQUIREMENTS_DIR=${SCRIPT_DIR}/../requirements

version=$1
adapter=$2

requirements_dir="${BASE_REQUIREMENTS_DIR}/${version}"

if [ ! -d "${requirements_dir}" ]; then
  echo "Version ${version} not found"
  exit 1
fi

if grep -Fxq "$adapter" "${requirements_dir}/${version}/pyproject.toml"; then
  echo "Adapter ${adapter} for ${version} not found"
  exit 1
fi

echo "Building requirements for ${version}/${adapter}"

tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'docker-dbt')
# note, we break ${adapter} out of the single quotes into its own double
# quotes section, as we want it to be expanded, but we also don't want
# bash expansion on the other parts of the string
perl -p -e 's/^dbt-(?!core|'"${adapter}"'|rpc).*\n$//' "${requirements_dir}"/pyproject.toml > "${tmpdir}"/pyproject.toml
cp "${requirements_dir}"/poetry.lock "${tmpdir}"/poetry.lock
pushd "${tmpdir}" > /dev/null
poetry -q lock
poetry export -o "${requirements_dir}/requirements-${adapter}".txt
popd > /dev/null
rm -rf "${tmpdir}"
