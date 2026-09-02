from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.database import Base


class Caregiver(Base):
    __tablename__ = "caregiver"

    caregiver_id = Column(Integer, primary_key=True, index=True)

    user_id = Column(
        Integer,
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False
    )

    relationship_type = Column("relationship", String(50))

    user = relationship("User", backref="caregivers")