import pytest
from django.contrib.auth import get_user_model

User = get_user_model()


@pytest.mark.django_db
class TestUserModel:
    """Test the custom User model."""

    def test_create_user(self):
        """Test creating a user with email and password."""
        email = "test@example.com"
        password = "testpass123"
        user = User.objects.create_user(email=email, password=password)

        assert user.email == email
        assert user.check_password(password)
        assert not user.is_staff
        assert not user.is_superuser
        assert user.is_active

    def test_create_superuser(self):
        """Test creating a superuser."""
        email = "admin@example.com"
        password = "adminpass123"
        user = User.objects.create_superuser(email=email, password=password)

        assert user.email == email
        assert user.check_password(password)
        assert user.is_staff
        assert user.is_superuser
        assert user.is_active

    def test_user_str_representation(self):
        """Test the string representation of a user."""
        email = "user@example.com"
        user = User.objects.create_user(email=email, password="pass123")

        assert str(user) == email

    def test_email_normalization(self):
        """Test that email addresses are normalized."""
        email = "test@EXAMPLE.COM"
        user = User.objects.create_user(email=email, password="pass123")

        assert user.email == "test@example.com"

    def test_create_user_without_email_raises_error(self):
        """Test that creating a user without an email raises an error."""
        with pytest.raises(ValueError, match="The given email must be set"):
            User.objects.create_user(email="", password="pass123")
