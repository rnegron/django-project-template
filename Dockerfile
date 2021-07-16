FROM python:3.9-slim-buster as base

ENV PIP_USER=1
ENV POETRY_VIRTUALENVS_CREATE=0
ENV PYTHONUNBUFFERED=1

RUN apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get update -y

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get install -y --no-install-recommends \
    build-essential \
    git

ENV PATH="/home/appuser/.local/bin:$PATH"
RUN useradd --create-home appuser
USER appuser

FROM base as builder

WORKDIR /tmp

RUN pip install --no-cache-dir poetry==1.1.7
COPY pyproject.toml poetry.lock /tmp/
RUN poetry install && poetry export --dev -f requirements.txt > /tmp/requirements.txt

FROM base

WORKDIR /home/appuser
COPY --from=builder --chown=appuser:appuser /tmp/requirements.txt /home/appuser/
RUN pip install --no-cache-dir --user -r requirements.txt

COPY --chown=appuser:appuser . .
