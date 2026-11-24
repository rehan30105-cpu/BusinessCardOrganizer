"""Authentication API Routes for Business Card Organizer Backend."""

import uuid
from datetime import datetime, timedelta

from fastapi import APIRouter, HTTPException, status
from tortoise.exceptions import IntegrityError

from app.core.config import settings
from app.core.security import authenticate_user, create_access_token, create_refresh_token, verify_refresh_token
from app.schemas.auth import UserRegister, UserLogin, UserResponse, TokenResponse


router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserRegister):
    """Register a new user account."""
    from app.models import User

    try:
        user = await User.create(
            id=uuid.uuid4().hex,
            email=user_data.email,
            hashed_password=user_data.password,  # In production, hash the password
            full_name=user_data.full_name,
        )
        return UserResponse(
            id=user.id,
            email=user.email,
            full_name=user.full_name,
            is_active=user.is_active,
            created_at=user.created_at,
        )
    except IntegrityError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )


@router.post("/login", response_model=TokenResponse)
async def login(form_data: OAuth2PasswordRequestForm = ...) -> TokenResponse:
    """Login and obtain access/refresh tokens."""
    from app.models import User

    user = await authenticate_user(form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )

    access_token = create_access_token(sub=user.email)
    refresh_token = create_refresh_token(sub=user.email)

    # Revoke old refresh tokens for this user
    await RefreshToken.filter(user=user).update(is_revoked=True)

    # Save new refresh token
    rt = await RefreshToken.create(
        id=uuid.uuid4().hex,
        token=refresh_token,
        user=user,
        expires_at=datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
    )

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh_token_endpoint(refresh_data: TokenRefresh):
    """Refresh access token using refresh token."""
    from app.models import User, RefreshToken

    # Verify refresh token
    user_email = await verify_refresh_token(refresh_data.refresh_token)
    if not user_email:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )

    # Get the user
    user = await User.get_or_none(email=user_email)
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found or deactivated",
        )

    # Revoke old token and create new one
    await RefreshToken.filter(token=refresh_data.refresh_token).update(is_revoked=True)

    new_access_token = create_access_token(sub=user.email)
    new_refresh_token = create_refresh_token(sub=user.email)

    await RefreshToken.create(
        id=uuid.uuid4().hex,
        token=new_refresh_token,
        user=user,
        expires_at=datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS),
    )

    return TokenResponse(
        access_token=new_access_token,
        refresh_token=new_refresh_token,
        expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    )


@router.get("/me", response_model=UserResponse)
async def get_current_user():
    """Get current user profile."""
    raise HTTPException(
        status_code=status.HTTP_501_NOT_IMPLEMENTED,
        detail="Authentication dependency not fully implemented",
    )