from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.database import get_db
from app.models import User, Reminder

from app.schemas.reminder import (
    ReminderCreate,
    ReminderUpdate,
    ReminderResponse
)


router = APIRouter(
    prefix="/api/reminders",
    tags=["Reminders"]
)


@router.post("/", response_model=ReminderResponse)
def create_reminder(
    reminder: ReminderCreate,
    db: Session = Depends(get_db)
):

    # Check whether user exists
    user = db.query(User).filter(
        User.user_id == reminder.user_id
    ).first()

    if not user:
        raise HTTPException(
            status_code=404,
            detail="User not found"
        )

    new_reminder = Reminder(
        user_id=reminder.user_id,
        reminder_type=reminder.reminder_type,
        message=reminder.message,
        scheduled_time=reminder.scheduled_time
    )

    db.add(new_reminder)
    db.commit()
    db.refresh(new_reminder)

    return new_reminder


@router.get("/", response_model=list[ReminderResponse])
def get_reminders(
    db: Session = Depends(get_db)
):
    return db.query(Reminder).all()


@router.get("/{reminder_id}", response_model=ReminderResponse)
def get_reminder(
    reminder_id: int,
    db: Session = Depends(get_db)
):

    reminder = db.query(Reminder).filter(
        Reminder.reminder_id == reminder_id
    ).first()

    if not reminder:
        raise HTTPException(
            status_code=404,
            detail="Reminder not found"
        )

    return reminder


@router.patch("/{reminder_id}", response_model=ReminderResponse)
def update_reminder(
    reminder_id: int,
    reminder_data: ReminderUpdate,
    db: Session = Depends(get_db)
):

    reminder = db.query(Reminder).filter(
        Reminder.reminder_id == reminder_id
    ).first()

    if not reminder:
        raise HTTPException(
            status_code=404,
            detail="Reminder not found"
        )

    if reminder_data.reminder_type is not None:
        reminder.reminder_type = reminder_data.reminder_type

    if reminder_data.message is not None:
        reminder.message = reminder_data.message

    if reminder_data.scheduled_time is not None:
        reminder.scheduled_time = reminder_data.scheduled_time

    if reminder_data.completed is not None:
        reminder.completed = reminder_data.completed

    db.commit()
    db.refresh(reminder)

    return reminder