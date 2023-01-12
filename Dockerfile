FROM python:3.11-slim-buster

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
        git

# Install application-level dependencies
RUN pip install poetry==1.3.2
COPY pyproject.toml poetry.lock /src/
RUN poetry install --no-root

# Copy project files over to image
COPY . /src/

# Expose 8000 port in container for API use
EXPOSE 8000
