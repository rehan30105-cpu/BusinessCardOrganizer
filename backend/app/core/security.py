"""Security utilities for Business Card Organizer Backend."""

import os
import uuid
import hashlib
import base64
from datetime import datetime, timedelta, timezone
from typing import Optional, Union

from jose import JWTError, jwt as jjwt
from passlib.context import CryptContext
from tortoise.models import Model

# Password hashing using Argon2id
pwd_context = CryptContext(
    scheme="argon2",
    rounds=15,
    memory=64 * 1024,
    time_cost=2,
    hash_len=32,
    secret_key=os.getenv("HASH_SECRET", "change-this-in-production"),
    use_and_logaritmic_rounds=False,
)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash."""
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    """Generate a password hash using Argon2id."""
    return pwd_context.hash(password)


def create_access_token(sub: Union[str, bytes], expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT access token."""
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=15)
    
    to_encode = {"exp": expire, "sub": str(sub), "type": "access"}
    encoded_jwt = jjwt.encode(to_encode, os.getenv("SECRET_KEY", "change-this-in-production"), algorithm="HS256")
    return encoded_jwt


def create_refresh_token(sub: Union[str, bytes], expires_delta: Optional[timedelta] = None) -> str:
    """Create a JWT refresh token."""
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(days=30)
    
    to_encode = {"exp": expire, "sub": str(sub), "type": "refresh"}
    encoded_jwt = jjwt.encode(to_encode, os.getenv("SECRET_KEY", "change-this-in-production"), algorithm="HS256")
    return encoded_jwt


def verify_refresh_token(token: str) -> Optional[str]:
    """Verify a refresh token and return the subject (user email)."""
    try:
        payload = jjwt.decode(
            token, 
            os.getenv("SECRET_KEY", "change-this-in-production"), 
            algorithms=["HS256"]
        )
        token_type: str = payload.get("type")
        if token_type != "refresh":
            return None
        email: str = payload.get("sub")
        if email is None:
            return None
        return email
    except (JWTError, Exception):
        return None


def authenticate_user(email: str, password: str) -> Optional[Model]:
    """Authenticate a user by email and password."""
    from app.models import User
    
    user = await User.filter(email=email).first()
    if not user:
        return None
    
    if not verify_password(password, user.hashed_password):
        return None
    
    return user