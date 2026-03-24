from fastapi import APIRouter
from src.api.apiteams import router as teams_router


main_router = APIRouter()

main_router.include_router(teams_router)