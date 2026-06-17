# AGENTS.md

Guidance for AI coding agents working in this repository. Tool-specific entrypoints such as `CLAUDE.md` point here so every agent shares one source of truth.

## Project Overview

A Django backend project bootstrapped from a Django project template, set up for rapid development.

Key characteristics:
- Python 3.13 with Django 5.2 (LTS)
- Custom settings layout in `config/` (not within the app directory)
- Custom User model with email-only authentication (no username)
- Full-stack setup including frontend tooling (Tailwind, htmx, Alpine.js)
- Celery + Redis for async tasks
- Docker-first development approach

## Essential Commands

### Development Setup

```bash
# Local development (without Docker)
uv sync
cp .env.example .env
uv run pre-commit install
uv run python manage.py check

# Docker development (recommended)
cp .env.example .env
docker-compose up --detach --build
# Default admin: admin@example.com / password123
```

### Running Tests

```bash
# Run all tests
uv run pytest

# Run with coverage (CI standard: 85% minimum)
uv run pytest --cov={{ project_name }} --cov-fail-under=85 --cov-report term-missing:skip-covered

# Run specific test file
uv run pytest tests/test_something.py

# Run specific test
uv run pytest tests/test_something.py::test_function_name
```

### Code Quality

```bash
# Run all pre-commit hooks manually
uv run pre-commit run --all-files

# Individual tools
uv run ruff check .        # Run linting
uv run ruff check . --fix  # Run linting with auto-fix
uv run ruff format .       # Run formatting
uv run mypy .              # Run type checking
```

### Commit Messages

