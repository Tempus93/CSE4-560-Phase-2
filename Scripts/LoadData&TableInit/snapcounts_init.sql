CREATE TABLE SnapCounts_Staging (
    game_id TEXT,
    pfr_game_id TEXT,
    season INTEGER,
    game_type TEXT,
    week INTEGER,
    player TEXT,
    pfr_player_id TEXT,
    position TEXT,
    team TEXT,
    opponent TEXT,
    offense_snaps INTEGER,
    offense_pct DECIMAL,
    defense_snaps INTEGER,
    defense_pct DECIMAL,
    st_snaps INTEGER,
    st_pct DECIMAL
);

COPY SnapCounts_Staging
FROM 'C:/Temp/snap_counts/snap_counts_2020.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY SnapCounts_Staging
FROM 'C:/Temp/snap_counts/snap_counts_2021.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY SnapCounts_Staging
FROM 'C:/Temp/snap_counts/snap_counts_2022.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY SnapCounts_Staging
FROM 'C:/Temp/snap_counts/snap_counts_2023.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY SnapCounts_Staging
FROM 'C:/Temp/snap_counts/snap_counts_2024.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

COPY SnapCounts_Staging
FROM 'C:/Temp/snap_counts/snap_counts_2025.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

INSERT INTO SnapCounts (
    PlayerID,
    GameID,
    OffensiveSnaps,
    DefensiveSnaps,
    STSnaps,
    SnapPercentage
)
SELECT
    p.PlayerID,
    g.GameID,
    COALESCE(s.offense_snaps, 0),
    COALESCE(s.defense_snaps, 0),
    COALESCE(s.st_snaps, 0),
    ROUND(
        GREATEST(
            COALESCE(s.offense_pct, 0),
            COALESCE(s.defense_pct, 0),
            COALESCE(s.st_pct, 0)
        ) * 100,
        2
    ) AS SnapPercentage
FROM SnapCounts_Staging s

-- Match season
JOIN Seasons se
    ON s.season = EXTRACT(YEAR FROM se.StartDate)

-- Match teams
JOIN Teams t_team
    ON t_team.TeamAbbr = s.team

JOIN Teams t_opp
    ON t_opp.TeamAbbr = s.opponent

-- Match game (NOW includes week → deterministic)
JOIN Games g
    ON g.SeasonID = se.SeasonID
   AND g.Week = s.week
   AND (
        (g.HomeTeamID = t_team.TeamID AND g.AwayTeamID = t_opp.TeamID)
     OR (g.HomeTeamID = t_opp.TeamID AND g.AwayTeamID = t_team.TeamID)
   )

-- Match player (name-based fallback)
JOIN Player p
  ON LOWER(REGEXP_REPLACE(TRIM(p.FirstName || ' ' || p.LastName), '[^a-z ]', '', 'g'))
   =
     LOWER(REGEXP_REPLACE(TRIM(s.player), '[^a-z ]', '', 'g'))

DROP TABLE IF EXISTS SnapCounts_Staging;