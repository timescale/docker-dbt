#!/usr/bin/env bash

if [ -n "${DBT_PROFILES}" ]; then
  echo "${DBT_PROFILES}" > /.dbt/profiles.yml
elif [ -f ~/.dbt/profiles.yml ]; then
  cp ~/.dbt/profiles.yml /.dbt/profiles.yml
fi

if [ -n "${AWS_CREDENTIALS}" ]; then
  echo "${AWS_CREDENTIALS}" > /.dbt/aws_credentials
elif [ -f ~/.aws/credentials ]; then
  cp ~/.aws/credentials /.dbt/aws_credentials
fi

if [ -n "${BQ_KEYFILE}" ]; then
  echo "${BQ_KEYFILE}" > /.dbt/bq_keyfile.json
fi

exec "$@"
