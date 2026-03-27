from fastapi import APIRouter , HTTPException
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from src.database.database import SessionDep
from src.database.models.teams import Team
from src.database.models.players import Player
from src.database.models.matches import Match , MatchMap , PlayerStats

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
        },
        'is_active' : player.is_active
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
                'logo_url' : match.team1.logo_url
            },
            'team2' : {
                'name' : match.team2.name,
                'logo_url' : match.team2.logo_url
            },
            'start_time' : match.start_time,
            'bo_type' : match.bo_type.value,
            'stage' : match.stage.value,
            'status' : match.status.value,
            'score_team1' : match.score_team1,
            'score_team2' : match.score_team2
        }
        for match in matches
    ]

@router.get('/matches/{match_id}')
async def get_match_by_id(match_id : int, ses: SessionDep):
    result = await ses.execute(select(Match).options(selectinload(Match.team1),selectinload(Match.team2),selectinload(Match.winner),selectinload(Match.maps).selectinload(MatchMap.winner),selectinload(Match.maps).selectinload(MatchMap.picked_by_team)).where(Match.id == match_id))
    match = result.scalar_one_or_none()

    if not match:
        raise HTTPException(status_code=404 , detail='Match not found in Database!')
    
    return {
        'id' : match.id,
        'team1' : {
                'name' : match.team1.name,
                'short_name' : match.team1.short_name,
                'country_code' : match.team1.country_code,
                'flag_url' : f'/static/flags/{match.team1.country_code.lower()}.svg',
                'region' : match.team1.region,  
                'logo_url' : match.team1.logo_url
            },
        'team2' : {
                'name' : match.team2.name,
                'short_name' : match.team2.short_name,
                'country_code' : match.team2.country_code,
                'flag_url' : f'/static/flags/{match.team2.country_code.lower()}.svg',
                'region' : match.team2.region,
                'logo_url' : match.team2.logo_url
            },
            'start_time' : match.start_time,
            'bo_type' : match.bo_type.value,
            'stage' : match.stage.value,
            'status' : match.status.value,
            'score_team1' : match.score_team1,
            'score_team2' : match.score_team2,
            'winner': (
            {
                'name': match.winner.name,
                'logo_url': match.winner.logo_url,
                'flag_url': f'/static/flags/{match.winner.country_code.lower()}.svg'
            }
            if match.winner else None
        ),
            'maps' : [
                {
                    'id' : match_map.id,
                    'map_order' : match_map.map_order,
                    'map_name' : match_map.map_name.value,
                    'team1' : {
                        'name' : match.team1.name,
                        'logo_url' : match.team1.logo_url
                    },
                    'team2' : {
                        'name' : match.team2.name,
                        'logo_url' : match.team2.logo_url
                    },
                    'score_team1' : match_map.score_team1,
                    'score_team2' : match_map.score_team2,
                    'winner' : ( {
                        'name' : match_map.winner.name,
                        'logo_url' : match_map.winner.logo_url
                    } if match_map.winner else None
                ),
                    'picked_by' : (
                        {
                            'name' : match_map.picked_by_team.name,
                            'logo_url' : match_map.picked_by_team.logo_url
                        }
                        if match_map.picked_by_team else
                        {
                            'name' : 'Decider',
                            'logo_url' : None
                        }
                    )
                }
                for match_map in match.maps
            ]

    }

@router.get('/matches/{match_id}/maps/{match_map_id}')
async def get_match_map_by_id(match_id: int, match_map_id: int, ses: SessionDep):
    result = await ses.execute(
        select(MatchMap).options(
            selectinload(MatchMap.match).selectinload(Match.team1),
            selectinload(MatchMap.match).selectinload(Match.team2),
            selectinload(MatchMap.picked_by_team),
            selectinload(MatchMap.winner),
            selectinload(MatchMap.player_stat).selectinload(PlayerStats.player)
        ).where(
            MatchMap.id == match_map_id,
            MatchMap.match_id == match_id
        )
    )
    match_map = result.scalar_one_or_none()

    if not match_map:
        raise HTTPException(status_code=404, detail='Match map not found in database!')

    team1_stats = [
        {
            'id': player_stat.player.id,
            'nickname': player_stat.player.nickname,
            'real_name': player_stat.player.real_name,
            'photo_url': player_stat.player.photo_url,
            'kills': player_stat.kills,
            'deaths': player_stat.deaths,
            'assists': player_stat.assists,
            'adr': player_stat.adr,
            'kast': player_stat.kast,
            'rating': player_stat.rating,
            'hs_percentage': player_stat.hs_percentage
        }
        for player_stat in match_map.player_stat
        if player_stat.player.team_id == match_map.match.team1_id
    ]

    team2_stats = [
        {
            'id': player_stat.player.id,
            'nickname': player_stat.player.nickname,
            'real_name': player_stat.player.real_name,
            'photo_url': player_stat.player.photo_url,
            'kills': player_stat.kills,
            'deaths': player_stat.deaths,
            'assists': player_stat.assists,
            'adr': player_stat.adr,
            'kast': player_stat.kast,
            'rating': player_stat.rating,
            'hs_percentage': player_stat.hs_percentage
        }
        for player_stat in match_map.player_stat
        if player_stat.player.team_id == match_map.match.team2_id
    ]

    return {
        'id': match_map.id,
        'match_id': match_map.match_id,
        'map_order': match_map.map_order,
        'map_name': match_map.map_name.value,
        'picked_by_team': (
            {
                'name': match_map.picked_by_team.name,
                'logo_url': match_map.picked_by_team.logo_url
            }
            if match_map.picked_by_team else
            {
                'name': 'decider',
                'logo_url': None
            }
        ),
        'score_team1': match_map.score_team1,
        'score_team2': match_map.score_team2,
        'winner': (
            {
                'name': match_map.winner.name,
                'logo_url': match_map.winner.logo_url,
                'country_code': match_map.winner.country_code,
                'flag_url': f'/static/flags/{match_map.winner.country_code.lower()}.svg',
                'region': match_map.winner.region,
                'short_name': match_map.winner.short_name
            }
            if match_map.winner else None
        ),
        'team1': {
            'name': match_map.match.team1.name,
            'logo_url': match_map.match.team1.logo_url,
            'country_code': match_map.match.team1.country_code,
            'flag_url': f'/static/flags/{match_map.match.team1.country_code.lower()}.svg',
            'region': match_map.match.team1.region,
            'short_name': match_map.match.team1.short_name,
            'players_stats': team1_stats
        },
        'team2': {
            'name': match_map.match.team2.name,
            'logo_url': match_map.match.team2.logo_url,
            'country_code': match_map.match.team2.country_code,
            'flag_url': f'/static/flags/{match_map.match.team2.country_code.lower()}.svg',
            'region': match_map.match.team2.region,
            'short_name': match_map.match.team2.short_name,
            'players_stats': team2_stats
        }
    }

    


