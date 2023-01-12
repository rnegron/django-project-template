# Raúl's Django project template

When I get an idea for a backend project, I want to get up and running quickly with all my favorite packages. Hence this template repository!

## About

Inspired by [Sergio Mattei's](https://twitter.com/matteing) "Shipping Projects at Lightning Speed with Django and NextJS" talk at [Fullstack Nights](https://twitter.com/rucury/status/1207092925542342656), as well as [José Padilla's](https://github.com/jpadilla/django-project-template) own project template.

## Features

* Most recent Python (3.11)
* Latest Django LTS (3.2)
* [poetry](https://python-poetry.org/) as an alternative to `pipenv`
* Containerization with Docker
* Type hints using `mypy` and `django-stubs`
* Tests and linting with GitHub CI
* A `docker-compose` setup for easy development using the latest Postgres major version (14)
* Static file serving with [WhiteNoise](http://whitenoise.evans.io/en/stable/)
* Deployment to [Heroku](https://dashboard.heroku.com/) using containers
* Testing with [pytest-django](https://pytest-django.readthedocs.io/en/latest/index.html)
* Aggressive [pre-commit](https://pre-commit.com/) hooks with tools such as black, isort and flake8
* [Argon2](https://docs.djangoproject.com/en/3.2/topics/auth/passwords/#using-argon2-with-django) hashed passwords by default
* Alternative settings layout within a top-level config folder
* [Custom user model](https://docs.djangoproject.com/en/3.2/topics/auth/customizing/#auth-custom-user) with no username (only email/password)
* [Sentry](https://sentry.io) support for error tracking
* [Atomic Requests](https://docs.djangoproject.com/en/3.2/ref/settings/#atomic-requests) in production
* [Celery](https://docs.celeryproject.org/en/stable/index.html) asynchronous task management with [Redis](https://redis.io) as the transport
* [Django Celery Beat](https://django-celery-beat.readthedocs.io/en/latest/) for periodic tasks management from the Django Admin
* [htmx](https://htmx.org/) support via `django-htmx` for AJAX and other tools in HTML
* [Tailwind CSS](https://tailwindcss.com/) support via `django-tailwind` for webpage styling
* [Alpine.js](https://alpinejs.dev/) support via base template `<script>` tag for small interactivity

## Manual Quickstart

I recommend checking out [pipx](https://github.com/pipxproject/pipx) for isolating management commands like `django-admin` when working outside a virtual environment.


```bash
pipx install 'django==3.2'
```

```bash
django-admin startproject \
    --template=https://github.com/rnegron/django-project-template/archive/main.zip \
    --name=docker-entrypoint.sh,.isort.cfg \
    --extension=py,md,yml \
    project_name_here
```

```bash
cd project_name_here
```

```bash
poetry install
```

```bash
cp .env.example .env
```

```bash
poetry run pre-commit install
```

```bash
poetry run python manage.py check
```

If not using Docker, you will need to provide your own Postgres database and add the connection URL to the `.env` file.


## Docker Quickstart

```bash
pipx install 'django==3.2'
```

```bash
django-admin startproject \
    --template=https://github.com/rnegron/django-project-template/archive/main.zip \
    --name=docker-entrypoint.sh,.isort.cfg \
    --extension=py,md,yml \
    project_name_here
```

```bash
cd project_name_here
```

```bash
cp .env.example .env
```

```bash
docker-compose up --detach --build
```

The API should be live at [http://localhost:8000](http//localhost:8000). A super user for the Django Admin is created automatically using fixtures when using the Docker quickstart method.

```
    email: admin@example.com
    password: password123
```
## Deploy with Heroku

Log in to your Heroku account with their CLI and set up your repository to track your Heroku app. Then,

* `heroku stack:set container`
* `git push heroku main`

More information: [Heroku docs](https://devcenter.heroku.com/articles/build-docker-images-heroku-yml).

## Track errors with Sentry

Simply add your Sentry DSN to the `.env` file.

More information: [Sentry docs](https://sentry.io/for/django/).

