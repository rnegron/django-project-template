# django-project-template

When I get an idea for a backend project, I want to get up and running quickly with all my favorite tools. Hence this template repository!

## Quickstart

```
django-admin startproject --template=https://github.com/rnegron/django-project-template/archive/master.zip project-name-here
```

## About

Inspired by [Sergio Mattei's](https://twitter.com/matteing) "Shipping Projects at Lightning Speed with Django and NextJS" talk at [Fullstack Nights](https://twitter.com/rucury/status/1207092925542342656), as well as [José Padilla's](https://github.com/jpadilla/django-project-template) own project template.

## Features

* Latest Django LTS (2.2)
* [poetry](https://python-poetry.org/) as an alternative to pipenv
* Containerization with Docker
* A `docker-compose` setup for easy development using Postgres 11
* Testing with [pytest-django](https://pytest-django.readthedocs.io/en/latest/index.html)
* Aggressive [pre-commit](https://pre-commit.com/) hooks with tools such as black, isort and flake8
* [Argon2](https://docs.djangoproject.com/en/3.0/topics/auth/passwords/#using-argon2-with-django) hashed passwords by default
* Alternative settings layout with a top-level config folder
* Custom user model with no username (only email/password)

## Docker Setup

1. Download [Docker Compose](https://docs.docker.com/compose/install/)
2. Run `docker-compose up -d`
3. Visit [http://localhost:8000](http//localhost:8000) to view the API. A super user for the Django Admin is created automatically using fixtures.

```
    email: admin@example.com
    password: password123
```

4. Run `docker-compose down` to stop the running containers.

## To-Do

### Add
- Test runner script
- Sentry
- Celery
- Heroku
- mypy

### Update

- Improve documentation
