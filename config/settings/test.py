import os

from .base import *  # noqa

DEBUG = True

SECRET_KEY = os.getenv("SECRET_KEY", "super-secret-key")

ALLOWED_HOSTS = ["localhost", "0.0.0.0", "127.0.0.1"]

INTERNAL_IPS = [
    "127.0.0.1",
]
