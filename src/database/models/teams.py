from sqlalchemy.orm import Mapped , mapped_column , DeclarativeBase
from sqlalchemy import ForeignKey, String, Integer, Boolean, DateTime, func
from datetime import datetime
from enum import Enum
from sqlalchemy import Enum as SQLEnum


class Base(DeclarativeBase):
    pass

class RegionEnum(str, Enum):
    CIS = "CIS"
    EU = "EU"
    NA = "NA"
    SA = "SA"
    ASIA = "ASIA"


class Team(Base):
    __tablename__ = 'teams'

    id : Mapped[int] = mapped_column(primary_key=True) # ID

    name : Mapped[str] = mapped_column(String, nullable=False) # Название
    short_name: Mapped[str] = mapped_column(String, nullable=False) # Короткое название
    slug: Mapped[str] = mapped_column(String, unique=True, nullable=False) # Слаг для URL

    country_code: Mapped[str] = mapped_column(String(2), nullable=False) # Код страны
    region: Mapped[RegionEnum] = mapped_column(SQLEnum(RegionEnum), nullable=False) # Код региона

    logo_url: Mapped[str | None] = mapped_column(String, nullable=True) # Ссылка на логотип
    description: Mapped[str | None] = mapped_column(String, nullable=True) # Описание

    is_active: Mapped[bool] = mapped_column(Boolean , default=True) # Активна/Неактивна
    created_at : Mapped[datetime] = mapped_column(DateTime , server_default=func.now()) # Когда создана