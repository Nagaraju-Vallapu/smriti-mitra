from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User, ElderlyProfile
from app.schemas.elderly_profile import (
    ElderlyProfileCreate,
    ElderlyProfileResponse
)


router = APIRouter(
    prefix="/api/elderly-profiles",
    tags=["Elderly Profiles"]
)


@router.post("/", response_model=ElderlyProfileResponse)
def create_elderly_profile(
    profile: ElderlyProfileCreate,
    db: Session = Depends(get_db)
):

    # Check whether user exists
    user = db.query(User).filter(
        User.user_id == profile.user_id
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    # Check whether profile already exists
    existing_profile = db.query(ElderlyProfile).filter(
        ElderlyProfile.user_id == profile.user_id
    ).first()

    if existing_profile:
        raise HTTPException(
            status_code=400,
            detail="Elderly profile already exists for this user"
        )

    new_profile = ElderlyProfile(
        user_id=profile.user_id,
        age=profile.age,
        accessibility_mode=profile.accessibility_mode,
        emergency_contact=profile.emergency_contact,
        preferred_language=profile.preferred_language
    )

    db.add(new_profile)
    db.commit()
    db.refresh(new_profile)

    return new_profile


@router.get("/", response_model=list[ElderlyProfileResponse])
def get_elderly_profiles(
    db: Session = Depends(get_db)
):
    return db.query(ElderlyProfile).all()


@router.get("/{profile_id}", response_model=ElderlyProfileResponse)
def get_elderly_profile(
    profile_id: int,
    db: Session = Depends(get_db)
):

    profile = db.query(ElderlyProfile).filter(
        ElderlyProfile.profile_id == profile_id
    ).first()

    if not profile:
        raise HTTPException(
            status_code=404,
            detail="Elderly profile not found"
        )

    return profile