This project enforces [Conventional Commits](https://www.conventionalcommits.org/) format:

```bash
# Interactive commit (recommended for beginners)
uv run cz commit

# Manual commit (must follow conventional format)
git commit -m "feat: add user profile page"
git commit -m "fix(auth): resolve token expiration"
git commit -m "docs: update README with new features"
```

**Format:** `<type>(<scope>): <description>`

**Allowed types:** feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

### Django Management

```bash
# Create migrations
uv run python manage.py makemigrations

# Apply migrations
uv run python manage.py migrate

# Create superuser
uv run python manage.py createsuperuser

# Run development server
uv run python manage.py runserver
```

### Frontend Tooling

```bash
# Install Tailwind dependencies
uv run python manage.py tailwind install

# Start Tailwind watcher (development)
uv run python manage.py tailwind start

# Build Tailwind for production
uv run python manage.py tailwind build

# Collect static files
uv run python manage.py collectstatic --noinput
```

### Celery Tasks

```bash
# Run Celery worker with beat scheduler
celery -A {{ project_name }} worker --beat --scheduler django --loglevel=info

# In Docker, this runs automatically via docker-compose (worker service)
```

## Architecture

### Settings Architecture

Settings are split into environment-specific modules under `config/settings/`:
- `base.py` - Common settings for all environments
- `local.py` - Development settings (DEBUG=True, django-debug-toolbar, django-extensions)
- `production.py` - Production settings (security headers, Sentry integration, atomic requests)
- `test.py` - Test-specific settings

Set via `DJANGO_SETTINGS_MODULE` environment variable:
- Local: `config.settings.local`
- Production: `config.settings.production`
- Tests: `config.settings.test` (configured in pytest.ini)

### Custom User Model

Located in `{{ project_name }}/users/models.py`:
- Uses `UUID` as primary key instead of integer
- Email-only authentication (no username field)
- Custom manager `CustomUserManager` handles user creation
- Configured as `AUTH_USER_MODEL = "users.User"` in settings

This is integrated with django-allauth (65.x) for authentication with these settings:
```python
ACCOUNT_USER_MODEL_USERNAME_FIELD = None
ACCOUNT_LOGIN_METHODS = {"email"}
ACCOUNT_SIGNUP_FIELDS = ["email*", "password1*", "password2*"]
```

### URL Structure

Root URL configuration in `config/urls.py`:
- `/admin/` - Django Admin
- `/api/v1/` - REST API endpoints (includes `{{ project_name }}.api.urls`)
- `/__debug__/` - Django Debug Toolbar (DEBUG mode only)
- `/__reload__/` - Browser reload for development (DEBUG mode only)

API URLs are defined in `{{ project_name }}/api/urls.py`.

### Docker Architecture

The `docker-compose.yml` defines 5 services:
1. **database** - PostgreSQL 17
2. **redis** - Redis 8-alpine (for Celery broker)
3. **web** - Django application server
   - Entrypoint: `dev_web_start` runs migrations, loads fixtures, starts runserver
4. **worker** - Celery worker with beat scheduler
   - Entrypoint: `dev_worker_start` runs Celery with Django scheduler
5. **tailwind** - Tailwind CSS watcher for development
   - Entrypoint: `dev_tailwind_start` runs Tailwind in watch mode

The `docker-entrypoint.sh` script handles different startup modes based on the command argument.

### App Structure

Three Django apps:
1. **`{{ project_name }}.users`** - Custom User model, forms, admin, factories
2. **`{{ project_name }}.api`** - REST API endpoints (DRF)
3. **`{{ project_name }}.theme`** - Tailwind CSS integration app

Templates are stored at project root in `templates/` directory.

### Testing Setup

Tests use pytest-django with configuration in `pytest.ini`:
- Test files: `tests.py`, `test_*.py`, `*_tests.py`
- Settings: `config.settings.test`
- Factories via `factory-boy` (see `{{ project_name }}/users/factories.py`)
- Test directory: `tests/` at project root
- Coverage excludes test infrastructure (migrations, factories, tests) via `[tool.coverage.run]`

### Type Checking

mypy configured in `pyproject.toml` with strict settings:
- Requires type hints for all function definitions (`disallow_untyped_defs`)
- Uses django-stubs and djangorestframework-stubs
- Excludes migrations
- Test settings module: `config.settings.test`

### CI/CD

GitHub Actions workflows:

**`.github/workflows/ci.yml`** - Main CI pipeline:
1. **Test job**: Runs tests with Postgres 17 and Redis 8-alpine, Python 3.13, Node 22, includes Playwright, requires 85% coverage, uploads results to Codecov
2. **Lint job**: Runs Ruff (linting + formatting)

## Important Notes

### Pre-commit Hooks

Aggressive pre-commit hooks are enabled by default:
- **Ruff** (fast linting and formatting - replaces black, isort, and flake8)
- **mypy** (strict type checking, excludes tests/ and migrations/)
- **Conventional commits** (validates commit message format via commitizen)
- **Django checks** (runs `python manage.py check` before commits)
- **Migration checks** (ensures no uncommitted migrations)
- **File checks** (YAML, JSON, TOML validation, merge conflicts, debug statements, trailing whitespace, private key detection)

Install hooks with: `uv run pre-commit install`

### Database Configuration

Uses `dj-database-url` for flexible database configuration via `DATABASE_URL` environment variable. Defaults to SQLite if not set, but Postgres is strongly recommended (required for some features like `django.contrib.postgres`). The PostgreSQL driver is **psycopg 3** (`psycopg[binary]`); Django 5.2 auto-detects it from the `postgres://` URL scheme.

### Static Files

Static files use WhiteNoise with compressed manifest storage:
- `STATIC_URL = "/static/"`
- `STATIC_ROOT = BASE_DIR / "assets"`
- `STORAGES["staticfiles"]` uses `CompressedManifestStaticFilesStorage`

Tailwind CSS is integrated via django-tailwind and requires Node.js.

### Celery Configuration

Celery is configured but the actual celery.py file is not included by default. When adding Celery tasks:
1. Create `{{ project_name }}/celery.py` with standard Celery app initialization
2. Import it in `{{ project_name }}/__init__.py` to ensure it's loaded
3. Tasks use Redis as broker (configured via `REDIS_URL` environment variable)
4. Beat scheduler uses django-celery-beat for database-backed periodic tasks

### Environment Variables

Required environment variables (see `.env.example`):
- `SECRET_KEY` - Django secret key
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string for Celery
- `DEBUG` - Enable/disable debug mode
- `SENTRY_DSN` - (Optional) Sentry error tracking
- `SENTRY_TRACES_SAMPLE_RATE` - (Optional) Sentry performance tracing rate (default `0.0`)

## Deployment

Container-based: the `Dockerfile` runs on any Docker host (Render, Fly.io, Railway, Cloud Run, ECS, a plain VM, etc.). Provide `SECRET_KEY`, `DATABASE_URL`, `REDIS_URL`, and `DJANGO_SETTINGS_MODULE=config.settings.production`. Processes:
- **Release/migrate:** `python manage.py migrate`
- **Web:** `gunicorn -b "0.0.0.0:${PORT:-8000}" -w 2 "config.wsgi:application" --log-file -`
- **Worker:** `celery -A {{ project_name }} worker --beat --scheduler django --loglevel=info`

Static files (Tailwind + `collectstatic`) are built into the image and served by WhiteNoise. Production settings in `config/settings/production.py` include:
- Atomic database requests
- SSL redirect and secure cookies
- Sentry integration for error tracking (sentry-sdk 2.x)
- Security headers (HSTS, XSS filter, content type nosniff)
</content>
