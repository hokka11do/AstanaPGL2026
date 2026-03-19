import asyncio
from src.database.database import session
from src.database.models.teams import Team , RegionEnum

async def seed():
    async with session() as s:
        teams = [
            Team(
                name="Team Spirit",
                short_name="Spirit",
                slug="team-spirit",
                country_code="RU",
                region=RegionEnum.CIS,
                logo_url=None,
                description="Российская киберспортивная организация Team Spirit.",
                is_active=True
            )   
        ]

        s.add_all(teams)
        await s.commit()

if __name__ == "__main__":
    asyncio.run(seed())   