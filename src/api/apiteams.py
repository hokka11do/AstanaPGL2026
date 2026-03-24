from fastapi import APIRouter , HTTPException
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from src.database.database import SessionDep
from src.database.models.teams import Team
from src.database.models.players import Player

router = APIRouter()

# TEAMS
# TEAMS

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

@router.get('/teams/{team_slug}')
async def get_team(team_slug , ses: SessionDep):
    result = await ses.execute(select(Team).where(Team.slug == team_slug))
    team = result.scalar_one_or_none()

    if not team:
        raise HTTPException(status_code=404, detail='Team not found!')

    return {
        'id' : team.id,
        'name' : team.name,
        'slug' : team.slug,
        'country_code' : team.country_code,
        'flag_url' : f'/static/photos/{team.country_code.lower()}.svg',
        'region' : team.region,
        'logo_url' : team.logo_url,
        'description' : team.description
    }

@router.get('/players/{nickname}')
async def get_player_in_window(nickname , ses: SessionDep):
    result = await ses.execute(select(Player).options(selectinload(Player.team)).where(Player.nickname == nickname))
    player = result.scalar_one_or_none()

    if not player:
        raise HTTPException(status_code=404, detail='Player not found')
    
    return {
        "nickname": player.nickname,
        "real_name": player.real_name,
        "country_code": player.country_code,
        "flag_url" : f'/static/flags/{player.country_code.lower()}.svg',
        "role": player.role,
        "photo_url": player.photo_url,
        "team" : {
            "name" : player.team.name,
            "slug" : player.team.slug,
            "region" : player.team.region
        }
    }

    


