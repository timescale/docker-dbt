#!/usr/bin/env bash

set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
BASE_REQUIREMENTS_DIR=${SCRIPT_DIR}/../requirements

# shellcheck disable=SC2207
versions=($(ls -1A "${BASE_REQUIREMENTS_DIR}"))
echo -n '{"include": ['
for i in "${!versions[@]}"; do
  version=${versions[$i]}
  if [ "${i}" -gt 0 ]; then
    echo -n ', '
  fi

  echo -n "{\"version\": \"${version}\", \"adapter\": \"\"}"

  requirements_dir="${BASE_REQUIREMENTS_DIR}/${version}"
  # shellcheck disable=SC2207
  adapters=($(grep "^dbt-*" "${requirements_dir}"/pyproject.toml | grep -v "core" | grep -v "rpc" | perl -p -e 's/^dbt-([a-z0-9]*).*$/\1/'))
  for j in "${!adapters[@]}"; do
    adapter=${adapters[$j]}
    echo -n ",{\"version\": \"${version}\", \"adapter\": \"${adapter}\"}"
  done
done

echo -n ']}'
