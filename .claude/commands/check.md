---
description: Run the full local quality gate (lint, format, types, Django + migration checks, tests)
---

Run the project's complete quality gate — the same checks CI enforces — and fix anything that fails before reporting back. Run these in order and do not stop at the first failure; collect all results:

1. `uv run ruff check .` — lint (use `--fix` to auto-resolve)
2. `uv run ruff format --check .` — formatting (use `uv run ruff format .` to fix)
3. `uv run mypy .` — strict type checking
4. `uv run python manage.py check` — Django system checks
5. `uv run python manage.py makemigrations --check --dry-run --no-input` — no uncommitted migrations
6. `uv run pytest --cov={{ project_name }} --cov-fail-under=85 --cov-report term-missing:skip-covered` — tests with 85% coverage gate

Fix every failure, re-run the affected step to confirm green, then give a concise pass/fail summary per step. Do not commit; leave changes staged for review.
