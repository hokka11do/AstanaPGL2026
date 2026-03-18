from sqlalchemy.orm import DeclarativeBase , mapped_column , Mapped
from sqlalchemy.ext.asyncio import create_async_engine , async_sessionmaker , AsyncSession
from dotenv import load_dotenv
import os
from pydantic_settings import BaseSettings , SettingsConfigDict
from fastapi import Depends
from typing import Annotated


class Settings(BaseSettings):
    DB_USER : str
    DB_PASSWORD : str
    DB_HOST : str
    DB_PORT : int
    DB_NAME : str

    model_config = SettingsConfigDict(env_file='.env')

settings = Settings()


engine = create_async_engine(f'postgresql+asyncpg://{settings.DB_USER}:{settings.DB_PASSWORD}'
                             f'@{settings.DB_HOST}:{settings.DB_PORT}/{settings.DB_NAME}')

session = async_sessionmaker(
    engine,
    expire_on_commit = False,
    class_ = AsyncSession
)

async def get_session():
    async with session() as s:
        yield s

SessionDep = Annotated[AsyncSession , Depends(get_session)]