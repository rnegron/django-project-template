FROM python:3.7-slim-buster as base

ENV PIP_USER=1
ENV PYTHONUNBUFFERED=1

RUN apt clean \
    && rm -rf /var/lib/apt/lists/* \
    && apt update -y

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

ENV PATH="/home/appuser/.local/bin:$PATH"
RUN useradd --create-home appuser
USER appuser

FROM base as builder

RUN pip install poetry==1.0.5
COPY pyproject.toml poetry.lock /tmp/
RUN poetry export -f requirements.txt > /tmp/requirements.txt

FROM base

WORKDIR /home/appuser
COPY --from=builder --chown=appuser:appuser /tmp/requirements.txt /home/appuser/
RUN pip install --user -r requirements.txt

COPY --chown=appuser:appuser . .
