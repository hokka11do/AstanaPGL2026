import random
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from src.database.database import session
from src.database.models.players import Player
from src.database.models.matches import MatchMap , Match
from src.database.models.matches import PlayerStats , calculate_rating


def random_stat(min_val, max_val):
    return random.randint(min_val, max_val)


def random_float(min_val, max_val):
    return round(random.uniform(min_val, max_val), 2)


async def fill_stats():
    async with session() as ses:

        maps_result = await ses.execute(select(MatchMap).options(selectinload(MatchMap.match).selectinload(Match.team1),selectinload(MatchMap.match).selectinload(Match.team2)))
        maps = maps_result.scalars().all()

        for match_map in maps:
            print(f"Processing map {match_map.id}")

            # получаем команды
            team1_id = match_map.match.team1_id
            team2_id = match_map.match.team2_id

            # получаем игроков
            players_result = await ses.execute(
                select(Player).where(Player.team_id.in_([team1_id, team2_id]))
            )
            players = players_result.scalars().all()

            # берем по 5 игроков с каждой команды
            team1_players = [p for p in players if p.team_id == team1_id][:5]
            team2_players = [p for p in players if p.team_id == team2_id][:5]

            all_players = team1_players + team2_players

            rounds = match_map.score_team1 + match_map.score_team2

            for player in all_players:

                kills = random_stat(10, 30)
                deaths = random_stat(10, 30)
                assists = random_stat(0, 10)

                adr = random_float(60, 110)
                kast = random_float(60, 85)
                hs = random_float(30, 70)

                rating = calculate_rating(
                    kills=kills,
                    deaths=deaths,
                    rounds=rounds,
                    adr=adr,
                    kast=kast
                )

                stat = PlayerStats(
                    match_map_id=match_map.id,
                    player_id=player.id,
                    kills=kills,
                    deaths=deaths,
                    assists=assists,
                    adr=adr,
                    kast=kast,
                    rating=rating,
                    hs_percentage=hs
                )

                ses.add(stat)

        await ses.commit()


if __name__ == "__main__":
    import asyncio
    asyncio.run(fill_stats())