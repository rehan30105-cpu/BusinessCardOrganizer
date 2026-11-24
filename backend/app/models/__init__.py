"""Database Models for Business Card Organizer Backend."""

from tortoise.models import ModelsMixin
from tortoise import fields


class User(models.Model):
    """User model representing authenticated accounts."""
    
    id = fields.CharField(max_length, primary_key=True, default=lambda: str(uuid4()))
    email = fields.CharField(max_length=254, unique=True)
    hashed_password = fields.CharField(max_length=128)
    is_active = fields.BooleanField(default=True)
    is_superuser = fields.BooleanField(default=False)
    created_at = fields.DatetimeField(auto_now_add=True)
    updated_at = fields.DatetimeField(auto_now=True)
    
    class PydanticMeta:
        computed = ["id"]
    
    class Meta:
        table = "users"


class Contact(models.Model):
    """Contact model representing a business contact."""
    
    id = fields.CharField(max_length=36, primary_key=True, default=lambda: str(uuid4()))
    full_name = fields.CharField(max_length=200)
    company = fields.CharField(max_length=200, default="")
    designation = fields.CharField(max_length=200, null=True)
    email = fields.CharField(max_length=254, null=True)
    phone = fields.CharField(max_length=50, null=True)
    website = fields.CharField(max_length=500, null=True)
    where_met = fields.CharField(max_length=500, null=True)
    notes = fields.TextField(null=True)
    is_favorite = fields.BooleanField(default=False)
    created_at = fields.DatetimeField(auto_now_add=True)
    updated_at = fields.DatetimeField(auto_now=True)
    
    # Foreign key to user who owns this contact
    owner = fields.ForeignKeyField("models.User", related_name="contacts")
    
    # Relationship tag
    tag = fields.CharField(max_length=50, default="colleague")
    
    class PydanticMeta:
        computed = ["id"]
    
    class Meta:
        table = "contacts"
        unique_together = [("owner", "email"), ("owner", "phone")]
    
    def __str__(self) -> str:
        return self.full_name


class RelationshipTag(models.Model):
    """Relationship tag model for contact categorization."""
    
    id = fields.CharField(max_length=36, primary_key=True, default=lambda: str(uuid4()))
    name = fields.CharField(max_length=50, unique=True)
    display_name = fields.CharField(max_length=50)
    icon_name = fields.CharField(max_length=100)
    background_color = fields.CharField(max_length=20, default="")
    text_color = fields.CharField(max_length=20, default="")
    created_at = fields.DatetimeField(auto_now_add=True)
    updated_at = fields.DatetimeField(auto_now=True)
    
    class PydanticMeta:
        computed = ["id"]
    
    class Meta:
        table = "relationship_tags"
    
    def __str__(self) -> str:
        return self.display_name


class RefreshToken(models.Model):
    """Refresh token model for token rotation and revocation."""
    
    id = fields.CharField(max_length=36, primary_key=True, default=lambda: str(uuid4()))
    token = fields.CharField(max_length=512, unique=True)
    user = fields.ForeignKeyField("models.User", related_name="refresh_tokens")
    expires_at = fields.DatetimeField()
    is_revoked = fields.BooleanField(default=False)
    created_at = fields.DatetimeField(auto_now_add=True)
    
    class PydanticMeta:
        computed = ["id"]
    
    class Meta:
        table = "refresh_tokens"


class AuditEvent(models.Model):
    """Audit event model for security and compliance logging."""
    
    id = fields.CharField(max_length=36, primary_key=True, default=lambda: str(uuid4()))
    user = fields.ForeignKeyField("models.User", related_name="audit_events", null=True)
    action = fields.CharField(max_length=100)
    resource_type = fields.CharField(max_length=50)
    resource_id = fields.CharField(max_length=36, null=True)
    details = fields.TextField(null=True)
    ip_address = fields.CharField(max_length=45, null=True)
    created_at = fields.DatetimeField(auto_now_add=True)
    
    class PydanticMeta:
        computed = ["id"]
    
    class Meta:
        table = "audit_events"