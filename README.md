# Raúl's Django project template

When I get an idea for a backend project, I want to get up and running quickly with all my favorite packages. Hence this template repository!

## About

Inspired by [Sergio Mattei's](https://matteing.com/) "Shipping Projects at Lightning Speed with Django and NextJS" talk at [Fullstack Nights](https://fullstacknights.com/about/), as well as [José Padilla's](https://github.com/jpadilla/django-project-template) own project template.

## Features

* Most recent supported Python version (3.13)
* Latest Django LTS version (5.2)
* [uv](https://docs.astral.sh/uv/) as an alternative to `pip` and `pipenv`
* Type hints using `mypy` and `django-stubs`
* Tests and linting with GitHub CI
* Containerization with Docker
* A `docker-compose` setup for easy development using the latest Postgres major version (17)
* Static file serving with [WhiteNoise](https://whitenoise.readthedocs.io/en/stable/)
* Container-based deployment to any Docker host (Render, Fly.io, Railway, Cloud Run, ECS, a plain VM, etc.)
* Testing with [pytest-django](https://pytest-django.readthedocs.io/en/latest/index.html)
* Aggressive [pre-commit](https://pre-commit.com/) hooks with [Ruff](https://docs.astral.sh/ruff/) for fast linting and formatting
* [Conventional Commits](https://www.conventionalcommits.org/) enforcement via [Commitizen](https://commitizen-tools.github.io/commitizen/)
* Django-specific pre-commit hooks (system checks, migration checks)
* Alternative settings layout within a top-level config folder
* [Custom user model](https://docs.djangoproject.com/en/5.2/topics/auth/customizing/#auth-custom-user) with no username (only email/password)
* [Sentry](https://sentry.io) support for error tracking
* [Atomic Requests](https://docs.djangoproject.com/en/5.2/ref/settings/#atomic-requests) in production
* [Celery](https://docs.celeryproject.org/en/stable/index.html) asynchronous task management with [Redis](https://redis.io) as the transport
* [Django Celery Beat](https://django-celery-beat.readthedocs.io/en/latest/) for periodic tasks management from the Django Admin
* [htmx](https://htmx.org/) support via `django-htmx` for AJAX and other tools in HTML
* [Tailwind CSS v4](https://tailwindcss.com/) support via `django-tailwind` for webpage styling
* [Alpine.js](https://alpinejs.dev/) support via base template `<script>` tag for small interactivity

## Manual Quickstart

I recommend checking out [pipx](https://github.com/pipxproject/pipx) for isolating management commands like `django-admin` when working outside a virtual environment.


```bash
pipx install 'django==5.2'
```

```bash
django-admin startproject \
    --template=https://github.com/rnegron/django-project-template/archive/main.zip \
    --name=docker-entrypoint.sh,pytest.ini \
    --extension=py,md,toml \
    --exclude=node_modules \
    --exclude=.template-dev \
    project_name_here
```

```bash
cd project_name_here
```

```bash
uv sync
```

```bash
cp .env.example .env
```

```bash
uv run pre-commit install
```

```bash
uv run python manage.py check
```

If not using Docker, you will need to provide your own Postgres database and add the connection URL to the `.env` file.


## Docker Quickstart

```bash
pipx install 'django==5.2'
```

```bash
django-admin startproject \
    --template=https://github.com/rnegron/django-project-template/archive/main.zip \
    --name=docker-entrypoint.sh,pytest.ini \
    --extension=py,md,toml \
    --exclude=node_modules \
    --exclude=.template-dev \
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
## Deployment

The project ships as a single `Dockerfile` and runs on any container host (Render, Fly.io, Railway, Cloud Run, ECS, a plain VM, etc.).

Set these environment variables on the host, plus `DJANGO_SETTINGS_MODULE=config.settings.production`:

* `SECRET_KEY`
* `DATABASE_URL` (Postgres)
* `REDIS_URL`

Run these processes from the built image:

* **Release / migrate:** `python manage.py migrate`
* **Web:** `gunicorn -b "0.0.0.0:${PORT:-8000}" -w 2 "config.wsgi:application" --log-file -`
* **Worker:** `celery -A {{ project_name }} worker --beat --scheduler django --loglevel=info`

Static files (Tailwind + `collectstatic`) are built into the image and served by WhiteNoise, so no external static hosting is needed. `SECURE_PROXY_SSL_HEADER` is preset for deployments behind a TLS-terminating proxy.

## Track errors with Sentry

Simply add your Sentry DSN to the `.env` file.

More information: [Sentry docs](https://sentry.io/for/django/).

## Developing this template

Working on the template repository itself (not a project generated from it)? See [`.template-dev/AGENTS.md`](.template-dev/AGENTS.md) for placeholder workarounds, lockfile regeneration, and how to validate the template by generating a real project.
