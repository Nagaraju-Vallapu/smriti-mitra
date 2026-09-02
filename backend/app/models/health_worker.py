from sqlalchemy import Column, Integer, String, ForeignKey
from sqlalchemy.orm import relationship

from app.database import Base


class HealthWorker(Base):
    __tablename__ = "health_worker"

    worker_id = Column(Integer, primary_key=True, index=True)

    user_id = Column(
        Integer,
        ForeignKey("users.user_id", ondelete="CASCADE"),
        nullable=False
    )

    specialization = Column(String(100))

    user = relationship("User", backref="health_worker")