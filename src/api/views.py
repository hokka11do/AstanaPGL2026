from fastapi import APIRouter
from fastapi.responses import FileResponse

router = APIRouter()

@router.get('/')
async def index():
    return FileResponse('static/index.html')

@router.get('/teams')
async def teams():
    return FileResponse('static/teams.html')

@router.get("/teams/{team_slug}")
async def team(team_slug: str):
    return FileResponse("static/team.html")


@router.get("/players/{nickname}")
async def player(nickname: str):
    return FileResponse("static/player.html")


@router.get("/matches")
async def matches():
    return FileResponse("static/matches.html")


@router.get("/matches/{match_id}")
async def match(match_id: int):
    return FileResponse("static/match.html")


@router.get("/matches/{match_id}/maps/{map_id}")
async def map_view(match_id: int, map_id: int):
    return FileResponse("static/map.html")