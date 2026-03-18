from sqlalchemy.orm import DeclarativeBase , mapped_column , Mapped
from sqlalchemy.ext.asyncio import create_async_engine , async_sessionmaker
from dotenv import load_dotenv
import os
from pydantic_settings import BaseSettings , SettingsConfigDict


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