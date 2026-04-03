from fastapi import APIRouter
from src.api.apiteams import router as teams_router
from src.api.views import router as views_router


main_router = APIRouter()

main_router.include_router(teams_router, prefix='/api')
main_router.include_router(views_router)