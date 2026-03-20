import asyncio
from sqlalchemy import select
from src.database.database import session
from src.database.models.teams import Team, RegionEnum


async def seed():
    async with session() as s:
        teams = [
            Team(
                name="PARIVISION",
                short_name="PARI",
                slug="parivision",
                country_code="RU",
                region=RegionEnum.CIS,
                logo_url=None,
                description="Российская киберспортивная организация PARIVISION.",
                is_active=True
            ),
            Team(
                name="Team Falcons",
                short_name="Falcons",
                slug="team-falcons",
                country_code="SA",
                region=RegionEnum.MENA,
                logo_url=None,
                description="Саудовская организация Team Falcons с международным составом.",
                is_active=True
            ),
            Team(
                name="Team Spirit",
                short_name="Spirit",
                slug="team-spirit",
                country_code="RU",
                region=RegionEnum.CIS,
                logo_url=None,
                description="Одна из сильнейших команд мира — Team Spirit.",
                is_active=True
            ),
            Team(
                name="G2 Esports",
                short_name="G2",
                slug="g2-esports",
                country_code="DE",
                region=RegionEnum.EU,
                logo_url=None,
                description="Европейский гранд G2 Esports.",
                is_active=True
            ),
            Team(
                name="The MongolZ",
                short_name="MongolZ",
                slug="the-mongolz",
                country_code="MN",
                region=RegionEnum.ASIA,
                logo_url=None,
                description="Монгольская команда The MongolZ.",
                is_active=True
            ),
            Team(
                name="MOUZ",
                short_name="MOUZ",
                slug="mouz",
                country_code="DE",
                region=RegionEnum.EU,
                logo_url=None,
                description="Европейская команда MOUZ.",
                is_active=True
            ),
            Team(
                name="FURIA Esports",
                short_name="FURIA",
                slug="furia",
                country_code="BR",
                region=RegionEnum.SA,
                logo_url=None,
                description="Бразильская организация FURIA Esports.",
                is_active=True
            ),
            Team(
                name="Aurora Gaming",
                short_name="Aurora",
                slug="aurora",
                country_code="RS",
                region=RegionEnum.EU,
                logo_url=None,
                description="Европейская команда Aurora Gaming.",
                is_active=True
            ),
            Team(
                name="Heroic",
                short_name="Heroic",
                slug="heroic",
                country_code="DK",
                region=RegionEnum.EU,
                logo_url=None,
                description="Датская организация Heroic.",
                is_active=True
            ),
            Team(
                name="Gentle Mates",
                short_name="M8",
                slug="gentle-mates",
                country_code="FR",
                region=RegionEnum.EU,
                logo_url=None,
                description="Французская команда Gentle Mates.",
                is_active=True
            ),
            Team(
                name="Monte",
                short_name="Monte",
                slug="monte",
                country_code="UA",
                region=RegionEnum.EU,
                logo_url=None,
                description="Украинская команда Monte.",
                is_active=True
            ),
            Team(
                name="FUT Esports",
                short_name="FUT",
                slug="fut-esports",
                country_code="TR",
                region=RegionEnum.EU,
                logo_url=None,
                description="Турецкая организация FUT Esports.",
                is_active=True
            )
        ]

        created_count = 0
        updated_count = 0

        for team in teams:
            existing_team = await s.scalar(
                select(Team).where(Team.slug == team.slug)
            )

            if existing_team is None:
                s.add(team)
                created_count += 1
            else:
                existing_team.logo_url = team.logo_url
                existing_team.description = team.description
                existing_team.country_code = team.country_code
                existing_team.region = team.region
                existing_team.short_name = team.short_name
                existing_team.name = team.name
                existing_team.is_active = team.is_active
                updated_count += 1

        await s.commit()
        print(f"Создано: {created_count}, обновлено: {updated_count}")


if __name__ == "__main__":
    asyncio.run(seed())
