from sqlalchemy.orm import DeclarativeBase , mapped_column , Mapped
from sqlalchemy.ext.asyncio import create_async_engine , async_sessionmaker , AsyncSession
from pydantic_settings import BaseSettings , SettingsConfigDict
from fastapi import Depends
from typing import Annotated


class Settings(BaseSettings):
    DATABASE_URL : str

    model_config = SettingsConfigDict(env_file='.env', extra='ignore')

settings = Settings()


engine = create_async_engine(settings.DATABASE_URL)

session = async_sessionmaker(
    engine,
    expire_on_commit = False,
    class_ = AsyncSession
)

class Base(DeclarativeBase):
    pass

async def get_session():
    async with session() as s:
        yield s

SessionDep = Annotated[AsyncSession , Depends(get_session)]