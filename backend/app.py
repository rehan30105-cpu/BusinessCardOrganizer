"""Business Card Organizer Backend - FastAPI Application"""

import os
from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from tortoise.exceptions import ConfigurationError

from app.core.config import settings
from app.api.v1.auth import router as auth_router
from app.api.v1.contacts import router as contacts_router
from app.api.v1.dashboard import router as dashboard_router
from app.api.v1.health import router as health_router

# Import models to ensure Tortoise-ORM registration
import app.models  # noqa: F401

# Import Tortoise ORM initialization
from tortoise.contrib.fastapi import register_tortoise

# Initialize FastAPI app
app = FastAPI(
    title="Business Card Organizer API",
    description="Full-stack Business Card Organizer with offline-first iOS app and cloud backend",
    version="1.0.0",
    docs_url="/api/docs",
    redoc_url="/api/redoc",
)

# CORS middleware - configure for production
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE"],
    allow_headers=["Content-Type", "Authorization", "X-Request-ID"],
    expose_headers=["X-Request-ID", "X-Rate-Limit-Limit", "X-Rate-Limit-Remaining", "X-Reset-Time"],
)

# Include API v1 routers
app.include_router(auth_router, prefix="/api/v1/auth", tags=["Authentication"])
app.include_router(contacts_router, prefix="/api/v1/contacts", tags=["Contacts"])
app.include_router(dashboard_router, prefix="/api/v1/dashboard", tags=["Dashboard"])
app.include_router(health_router, prefix="/health", tags=["Health"])


# Global exception handler
@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": exc.detail,
            "status_code": exc.status_code,
            "request_id": getattr(request.state, "request_id", "unknown"),
        },
    )


@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    # In production, log the error but don't expose details
    return JSONResponse(
        status_code=500,
        content={
            "error": "Internal server error",
            "status_code": 500,
            "request_id": getattr(request.state, "request_id", "unknown"),
        },
    )


# Root endpoint
@app.get("/", tags=["Root"])
async def root() -> dict:
    return {
        "message": "Business Card Organizer API",
        "version": "1.0.0",
        "documentation": "/api/docs",
    }


# Health check endpoint
@app.get("/health", include_in_schema=False)
async def health_check() -> dict:
    return {"status": "healthy"}


# Setup Tortoise ORM
register_tortoise(
    app,
    db_url=settings.DATABASE_URL,
    modules={"models": ["app.models", "aeron.models"] if os.path.exists("aeron/models.py") else ["app.models"]},
    generate_schemas=False,
    add_exception_handlers=True,
)