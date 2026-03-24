from fastapi import APIRouter
from sqlalchemy import select
from src.database.database import SessionDep
from src.database.models.teams import Team
from src.database.models.players import Player

router = APIRouter()

@router.get('/teams')
async def get_teams(ses: SessionDep):
    result = await ses.execute(select(Team))
    teams = result.scalars().all()
    return [
        {'name' : team.name,
         'country_code' : team.country_code,
         'short_name' : team.short_name,
         'region' : team.region,
         'logo_url' : team.logo_url}
         for team in teams
    ]


