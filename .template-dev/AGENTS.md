# AGENTS.md — Template Development

Instructions for AI agents (and humans) working on the **django-project-template repository itself** — not on a project generated from it.

Everything in this `.template-dev/` directory is template-maintenance machinery and is **excluded from generated projects** (the `startproject` commands pass `--exclude=.template-dev`). Keep template-only logic here; the root `AGENTS.md` is the project-facing file that gets copied into real projects, so it must stay free of template-maintenance content.

## This is a template repository

Files contain `{{ project_name }}` placeholders that `django-admin startproject` replaces during generation. When working on the template, **preserve these placeholders**. Markdown/py/toml files are rendered (`--extension=py,md,toml`), so `{{ project_name }}` inside them resolves to the real project name in generated projects.

Always generate with `--exclude=node_modules` (Tailwind's `node_modules` contains JS that conflicts with Django's template engine) and `--exclude=.template-dev` (this directory).

## Working on the template itself

`pyproject.toml` has `name = "{{ project_name }}"`, which is **not a valid package name**, so plain `uv` commands fail to parse it. Install dependencies without building the package:

```bash
uv sync --no-install-project   # skips the editable install of the template package
cp .env.example .env
uv run pre-commit install
```

## Running Django commands on the template

`uv run python manage.py <cmd>` fails because uv tries to build the package with the placeholder name. Workaround:

1. Temporarily change `pyproject.toml` line 2 from `name = "{{ project_name }}"` to a valid name (e.g. `name = "project-name"`).
2. If a build is actually needed, add a `[tool.hatch.build.targets.wheel]` section with `packages = ["project_name"]`.
3. Run the command.
4. **Revert** the changes before committing — the placeholders must be preserved.

## Regenerating the lockfile (uv commands only)

**Never hand-edit `uv.lock`.** Regenerate it exclusively with uv:

```bash
sed -i '' 's/^name = "{{ project_name }}"/name = "project-name"/' pyproject.toml
uv lock --python 3.13.8          # pass --python to avoid the .python-version pin
sed -i '' 's/^name = "project-name"/name = "{{ project_name }}"/' pyproject.toml
```

Only `pyproject.toml`'s `name` line is touched by hand — `uv.lock` itself is always machine-generated.

## Testing the template

The template is validated by generating a **real project from it** and running the project's checks.

### Automated harness

```bash
./.template-dev/test_template.sh            # quick validation (~3-5 min)
./.template-dev/test_template.sh --full     # full suite incl. Docker (~10-15 min)
```

### Manual end-to-end exercise (the `/tmp` exercise)

Use this to validate a real generation by hand. It points `django-admin` at the **local repo** and runs the full project gate:

```bash
REPO="$(pwd)"
rm -rf /tmp/myproject && mkdir -p /tmp/myproject

# 1. Generate a project from the local template
uvx --from "django>=5.2,<6.0" django-admin startproject \
  --template="$REPO" \
  --name=docker-entrypoint.sh,.isort.cfg,pytest.ini \
  --extension=py,md,toml \
  --exclude=node_modules \
  --exclude=.template-dev \
  myproject /tmp/myproject

cd /tmp/myproject
cp .env.example .env
printf '\nSECRET_KEY=k\nDATABASE_URL=sqlite:///db.sqlite3\n' >> .env

# 2. Run the full project gate (these must all pass)
uv sync --all-groups
uv run python manage.py check --settings=config.settings.local
uv run python manage.py makemigrations --settings=config.settings.local
uv run python manage.py migrate --settings=config.settings.local
uv run pytest --cov=myproject --cov-fail-under=85 --cov-report term-missing:skip-covered
uv run ruff check .
uv run ruff format --check .
# Optional smoke test: boot the server and curl /admin/ (expect 302) and /api/v1/ (expect 404)
```

Verify along the way: **no unreplaced `{{ project_name }}`** remains, `django check` is clean, migrations apply, tests pass the 85% coverage gate, and ruff is green. Clean up with `rm -rf /tmp/myproject`.

> Note: if the locally-installed Python differs from the pinned patch (`.python-version` / `requires-python`), set `echo "<available 3.13.x>" > /tmp/myproject/.python-version` before `uv sync`. The patch version does not affect dependency resolution.

## Keeping template logic out of generated projects

When adding template-maintenance tooling, put it in `.template-dev/` (auto-excluded). Before shipping, regenerate via the `/tmp` exercise and confirm the generated project does **not** contain any template-only files or instructions. Known root-level files that still ship but are harmless: `_config.yml` (Jekyll config for this repo's GitHub Pages — must stay at root) and `README.md` (template-usage oriented by nature).
</content>
