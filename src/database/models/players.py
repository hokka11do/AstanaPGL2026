from sqlalchemy.orm import Mapped , mapped_column , DeclarativeBase, relationship
from sqlalchemy import ForeignKey, String, Integer, Boolean, DateTime, func
from datetime import datetime
from enum import Enum
from sqlalchemy import Enum as SAEnum
from src.database.models.teams import Base
from sqlalchemy import Text


class PlayerRoleEnum(str, Enum):
    RIFLER = "rifler"
    SNIPER = "sniper"
    IGL = "igl"
    SUPPORT = "support"
    ENTRY = "entry"


class Player(Base):
    __tablename__ = "players"

    id: Mapped[int] = mapped_column(primary_key=True)

    nickname: Mapped[str] = mapped_column(String, unique=True, nullable=False)
    real_name: Mapped[str] = mapped_column(String, nullable=False)

    country_code: Mapped[str] = mapped_column(String(2), nullable=False)

    role: Mapped[PlayerRoleEnum] = mapped_column(
        SAEnum(PlayerRoleEnum),
        nullable=True
    )

    description : Mapped[str | None] = mapped_column(Text , nullable=True)

    photo_url: Mapped[str] = mapped_column(String, nullable=True)

    team_id: Mapped[int] = mapped_column(
        ForeignKey("teams.id", ondelete="SET NULL"),
        nullable=True
    )

    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    created_at: Mapped[datetime] = mapped_column(
        DateTime,
        server_default=func.now()
    )

    team = relationship("Team", back_populates="players")

    player_stat = relationship('PlayerStats' , back_populates = 'player')