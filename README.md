# Raúl's Django project template

When I get an idea for a backend project, I want to get up and running quickly with all my favorite packages. Hence this template repository!

## About

Inspired by [Sergio Mattei's](https://twitter.com/matteing) "Shipping Projects at Lightning Speed with Django and NextJS" talk at [Fullstack Nights](https://twitter.com/rucury/status/1207092925542342656), as well as [José Padilla's](https://github.com/jpadilla/django-project-template) own project template.

## Features

* Latest Django LTS (2.2)
* [poetry](https://python-poetry.org/) as an alternative to pipenv
* Containerization with Docker
* A `docker-compose` setup for easy development using Postgres 11
* Static file serving with [WhiteNoise](http://whitenoise.evans.io/en/stable/)
* Support deployment to [Heroku](https://dashboard.heroku.com/) using container
* Testing with [pytest-django](https://pytest-django.readthedocs.io/en/latest/index.html)
* Aggressive [pre-commit](https://pre-commit.com/) hooks with tools such as black, isort and flake8
* [Argon2](https://docs.djangoproject.com/en/2.2/topics/auth/passwords/#using-argon2-with-django) hashed passwords by default
* Alternative settings layout within a top-level config folder
* Custom user model with no username (only email/password)
* [Sentry](https://sentry.io) support for error tracking


## Manual Quickstart

I recommend checking out [pipx](https://github.com/pipxproject/pipx) for isolating management commands like `django-admin` when working outside a virtual environment.


```bash
pipx install 'django<3.0'
```

```bash
django-admin startproject \
    --template=https://github.com/rnegron/django-project-template/archive/master.zip \
    --name=docker-entrypoint.sh,heroku.yml,.isort.cfg \
    project_name_here
```

```
cd project_name_here
```

```bash
poetry install
```

```bash
cp .env.example .env
```

```
poetry run python manage.py check
```

You will need to provide your own Postgres database, along with modifying the `.env` to


## Docker Quickstart

1. Download [Docker Compose](https://docs.docker.com/compose/install/)
2. Run `docker-compose up -d`
3. Visit [http://localhost:8000](http//localhost:8000) to view the API. A super user for the Django Admin is created automatically using fixtures.

```
    email: admin@example.com
    password: password123
```

4. Run `docker-compose down` to stop the running containers.

## Deploy with Heroku

Log in to your Heroku account with their CLI and set up your repository to track your Heroku app. Then,

* `heroku stack:set container`
* `git push heroku master`

More information: [Heroku docs](https://devcenter.heroku.com/articles/build-docker-images-heroku-yml).

## Track errors with Sentry

Simply add your Sentry DSN to the `.env` file.
More information: [Sentry docs](https://sentry.io/for/django/).


## To-Do

### Add
- Test runner script
- Celery
- mypy
- Debugging setup
