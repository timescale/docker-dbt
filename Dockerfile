FROM python:3.8-slim-bullseye

ARG UID=1000
ARG GID=1000

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    build-essential \
    libffi-dev \
    libpq-dev \
    git \
  && rm -rf /var/lib/apt/lists/ \
  && groupadd -f -g ${GID} -r dbt && useradd -g dbt -l -m -r -u ${UID} dbt \
  && python3 -m pip install -U wheel

ARG DBT_VERSION
ARG DBT_ADAPTER

COPY requirements/${DBT_VERSION}/requirements-${DBT_ADAPTER}.txt /tmp/requirements.txt

RUN  python3 -m pip install -r /tmp/requirements.txt && rm -f /tmp/requirements.txt

USER dbt
WORKDIR /dbt

CMD ["dbt", "debug"]
