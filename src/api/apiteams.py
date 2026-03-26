from fastapi import APIRouter , HTTPException
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from src.database.database import SessionDep
from src.database.models.teams import Team
from src.database.models.players import Player
from src.database.models.matches import Match

router = APIRouter()

# TEAMS
# TEAMS

@router.get('/teams')
async def get_teams(ses: SessionDep):
    result = await ses.execute(select(Team))
    teams = result.scalars().all()
    return [
        {'name' : team.name,
         'slug' : team.slug,
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
        'flag_url' : f'/static/flags/{team.country_code.lower()}.svg',
        'region' : team.region,
        'logo_url' : team.logo_url,
        'description' : team.description
    }

@router.get('/teams/{team_slug}/players')
async def get_team_players(team_slug , ses: SessionDep):
    result = await ses.execute(select(Player).options(selectinload(Player.team)).join(Team).where(Team.slug == team_slug, Player.is_active == True))
    players = result.scalars().all()

    if not players:
        raise HTTPException(status_code=404, detail='Players not found')
    
    return [
        {
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
        for player in players
    ]

@router.get('/teams/{team_slug}/players/{nickname}')
async def get_player(team_slug: str , nickname , ses: SessionDep):
    result = await ses.execute(select(Player)
                               .options(selectinload(Player.team))
                               .join(Team)
                               .where(Team.slug == team_slug , Player.nickname == nickname, Player.is_active == True)
                              )
    player = result.scalar_one_or_none()

    if not player:
        raise HTTPException(status_code=404, detail='Player not found')
    
    return {
        'nickname' : player.nickname,
        'real_name' : player.real_name,
        'country_code' : player.country_code,
        'flag_url' : f'/static/flags/{player.country_code.lower()}.svg',
        'role' : player.role,
        'description' : player.description,
        'photo_url' : player.photo_url,
        'team' : {
            'name' : player.team.name,
            'short_name' : player.team.short_name,
            'country_code' : player.team.country_code,
            'region' : player.team.region,
            'logo_url' : player.team.logo_url
        }
    }


@router.get('/matches')
async def get_matches(ses: SessionDep):
    result = await ses.execute(select(Match).options(selectinload(Match.team1),selectinload(Match.team2),selectinload(Match.winner)))
    matches = result.scalars().all()

    return [
        {
            'id' : match.id,
            'team1' : {
                'name' : match.team1.name,
                'short_name' : match.team1.short_name,
                'country_code' : match.team1.country_code,
                'flag_url' : f'/static/flags/{match.team1.country_code.lower()}.svg',
                'logo_url' : match.team1.logo_url
            },
            'team2' : {
                'name' : match.team2.name,
                'short_name' : match.team2.short_name,
                'country_code' : match.team2.country_code,
                'flag_url' : f'/static/flags/{match.team2.country_code.lower()}.svg',
                'logo_url' : match.team2.logo_url
            },
            'start_time' : match.start_time,
            'bo_type' : match.bo_type.value,
            'stage' : match.stage.value,
            'status' : match.status.value,
            'score_team1' : match.score_team1,
            'score_team2' : match.score_team2,
            'winner' : (
                    {
                    'name' : match.winner.name,
                    'flag_url' : f'/static/flags/{match.winner.country_code.lower()}.svg',
                    'logo_url' : match.winner.logo_url
                    } if match.winner else None
                        ),
            'stream_url' : match.stream_url
        }
        for match in matches
    ]

    


