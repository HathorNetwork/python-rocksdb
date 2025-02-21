# before changing these variables, make sure the tag $PYTHON-alpine$ALPINE exists first
# list of valid tags hese: https://hub.docker.com/_/python
ARG PYTHON=3.11
# this could be bullseye as well
ARG DEBIAN=bookworm

# use this image to copy uv binaries from
# bookworm is not parametrized to $DEBIAN because there is no bullseye image, and the binary from bookworm works just fine
FROM ghcr.io/astral-sh/uv:python$PYTHON-bookworm-slim AS uv-bin
RUN uv -V
RUN uvx -V

# stage-0: copy pyproject.toml/poetry.lock and install the production set of dependencies
FROM python:$PYTHON-slim-$DEBIAN
ARG PYTHON
# install runtime first deps to speedup the dev deps and because layers will be reused on stage-1
RUN apt-get -qy update
RUN apt-get -qy install libffi-dev build-essential zlib1g-dev libbz2-dev libsnappy-dev liblz4-dev librocksdb-dev
COPY --from=uv-bin /usr/local/bin/uv /usr/local/bin/uvx /bin/
WORKDIR /app/
COPY pyproject.toml setup.py README.md LICENSE ./
RUN uv venv
COPY rocksdb ./rocksdb
RUN uv pip install --editable .[test]
RUN uvx pytest
