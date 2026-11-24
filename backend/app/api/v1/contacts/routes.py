"""Contact Management API Routes for Business Card Organizer Backend."""

from fastapi import APIRouter, Depends, HTTPException, status
from tortoise.exceptions import IntegrityError
from tortoise.query_utils import Q

from app.core.config import settings
from app.core.security import get_current_user_from_token
from app.models import User, Contact, RelationshipTag
from app.schemas.contact import ContactCreate, ContactUpdate, ContactResponse

router = APIRouter(prefix="/contacts", tags=["Contacts"])


@router.get(
    "",
    response_model=dict,
    summary="List contacts with pagination, search, and filtering",
)
async def list_contacts(
    page: int = 1,
    page_size: int = 20,
    search: str = "",
    tag: str = "",
    favorite_only: bool = False,
    current_user: User = Depends(get_current_user_from_token),
):
    """List contacts with pagination, search, and filtering.

    Supports:
    - Search by name, company, email, or phone
    - Filter by relationship tag
    - Filter by favorite status
    """
    # Build query filtering by owner (user isolation)
    query = Contact.filter(owner=current_user)

    # Apply tag filter
    if tag:
        query = query.filter(tag=tag)

    # Apply favorite filter
    if favorite_only:
        query = query.filter(is_favorite=True)

    # Apply search filter
    if search:
        search_lower = search.lower()
        query = query.filter(
            Q(full_name__icontains=search_lower)
            | Q(company__icontains=search_lower)
            | Q(email__icontains=search_lower)
            | Q(phone__icontains=search_lower)
        )

    # Apply pagination
    total = await query.count()
    contacts = await query.offset((page - 1) * page_size).limit(page_size).order_by("-created_at")

    result = []
    for contact in contacts:
        # Get tag display info
        tag_obj, _ = await RelationshipTag.get_or_create(name=contact.tag, defaults={
            "display_name": contact.tag.capitalize(),
            "icon_name": "tag",
        })
        contact_dict = {
            "id": contact.id,
            "full_name": contact.full_name,
            "company": contact.company,
            "designation": contact.designation,
            "email": contact.email,
            "phone": contact.phone,
            "website": contact.website,
            "where_met": contact.where_met,
            "notes": contact.notes,
            "is_favorite": contact.is_favorite,
            "tag": contact.tag,
            "tag_display_name": tag_obj.display_name,
            "tag_icon_name": tag_obj.icon_name,
            "created_at": contact.created_at,
            "updated_at": contact.updated_at,
        }
        result.append(contact_dict)

    return {
        "items": result,
        "total": total,
        "page": page,
        "page_size": page_size,
        "total_pages": (total + page_size - 1) // page_size,
    }


@router.get(
    "/{contact_id}",
    response_model=ContactResponse,
    summary="Get contact by ID",
)
async def get_contact(
    contact_id: str,
    current_user: User = Depends(get_current_user_from_token),
):
    """Get a specific contact by ID."""
    contact = await Contact.filter(id=contact_id, owner=current_user).first()
    if not contact:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Contact not found",
        )

    # Get tag display info
    tag_obj, _ = await RelationshipTag.get_or_create(name=contact.tag, defaults={
        "display_name": contact.tag.capitalize(),
        "icon_name": "tag",
    })

    return ContactResponse(
        id=contact.id,
        full_name=contact.full_name,
        company=contact.company,
        designation=contact.designation,
        email=contact.email,
        phone=contact.phone,
        website=contact.website,
        where_met=contact.where_met,
        notes=contact.notes,
        is_favorite=contact.is_favorite,
        tag=contact.tag,
        tag_display_name=tag_obj.display_name,
        tag_icon_name=tag_obj.icon_name,
        created_at=contact.created_at,
        updated_at=contact.updated_at,
    )


@router.post(
    "",
    response_model=ContactResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Create a new contact",
)
async def create_contact(
    contact_data: ContactCreate,
    current_user: User = Depends(get_current_user_from_token),
):
    """Create a new contact.

    Required fields validation:
    - Full name (required)
    - Phone validation
    - Email validation
    - Duplicate contact warning
    """
    from tortoise.query_utils import Q

    # Validate required fields
    if not contact_data.full_name.strip():
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Full name is required",
        )

    # Validate email format if provided
    if contact_data.email and "@" not in contact_data.email:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid email format",
        )

    # Validate phone format if provided
    if contact_data.phone:
        cleaned_phone = contact_data.phone.replace(" ", "").replace("+", "").replace("-", "").replace("(", "").replace(")", "")
        if not cleaned_phone.isdigit():
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid phone format",
            )

    # Check for duplicate contact (same email or phone for same user)
    if contact_data.email:
        existing_by_email = await Contact.filter(
            owner=current_user, email=contact_data.email
        ).first()
        if existing_by_email:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="A contact with this email already exists",
            )

    if contact_data.phone:
        existing_by_phone = await Contact.filter(
            owner=current_user, phone=contact_data.phone
        ).first()
        if existing_by_phone:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="A contact with this phone number already exists",
            )

    # Create the contact
    tag_obj, _ = await RelationshipTag.get_or_create(
        name=contact_data.tag,
        defaults={
            "display_name": contact_data.tag.capitalize(),
        }
    )

    contact = await Contact.create(
        id=uuid.uuid4().hex,
        full_name=contact_data.full_name,
        company=contact_data.company,
        designation=contact_data.designation,
        email=contact_data.email,
        phone=contact_data.phone,
        website=contact_data.website,
        where_met=contact_data.where_met,
        notes=contact_data.notes,
        is_favorite=contact_data.is_favorite,
        tag=contact_data.tag,
        owner=current_user,
    )

    return ContactResponse(
        id=contact.id,
        full_name=contact.full_name,
        company=contact.company,
        designation=contact.designation,
        email=contact.email,
        phone=contact.phone,
        website=contact.website,
        where_met=contact.where_met,
        notes=contact.notes,
        is_favorite=contact.is_favorite,
        tag=contact.tag,
        tag_display_name=tag_obj.display_name,
        tag_icon_name=tag_obj.icon_name,
        created_at=contact.created_at,
        updated_at=contact.updated_at,
    )