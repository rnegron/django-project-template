#!/usr/bin/env python
"""Django's command-line utility for administrative tasks."""
import os
import sys


def main():
    os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.production")
    try:
        from django.core.management import execute_from_command_line

        RUN_MAIN = os.environ.get("RUN_MAIN") or os.environ.get("WERKZEUG_RUN_MAIN")
        if RUN_MAIN and os.environ.get("VSCODE_DEBUGGER", False):
            import ptvsd # noqa

            ptvsd_port = os.environ.get("PTVSD_PORT", 5678)

            try:
                ptvsd.enable_attach(address=("0.0.0.0", ptvsd_port))
                print(f"Started ptvsd at port {ptvsd_port}")
            except OSError:
                print(f"Error: Could open ptvsd at port {ptvsd_port}")

    except ImportError as exc:
        raise ImportError(
            "Couldn't import Django. Are you sure it's installed and "
            "available on your PYTHONPATH environment variable? Did you "
            "forget to activate a virtual environment?"
        ) from exc
    execute_from_command_line(sys.argv)


if __name__ == "__main__":
    main()
