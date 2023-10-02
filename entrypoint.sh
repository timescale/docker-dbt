#!/usr/bin/env bash

if [ ! -z "${DBT_PROFILES}" ]; then
  echo "${DBT_PROFILES}" > /.dbt/profiles.yml
elif [ -f ~/.dbt/profiles.yml ]; then
  cp ~/.dbt/profiles.yml /.dbt/profiles.yml
fi

if [ ! -z "${AWS_CREDENTIALS}" ]; then
  echo "${AWS_CREDENTIALS}" > /.dbt/aws_credentials
elif [ -f ~/.aws/credentials ]; then
  cp ~/.aws/credentials /.dbt/aws_credentials
fi

if [ ! -z "${BQ_KEYFILE}" ]; then
  echo "${BQ_KEYFILE}" > /.dbt/bq_keyfile.json
elif [ -f ~/.dbt/keyfile.json ]; then
  cp ~/.dbt/bq_keyfile.json /.dbt/bq_keyfile.json
fi

exec "$@"
