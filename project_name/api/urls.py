from django.urls import include, path

urlpatterns = [
    path("media/", include("{{ project_name }}.media.urls")),
]
