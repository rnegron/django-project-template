FROM python:3.8-slim-buster as base

ENV PIP_USER=1
ENV PYTHONUNBUFFERED=1

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get update -y

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get install -y --no-install-recommends \
    build-essential=12.6 \
    git=1:2.20.1-2+deb10u1

ENV PATH="/home/appuser/.local/bin:$PATH"
RUN useradd --create-home appuser
USER appuser

FROM base as builder

WORKDIR /tmp

RUN pip install poetry==1.0.5
COPY pyproject.toml poetry.lock /tmp/
RUN poetry install
RUN poetry export --dev -f requirements.txt > /tmp/requirements.txt

FROM base

WORKDIR /home/appuser
COPY --from=builder --chown=appuser:appuser /tmp/requirements.txt /home/appuser/
RUN pip install --user -r requirements.txt

COPY --chown=appuser:appuser . .
