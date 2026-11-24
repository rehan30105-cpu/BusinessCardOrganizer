"""Security module for Business Card Organizer Backend.

Implements security hardening across the application including:
- Authentication security
- Authorization
- API security
- Infrastructure security
"""

# Re-export key security utilities
from app.core.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    create_refresh_token,
    verify_refresh_token,
    authenticate_user,
)
from app.core.config import settings

# Security constants
class SecurityConstants:
    """Security-related constants."""
    
    # Password policy
    MIN_PASSWORD_LENGTH = 8
    MAX_PASSWORD_LENGTH = 128
    
    # Token settings
    ACCESS_TOKEN_EXPIRE_MINUTES = settings.ACCESS_TOKEN_EXPIRE_MINUTES
    REFRESH_TOKEN_EXPIRE_DAYS = settings.REFRESH_TOKEN_EXPIRE_DAYS
    
    # Rate limiting
    DEFAULT_RATE_LIMIT = 100
    LOGIN_RATE_LIMIT = 5
    REGISTER_RATE_LIMIT = 3
    CONTACT_CREATE_RATE_LIMIT = 10
    
    # Security headers
    CONTENT_TYPE_NOSNIFF = "nosniff"
    FRAME_OPTIONS_SAMEORIGIN = "SAMEORIGIN"
    XSS_PROTECTION "1; mode=block"
    REFERRER_POLICY = "strict-origin-when-cross-origin"

# Export for use in middleware and routes
__all__ = [
    "SecurityConstants",
    "verify_password",
    "get_password_hash",
    "create_access_token",
    "create_refresh_token",
    "verify_refresh_token",
    "authenticate_user",
    "settings",
]