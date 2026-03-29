from fastapi import APIRouter , HTTPException
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from src.database.database import SessionDep , session
from src.database.models.teams import Team
from src.database.models.players import Player , PlayerHLTVStats
from src.database.models.matches import Match , MatchMap , PlayerStats
from datetime import timedelta , datetime
from bs4 import BeautifulSoup
from typing import Optional
import re
import httpx


router = APIRouter()

CACHE_TTL = timedelta(hours=12)

# TEAMS
# TEAMS


def _to_float(value: str) -> Optional[float]:
    if not value:
        return None

    value = value.strip()
    value = value.replace("%", "")
    value = value.replace(",", ".")

    match = re.search(r"\d+(?:\.\d+)?", value)
    if not match:
        return None

    return float(match.group())


def _extract_summary_stats(summary_text: str) -> dict:

    text = " ".join(summary_text.split()).upper()

    rating_match = re.search(r"(\d+(?:\.\d+)?)\s+RATING(?:\s+3\.0|\s+2\.0)?", text)
    kast_match = re.search(r"(\d+(?:\.\d+)?)%\s+KAST", text)
    adr_match = re.search(r"(\d+(?:\.\d+)?)\s+ADR", text)
    kpr_match = re.search(r"(\d+(?:\.\d+)?)\s+KPR", text)
    dpr_match = re.search(r"(\d+(?:\.\d+)?)\s+DPR", text)

    return {
        "rating": float(rating_match.group(1)) if rating_match else None,
        "kast": float(kast_match.group(1)) if kast_match else None,
        "adr": float(adr_match.group(1)) if adr_match else None,
        "kpr": float(kpr_match.group(1)) if kpr_match else None,
        "dpr": float(dpr_match.group(1)) if dpr_match else None,
    }


def _extract_impact_from_statistics(statistics_text: str) -> Optional[float]:


    text = " ".join(statistics_text.split())
    match = re.search(r"Impact rating\s+(\d+(?:\.\d+)?)", text, flags=re.IGNORECASE)

    if not match:
        return None

    return float(match.group(1))


async def parse_hltv_player_stats(url: str) -> dict:
    headers = {
    "User-Agent": (
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
        "AppleWebKit/537.36 (KHTML, like Gecko) "
        "Chrome/146.0.0.0 Safari/537.36"
    ),
    "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9,ru;q=0.8",
    "Cache-Control": "no-cache",
    "Pragma": "no-cache",
    "Referer": "https://www.hltv.org/",
}

    async with httpx.AsyncClient(headers=headers, timeout=20.0, follow_redirects=True) as client:
        response = await client.get(url)
        response.raise_for_status()

    soup = BeautifulSoup(response.text, "html.parser")

    summary_box = soup.select_one("div.player-summary-stat-box.compact")
    if not summary_box:
        raise ValueError("Не найден блок player-summary-stat-box compact")

    statistics_block = soup.select_one("div.statistics")
    if not statistics_block:
        raise ValueError("Не найден блок statistics")

    summary_text = summary_box.get_text(" ", strip=True)
    statistics_text = statistics_block.get_text(" ", strip=True)

    summary_stats = _extract_summary_stats(summary_text)
    impact = _extract_impact_from_statistics(statistics_text)

    return {
        "rating": summary_stats["rating"],
        "adr": summary_stats["adr"],
        "kast": summary_stats["kast"],
        "kpr": summary_stats["kpr"],
        "dpr": summary_stats["dpr"],
        "impact": impact,
    }




async def get_or_update_player_hltv_stats(player: Player , ses : AsyncSession):
    stats = await ses.scalar(select(PlayerHLTVStats).where(PlayerHLTVStats.player_id == player.id))

    now = datetime.utcnow()

    if stats and stats.updated_at and now - stats.updated_at < CACHE_TTL:
        return stats
    
    parsed = await parse_hltv_player_stats(player.hltv_url)

    if not stats:
        stats = PlayerHLTVStats(player_id = player.id)
        ses.add(stats)
    
    stats.rating = parsed['rating']
    stats.adr = parsed['adr']
    stats.kast = parsed['kast']
    stats.kpr = parsed['kpr']
    stats.dpr = parsed['dpr']
    stats.impact = parsed['impact']
    stats.updated_at = now

    await ses.commit()
    await ses.refresh(stats)

    return stats



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
                               .options(selectinload(Player.team), selectinload(Player.hltv_stats))
                               .join(Team)
                               .where(Team.slug == team_slug , Player.nickname == nickname, Player.is_active == True)
                              )
    player = result.scalar_one_or_none()

    if not player:
        raise HTTPException(status_code=404, detail='Player not found')
    
    stats = None

    if player.hltv_url:
        try:
            stats_obj = await get_or_update_player_hltv_stats(player, ses)

            stats = {
                'rating': stats_obj.rating,
                'adr': stats_obj.adr,
                'kast': stats_obj.kast,
                'kpr': stats_obj.kpr,
                'dpr': stats_obj.dpr,
                'impact': stats_obj.impact,
                'updated_at': stats_obj.updated_at
            }
        except Exception as e:
            print(f'HLTV stats error for {player.nickname}: {e}')
            stats = None
    
    return {
        'nickname' : player.nickname,
        'real_name' : player.real_name,
        'country_code' : player.country_code,
        'flag_url' : f'/static/flags/{player.country_code.lower()}.svg',
        'role' : player.role,
        'description' : player.description,
        'photo_url' : player.photo_url,
        'hltv_url' : player.hltv_url,
        'team' : {
            'name' : player.team.name,
            'short_name' : player.team.short_name,
            'country_code' : player.team.country_code,
            'region' : player.team.region,
            'logo_url' : player.team.logo_url
        },
        'hltv_stats' : stats
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

    


