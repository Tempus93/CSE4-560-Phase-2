CREATE TABLE IF NOT EXISTS Games_Staging (
    game_id TEXT,
    season INTEGER,
    game_type TEXT,
    week INTEGER,
    gameday DATE,
    weekday TEXT,
    gametime TEXT,
    away_team TEXT,
    away_score INTEGER,
    home_team TEXT,
    home_score INTEGER,
    location TEXT,
    result TEXT,
    total TEXT,
    overtime TEXT,
    old_game_id TEXT,
    gsis TEXT,
    nfl_detail_id TEXT,
    pfr TEXT,
    pff TEXT,
    espn TEXT,
    ftn TEXT,
    away_rest TEXT,
    home_rest TEXT,
    away_moneyline TEXT,
    home_moneyline TEXT,
    spread_line TEXT,
    away_spread_odds TEXT,
    home_spread_odds TEXT,
    total_line TEXT,
    under_odds TEXT,
    over_odds TEXT,
    div_game TEXT,
    roof TEXT,
    surface TEXT,
    temp TEXT,
    wind TEXT,
    away_qb_id TEXT,
    home_qb_id TEXT,
    away_qb_name TEXT,
    home_qb_name TEXT,
    away_coach TEXT,
    home_coach TEXT,
    referee TEXT,
    stadium_id TEXT,
    stadium TEXT
);

COPY Games_Staging
FROM 'C:/Users/Public/Documents/games.csv' -- Adjust path as needed; has to be in public folder for COPY to work
WITH (FORMAT CSV, HEADER TRUE);

ALTER TABLE Games ADD COLUMN IF NOT EXISTS Week INTEGER; --gotta add this so we can pin playerstats to a specific week of the season, which is important for calculating rest days and other time-sensitive stats 
INSERT INTO games (
    SeasonID,
    Week,
    HomeTeamID,
    AwayTeamID,
    HomeScore,
    AwayScore,
    StadiumName
)
SELECT
    s.SeasonID,
    gs.Week AS Week,
    ht.TeamID AS HomeTeamID,
    at.TeamID AS AwayTeamID,
    gs.home_score,
    gs.away_score,
    gs.stadium
FROM Games_Staging gs
JOIN Seasons s
    ON EXTRACT(YEAR FROM s.StartDate) = gs.season
JOIN Teams ht
    ON ht.teamabbr = gs.home_team
JOIN Teams at
    ON at.teamabbr = gs.away_team;

DROP TABLE IF EXISTS Games_Staging;