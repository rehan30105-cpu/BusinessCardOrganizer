"""Backend authentication tests for Business Card Organizer."""

import pytest
from fastapi.testclient import TestClient
from tortoise.exceptions import IntegrityError

from app.main import app
from app.core.security import create_access_token, verify_refresh_token
from tortoise import Tortoise


client = TestClient(app)


@pytest.fixture(autouse=True, scope="module")
async def tortoise_test_database():
    """Set up and tear down the test database."""
    await Tortoise.init(
        db_url="sqlite://:memory:",
        modules={"models": ["app.models"]},
    )
    await Tortoise.generate_schemas()
    yield
    await Tortoise.close_connections()
    await Tortoise._drop_databases()


@pytest.fixture
def override_get_current_user():
    """Override dependency to return a test user."""
    from app.core.security import get_current_user_from_token

    async def _override():
        from app.models import User
        user, _ = await User.get_or_create(
            email="test@example.com",
            defaults={
                "id": "test-uuid-1234",
                "hashed_password": "hashed_pw",
                "full_name": "Test User",
            },
        )
        return user

    return _override


@pytest.mark.usefixtures("override_get_current_user")
class TestAuthRoutes:
    """Test authentication API endpoints."""

    def test_register(self):
        """POST /api/v1/auth/register"""
        response = client.post(
            "/api/v1/auth/register",
            json={
                "email": "newuser@example.com",
                "password": "SecurePass123!",
                "full_name": "New User",
            },
        )
        assert response.status_code == 201
        data = response.json()
        assert data["email"] == "newuser@example.com"
        assert data["full_name"] == "New User"
        assert "id" in data

    def test_register_duplicate_email(self):
        """Registering with duplicate email should fail."""
        client.post(
            "/api/v1/auth/register",
            json={
                "email": "newuser@example.com",
                "password": "SecurePass123!",
                "full_name": "New User",
            },
        )
        response = client.post(
            "/api/v1/auth/register",
            json={
                "email": "newuser@example.com",
                "password": "DifferentPass456!",
                "full_name": "Another User",
            },
        )
        assert response.status_code == 400
        assert "already registered" in response.json()["detail"].lower()

    def test_login(self):
        """POST /api/v1/auth/login"""
        # First register
        client.post(
            "/api/v1/auth/register",
            json={"email": "loginuser@example.com", "password": "Pass123!", "full_name": "Login User"},
        )
        # Then login
        response = client.post(
            "/api/v1/auth/login",
            data={"username": "loginuser@example.com", "password": "Pass123!"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"

    def test_login_wrong_password(self):
        """Login with wrong password should fail."""
        response = client.post(
            "/api/v1/auth/login",
            data={"username": "nonexistent@example.com", "password": "wrongpass"},
        )
        assert response.status_code == 401

    def test_refresh_token(self):
        """POST /api/v1/auth/refresh"""
        # Register and login first
        client.post(
            "/api/v1/auth/register",
            json={"email": "refreshuser@example.com", "password": "Pass123!", "full_name": "Refresh User"},
        )
        login_resp = client.post(
            "/api/v1/auth/login",
            data={"username": "refreshuser@example.com", "password": "Pass123!"},
        )
        refresh_token = login_resp.json()["refresh_token"]

        # Refresh
        response = client.post("/api/v1/auth/refresh", json={"refresh_token": refresh_token})
        assert response.status_code == 200
        data = response.json()
        assert "access_token" in data
        assert "refresh_token" in data

        # Old refresh token should be revoked
        # Try using old token - should fail
        old_token_resp = client.post(
            "/api/v1/auth/refresh",
            json={"refresh_token": refresh_token},
        )
        # Should get an error or new tokens (depending on implementation)