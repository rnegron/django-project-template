import os
import socket

from .base import *  # noqa

# GENERAL
DEBUG = True

SECRET_KEY = os.getenv("SECRET_KEY", "super-secret-key")

# https://docs.djangoproject.com/en/dev/ref/settings/#allowed-hosts
ALLOWED_HOSTS = ["localhost", "0.0.0.0", "127.0.0.1"]

# CACHES
CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.locmem.LocMemCache",
        "LOCATION": "",
    }
}


# django-debug-toolbar
INSTALLED_APPS += ["debug_toolbar"]  # noqa F405
MIDDLEWARE += ["debug_toolbar.middleware.DebugToolbarMiddleware"]  # noqa F405
DEBUG_TOOLBAR_CONFIG = {
    "DISABLE_PANELS": ["debug_toolbar.panels.redirects.RedirectsPanel"]
}

INTERNAL_IPS = [
    "127.0.0.1",
]

# Showing the debug toolbar when using Docker
hostname, _, ips = socket.gethostbyname_ex(socket.gethostname())
INTERNAL_IPS += [ip[:-1] + "1" for ip in ips]

# django-extensions
INSTALLED_APPS += ["django_extensions"]  # noqa F405
