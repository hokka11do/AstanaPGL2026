from sqlalchemy.orm import Mapped , mapped_column , DeclarativeBase, relationship
from sqlalchemy import ForeignKey, String, Integer, Boolean, DateTime, func, CheckConstraint
from datetime import datetime
from enum import Enum
from sqlalchemy import Enum as SAEnum
from src.database.models.teams import Base
from sqlalchemy import Text


class MatchStatus(str, Enum):
    ENDED = 'ended'
    ONGOING = 'ongoing'
    UPCOMING = 'upcoming'

class StageEnum(str, Enum):
    GROUP_STAGE = 'group_stage'
    QUARTER_FINAL = 'quarterfinal'
    SEMIFINAL = 'semifinal'
    FINAL = 'final'

class BoTypeEnum(str, Enum):
    BO1 = 'bo1'
    BO3 = 'bo3'
    BO5 = 'bo5'

###

class MapNameEnum(str, Enum):
    DUST2 = 'dust2'
    MIRAGE = 'mirage'
    ANUBIS = 'anubis'
    INFERNO = 'inferno'
    NUKE = 'nuke'
    ANCIENT = 'ancient'
    TRAIN = 'train'


class Match(Base):
    __tablename__ = 'matches'

    __table_args__ = (
        CheckConstraint('team1_id != team2_id', name='check_teams_not_equal'),
    )

    id: Mapped[int] = mapped_column(primary_key=True)

    team1_id : Mapped[int] = mapped_column(ForeignKey('teams.id'))
    team2_id : Mapped[int] = mapped_column(ForeignKey('teams.id'))

    start_time : Mapped[datetime] = mapped_column(DateTime)

    bo_type : Mapped[BoTypeEnum] = mapped_column(SAEnum(BoTypeEnum))

    stage : Mapped[StageEnum] = mapped_column(SAEnum(StageEnum))

    status : Mapped[MatchStatus] = mapped_column(SAEnum(MatchStatus), default=MatchStatus.UPCOMING)

    score_team1 : Mapped[int] = mapped_column(default=0)
    score_team2 : Mapped[int] = mapped_column(default=0)

    winner_id : Mapped[int | None] = mapped_column(ForeignKey('teams.id', ondelete='SET NULL') ,nullable=True)

    stream_url : Mapped[str | None] = mapped_column(String, nullable=True)
    match_page_url : Mapped[str | None] = mapped_column(String, nullable=True)

    created_at : Mapped[datetime] = mapped_column(DateTime , server_default=func.now())

    team1 = relationship('Team' , foreign_keys = [team1_id])
    team2 = relationship('Team' , foreign_keys = [team2_id])
    winner = relationship('Team', foreign_keys=[winner_id])

    maps = relationship('MatchMap' , back_populates = 'match')


class MatchMap(Base):
    __tablename__ = 'matches_maps'

    id: Mapped[int] = mapped_column(primary_key=True)
    
    match_id : Mapped[int] = mapped_column(ForeignKey('matches.id', ondelete='CASCADE'), nullable = False)

    map_order : Mapped[int] = mapped_column(nullable = False)
    map_name : Mapped[MapNameEnum] = mapped_column(SAEnum(MapNameEnum) , nullable = False)

    picked_by_team_id: Mapped[int | None] = mapped_column(ForeignKey('teams.id' , ondelete = 'SET NULL'), nullable = True)

    score_team1 : Mapped[int] = mapped_column(default=0 , nullable = False)
    score_team2 : Mapped[int] = mapped_column(default=0 , nullable = False)

    winner_id : Mapped[int | None] = mapped_column(ForeignKey('teams.id', ondelete='SET NULL'), nullable = True)

    match = relationship('Match' , back_populates = 'maps')
    picked_by_team = relationship('Team', foreign_keys=[picked_by_team_id])
    winner = relationship('Team' , foreign_keys=[winner_id])
    player_stat = relationship('PlayerStats' , back_populates = 'match_map')


def calculate_rating(kills, deaths, rounds, adr, kast):
    kpr = kills / rounds
    dpr = deaths / rounds

    rating = (
        0.4 * kpr - 0.3 * dpr + 0.002 * adr + 0.003 * kast
    )

    return round(rating, 2)



class PlayerStats(Base):
    __tablename__ = 'player_stats'

    id : Mapped[int] = mapped_column(primary_key=True)

    match_map_id : Mapped[int] = mapped_column(ForeignKey('matches_maps.id', ondelete='CASCADE'), nullable=False)
    player_id : Mapped[int] = mapped_column(ForeignKey('players.id', ondelete='CASCADE'), nullable=False)

    kills : Mapped[float] = mapped_column(default = 0, nullable=False)
    deaths : Mapped[float] = mapped_column(default = 0, nullable=False)
    assists : Mapped[float] = mapped_column(default = 0, nullable=False)

    adr : Mapped[float] = mapped_column(default=0.0 , nullable=False)
    kast : Mapped[float] = mapped_column(default=0.0 , nullable=False)
    rating : Mapped[float] = mapped_column(default=0.0 , nullable=False)

    hs_percentage : Mapped[float] = mapped_column(default=0.0, nullable=False)
    
    match_map = relationship('MatchMap', back_populates='player_stat')
    player = relationship('Player', back_populates='player_stat')






