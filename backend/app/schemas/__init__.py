"""Pydantic Schemas for Business Card Organizer Backend."""

from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime


# Authentication schemas


class UserRegister(BaseModel):
    """Schema for user registration."""
    email: str = Field(..., description="User email address")
    password: str = Field(..., min_length=8, description="User password")
    full_name: str = Field(..., description="User full name")
    
    @validator("email")
    def validate_email_format(cls, v):
        if "@" not in v:
            raise ValueError("Invalid email format")
        return v


class UserLogin(BaseModel):
    """Schema for user login."""
    email: str = Field(..., description="User email address")
    password: str = Field(..., description="User password")


class UserResponse(BaseModel):
    """Schema for user response."""
    id: str
    email: str
    full_name: str
    is_active: bool
    created_at: datetime
    
    class Config:
        from_attributes = True


# Contact schemas


class ContactCreate(BaseModel):
    """Schema for creating a contact."""
    full_name: str = Field(..., min_length=1, max_length=200, description="Contact full name")
    company: str = Field(default="", max_length=200, description="Company name")
    designation: Optional[str] = Field(default=None, max_length=200, description="Job title")
    email: Optional[str] = Field(default=None, max_length=254, description="Email address")
    phone: Optional[str] = Field(default=None, max_length=50, description="Phone number")
    website: Optional[str] = Field(default=None, max_length=500, description="Website URL")
    where_met: Optional[str] = Field(default=None, max_length=500, description="Where met")
    notes: Optional[str] = Field(default=None, description="Notes")
    is_favorite: bool = Field(default=False, description="Favorite status")
    tag: str = Field(default="colleague", max_length=50, description="Relationship tag")
    
    @validator("email", allow_reuse=True)
    def validate_email(cls, v):
        if v is not None and "@" not in v:
            raise ValueError("Invalid email format")
        return v
    
    @validator("phone", allow_reuse=True)
    def validate_phone(cls, v):
        if v is not None and not v.replace(" ", "").replace("+", "").replace("-", "").replace("(", "").replace(")", "").isdigit():
            raise ValueError("Invalid phone format")
        return v


class ContactUpdate(BaseModel):
    """Schema for updating a contact."""
    full_name: Optional[str] = Field(default=None, min_length=1, max_length=200)
    company: Optional[str] = Field(default=None, max_length=200)
    designation: Optional[str] = Field(default=None, max_length=200)
    email: Optional[str] = Field(default=None, max_length=254)
    phone: Optional[str] = Field(default=None, max_length=50)
    website: Optional[str] = Field(default=None, max_length=500)
    where_met: Optional[str] = Field(default=None, max_length=500)
    notes: Optional[str] = Field(default=None)
    is_favorite: Optional[bool] = Field(default=None)
    tag: Optional[str] = Field(default=None, max_length=50)


class ContactResponse(BaseModel):
    """Schema for contact response."""
    id: str
    full_name: str
    company: str
    designation: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None
    website: Optional[str] = None
    where_met: Optional[str] = None
    notes: Optional[str] = None
    is_favorite: bool
    tag: str
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True


# Tag schemas


class TagCreate(BaseModel):
    """Schema for creating a relationship tag."""
    name: str = Field(..., max_length=50, description="Tag internal name")
    display_name: str = Field(..., max_length=50, description="Tag display name")
    icon_name: str = Field(..., max_length=100, description="SF Symbols icon name")
    background_color: str = Field(default="", max_length=20, description="Background color hex")
    text_color: str = Field(default="", max_length=20, description="Text color hex")


class TagResponse(BaseModel):
    """Schema for tag response."""
    id: str
    name: str
    display_name: str
    icon_name: str
    background_color: str
    text_color: str
    
    class Config:
        from_attributes = True


# Refresh token schemas


class TokenRefresh(BaseModel):
    """Schema for token refresh."""
    refresh_token: str = Field(..., description="Refresh token")


class TokenResponse(BaseModel):
    """Schema for token response."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int


# Dashboard schemas


class DashboardSummary(BaseModel):
    """Schema for dashboard summary."""
    total_contacts: int
    favorite_contacts: int
    recent_contacts: int
    tags_distribution: dict


# Health schemas


class HealthCheck(BaseModel):
    """Schema for health check."""
    status: str
    database: str
    redis: str