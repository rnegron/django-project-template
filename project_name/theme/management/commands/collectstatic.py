# From: https://www.khanna.law/blog/deploying-django-tailwind-to-heroku
from typing import Any

from django.contrib.staticfiles.management.commands.collectstatic import (
    Command as CollectStaticCommand,
)
from django.core.management import call_command


class Command(CollectStaticCommand):
    def handle(self, *args: Any, **options: Any) -> Any:
        call_command("tailwind", "build")
        super().handle(*args, **options)
