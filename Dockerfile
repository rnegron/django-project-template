FROM python:3.11-slim-buster

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Set environment variables
ENV POETRY_VIRTUALENVS_CREATE=0
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV LANGUAGE en_US:en
ENV LANG en_US.UTF-8

# Set work directory
WORKDIR /src

# Update and install system-level dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
        build-essential \
        chromium \
        curl \
        gettext \
        git \
        libpq-dev \
        unzip \
        wget \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/*

# Install Node.js (for Tailwind support)
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install application-level dependencies
RUN pip install --no-cache-dir poetry==1.3.2
COPY pyproject.toml poetry.lock /src/
RUN poetry install --no-root

# Copy project files over to image
COPY . /src/

# Prepare static files for Heroku deployment
RUN python manage.py tailwind install --no-input
RUN python manage.py tailwind build --no-input
RUN python manage.py collectstatic --noinput

# Expose 8000 port in container for API use
EXPOSE 8000
