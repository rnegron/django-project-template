# AGENTS.md

This is the canonical instructions file for AI coding agents working in this
repository (see https://agents.md). Tool-specific entrypoints such as
`CLAUDE.md` point here so every agent shares one source of truth.

## Project Overview

This is a Django project template designed for rapid backend development. It's a **template repository** meant to be used via `django-admin startproject --template=...` to bootstrap new Django projects. Template variables like `{{ project_name }}` appear throughout the codebase and are replaced during project initialization.

Key characteristics:
- Python 3.13 with Django 5.2 (LTS)
- Custom settings layout in `config/` (not within the app directory)
- Custom User model with email-only authentication (no username)
- Full-stack setup including frontend tooling (Tailwind, htmx, Alpine.js)
- Celery + Redis for async tasks
- Docker-first development approach

## Testing the Template

Since this is a template repository, automated tests create real projects from the template:

```bash
# Quick validation (~3-5 min)
./test_template.sh

# Full test with Docker (~10-15 min)
./test_template.sh --full
```

See `TESTING.md` for detailed testing strategy and workflows.

## Essential Commands

### Development Setup

```bash
# Local development (without Docker)
uv sync
cp .env.example .env
uv run pre-commit install
uv run python manage.py check

# Template development (working on the template itself)
uv sync --no-install-project  # Skip installing the template package (avoids metadata validation errors)
cp .env.example .env
uv run pre-commit install

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
uv run pytest --cov={{project_name}} --cov-fail-under=85 --cov-report term-missing:skip-covered

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

This template enforces [Conventional Commits](https://www.conventionalcommits.org/) format:

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
celery -A project_name worker --beat --scheduler django --loglevel=info

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

Located in `project_name/users/models.py`:
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
- `/api/v1/` - REST API endpoints (includes `project_name.api.urls`)
- `/__debug__/` - Django Debug Toolbar (DEBUG mode only)
- `/__reload__/` - Browser reload for development (DEBUG mode only)

API URLs are defined in `project_name/api/urls.py` (currently empty in template).

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

The template includes three Django apps:
1. **`project_name.users`** - Custom User model, forms, admin, factories
2. **`project_name.api`** - REST API endpoints (DRF)
3. **`project_name.theme`** - Tailwind CSS integration app

Templates are stored at project root in `templates/` directory.

### Testing Setup

Tests use pytest-django with configuration in `pytest.ini`:
- Test files: `tests.py`, `test_*.py`, `*_tests.py`
- Settings: `config.settings.test`
- Factories via `factory-boy` (see `project_name/users/factories.py`)
- Test directory: `tests/` at project root

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
2. **Lint job**: Runs Ruff (linting + formatting) and mypy type checking

## Important Notes for Development

### Template Variables

This is a template repository. Files contain `{{ project_name }}` placeholders that get replaced during `django-admin startproject`. When working on the template itself, preserve these placeholders. When working on a project created from this template, these will already be replaced.

**Important**: When using this template, always include `--exclude=node_modules` to prevent Django's template engine from trying to parse:
- JavaScript files in the Tailwind `node_modules` directory (which contain syntax that conflicts with Django templates)

### Working on the Template Itself

When developing this template repository (not a project created from it), use `uv sync --no-install-project` to install dependencies without trying to build/install the template package itself. This is necessary because:
- The `pyproject.toml` contains template placeholders (e.g., `name = "{{ project_name }}"`)
- These placeholders may not pass package metadata validation (like invalid author emails)
- The `--no-install-project` flag skips the editable install of the template package while still installing all dependencies

For projects created from this template, use the standard `uv sync` command (placeholders will already be replaced with actual values).

#### Running Django Commands on the Template

When you need to run Django management commands (like generating password hashes, running migrations, etc.) while working on the template itself, `uv run` will fail because it tries to build the package with template placeholders. Workaround:

1. Temporarily change `pyproject.toml` line 2 from `name = "{{ project_name }}"` to a valid name like `name = "temp-project"`
2. Add a `[tool.hatch.build.targets.wheel]` section with `packages = ["project_name"]` to tell hatchling where to find the package
3. Run your Django command: `uv run python manage.py <command>`
4. Revert both changes back to template placeholders

Example:
```bash
# Before running Django commands, edit pyproject.toml:
# - Change: name = "{{ project_name }}" → name = "temp-project"
# - Add after [build-system]:
#   [tool.hatch.build.targets.wheel]
#   packages = ["project_name"]

uv run python -c "from django.contrib.auth.hashers import make_password; print(make_password('password123'))"

# After running commands, revert pyproject.toml back to template placeholders
```

**Important**: Always revert these changes before committing - the template variables must be preserved.

### Pre-commit Hooks

Aggressive pre-commit hooks are enabled by default:
- **Ruff** (fast linting and formatting - replaces black, isort, and flake8)
- **mypy** (strict type checking, excludes tests/ and migrations/)
- **Conventional commits** (validates commit message format via commitizen)
- **Django checks** (runs `python manage.py check` before commits)
- **Migration checks** (ensures no uncommitted migrations)
- **File checks** (YAML, JSON, TOML validation, merge conflicts, debug statements, trailing whitespace, private key detection)

Install hooks with: `uv run pre-commit install`

**Note:** The commitizen hook validates commit messages using the [Conventional Commits](https://www.conventionalcommits.org/) format. Use `uv run cz commit` for an interactive commit experience, or ensure your manual commits follow the format: `<type>(<scope>): <description>`

### Database Configuration

Uses `dj-database-url` for flexible database configuration via `DATABASE_URL` environment variable. Defaults to SQLite if not set, but Postgres is strongly recommended (required for some features like `django.contrib.postgres`). The PostgreSQL driver is **psycopg 3** (`psycopg[binary]`); Django 5.2 auto-detects it from the `postgres://` URL scheme.

### Static Files

Static files use WhiteNoise with compressed manifest storage:
- `STATIC_URL = "/static/"`
- `STATIC_ROOT = BASE_DIR / "assets"`
- `STORAGES["staticfiles"]` uses `CompressedManifestStaticFilesStorage`

Tailwind CSS is integrated via django-tailwind and requires Node.js.

### Celery Configuration

Celery is configured but the actual celery.py file is not included in the template. When adding Celery tasks:
1. Create `project_name/celery.py` with standard Celery app initialization
2. Import it in `project_name/__init__.py` to ensure it's loaded
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

### Heroku

Configured for container-based deployment via `heroku.yml`:
1. Set stack: `heroku stack:set container`
2. Push: `git push heroku main`

Production settings in `config/settings/production.py` include:
- Atomic database requests
- SSL redirect and secure cookies
- Sentry integration for error tracking (sentry-sdk 2.x)
- Security headers (HSTS, XSS filter, content type nosniff)
