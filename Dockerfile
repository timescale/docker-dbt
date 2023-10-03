FROM python:3.8-slim-bullseye

ENV DBT_PROFILES_DIR=/.dbt
ENV AWS_SHARED_CREDENTIALS_FILE=/.dbt/aws_credentials

ARG UID=1000
ARG GID=1000

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libpq-dev \
    git \
  && rm -rf /var/lib/apt/lists/ \
  && python3 -m pip install -U wheel

ADD entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh \
  && groupadd -f -g ${GID} -r dbt && useradd -g dbt -l -m -r -u ${UID} dbt \
  && mkdir /.dbt \
  && chown dbt:dbt /.dbt

ARG REQUIREMENTS_FILE
ARG DBT_VERSION

COPY requirements/${DBT_VERSION}/${REQUIREMENTS_FILE} /tmp/requirements.txt

RUN  python3 -m pip install -r /tmp/requirements.txt && rm -f /tmp/requirements.txt

USER dbt
WORKDIR /dbt

ENTRYPOINT ["/entrypoint.sh"]
CMD ["dbt", "debug"]
