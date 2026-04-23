-- 1. Conference (Top of hierarchy)
CREATE TABLE IF NOT EXISTS Conference (
    ConferenceID SERIAL PRIMARY KEY,
    ConfName VARCHAR(50) NOT NULL
);

-- 2. Division (References Conference)
CREATE TABLE IF NOT EXISTS Division (
    DivisionID SERIAL PRIMARY KEY,
    DivName VARCHAR(50) NOT NULL,
    ConferenceID INTEGER NOT NULL,
    FOREIGN KEY (ConferenceID) REFERENCES Conference(ConferenceID) ON DELETE CASCADE
);

-- 3. Teams (References Division)
CREATE TABLE IF NOT EXISTS Teams (
    TeamID SERIAL PRIMARY KEY,
    TeamName VARCHAR(100) NOT NULL,
    TeamAbbr VARCHAR(10) NOT NULL,
    City VARCHAR(100) NOT NULL,
    DivisionID INTEGER NOT NULL,
    HeadCoach VARCHAR(100),
    FOREIGN KEY (DivisionID) REFERENCES Division(DivisionID) ON DELETE SET NULL
);

-- 4. Player (References Teams)
CREATE TABLE IF NOT EXISTS Player (
    PlayerID SERIAL PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Position VARCHAR(10) NOT NULL,
    DraftYear INTEGER,
    College VARCHAR(100),
    TeamID INTEGER,
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID) ON DELETE SET NULL
);

-- 5. Seasons
CREATE TABLE IF NOT EXISTS Seasons (
    SeasonID SERIAL PRIMARY KEY,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsActive BOOLEAN NOT NULL DEFAULT FALSE
);

COPY Seasons(StartDate, EndDate, IsActive)
FROM 'C:/Temp/season_dates_1980-2026.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

-- 6. Games (References Seasons and Teams)
CREATE TABLE IF NOT EXISTS Games (
    GameID SERIAL PRIMARY KEY,
    SeasonID INTEGER NOT NULL,
    Week INTEGER NOT NULL,
    HomeTeamID INTEGER NOT NULL,
    AwayTeamID INTEGER NOT NULL,
    HomeScore INTEGER,
    AwayScore INTEGER,
    StadiumName VARCHAR(100) NOT NULL,
    FOREIGN KEY (SeasonID) REFERENCES Seasons(SeasonID) ON DELETE CASCADE,
    FOREIGN KEY (HomeTeamID) REFERENCES Teams(TeamID) ON DELETE RESTRICT,
    FOREIGN KEY (AwayTeamID) REFERENCES Teams(TeamID) ON DELETE RESTRICT
);

-- 7. SnapCounts (References Player and Games)
CREATE TABLE IF NOT EXISTS SnapCounts (
    SnapID SERIAL PRIMARY KEY,
    PlayerID INTEGER NOT NULL,
    GameID INTEGER NOT NULL,
    OffensiveSnaps INTEGER DEFAULT 0 NOT NULL,
    DefensiveSnaps INTEGER DEFAULT 0 NOT NULL,
    STSnaps INTEGER DEFAULT 0 NOT NULL,
    SnapPercentage DECIMAL(5,2),
    FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID) ON DELETE CASCADE,
    FOREIGN KEY (GameID) REFERENCES Games(GameID) ON DELETE CASCADE
);

-- 8. OffensiveStats
CREATE TABLE IF NOT EXISTS OffensiveStats (
    OffStatID SERIAL PRIMARY KEY,
    OffensiveSnaps INTEGER NOT NULL, -- References SnapCounts(SnapID) later via Alter or in PlayerStats
    PassingYds INTEGER DEFAULT 0 NOT NULL,
    PassingTDs INTEGER DEFAULT 0 NOT NULL,
    Completions INTEGER DEFAULT 0 NOT NULL,
    Attempts INTEGER DEFAULT 0 NOT NULL,
    RushingYds INTEGER DEFAULT 0 NOT NULL,
    RushingTDs INTEGER DEFAULT 0 NOT NULL,
    ReceivingYds INTEGER DEFAULT 0 NOT NULL,
    ReceivingTDs INTEGER DEFAULT 0 NOT NULL,
    TwoPtConversions INTEGER DEFAULT 0 NOT NULL
);

-- 9. DefensiveStats
CREATE TABLE IF NOT EXISTS DefensiveStats (
    DefStatID SERIAL PRIMARY KEY,
    DefensiveSnaps INTEGER NOT NULL,
    Tackles INTEGER DEFAULT 0 NOT NULL,
    Sacks DECIMAL(4,1) DEFAULT 0 NOT NULL,
    TacklesForLoss DECIMAL(4,1) DEFAULT 0 NOT NULL,
    Interceptions INTEGER DEFAULT 0 NOT NULL,
    PassDeflections INTEGER DEFAULT 0 NOT NULL,
    ForcedFumbles INTEGER DEFAULT 0 NOT NULL,
    DefensiveTDs INTEGER DEFAULT 0 NOT NULL,
    Pressures INTEGER DEFAULT 0 NOT NULL
);

-- 10. SpecialTeamStats
CREATE TABLE IF NOT EXISTS SpecialTeamStats (
    STStatID SERIAL PRIMARY KEY,
    STSnaps INTEGER NOT NULL,
    FGAttempts INTEGER DEFAULT 0 NOT NULL,
    FGMade INTEGER DEFAULT 0 NOT NULL,
    FGLong INTEGER DEFAULT 0 NOT NULL,
    XPAttempts INTEGER DEFAULT 0 NOT NULL,
    XPMade INTEGER DEFAULT 0 NOT NULL,
    PuntYds INTEGER DEFAULT 0 NOT NULL,
    ReturnYds INTEGER DEFAULT 0 NOT NULL,
    ReturnTDs INTEGER DEFAULT 0 NOT NULL
);

-- 11. PlayerStats (Bridge table linking Player, Game, and Specific Stats)
CREATE TABLE IF NOT EXISTS PlayerStats (
    StatID SERIAL PRIMARY KEY,
    PlayerID INTEGER NOT NULL,
    GameID INTEGER NOT NULL,
    OffStatID INTEGER,
    DefStatID INTEGER,
    STStatID INTEGER,
    FOREIGN KEY (PlayerID) REFERENCES Player(PlayerID) ON DELETE CASCADE,
    FOREIGN KEY (GameID) REFERENCES Games(GameID) ON DELETE CASCADE,
    FOREIGN KEY (OffStatID) REFERENCES OffensiveStats(OffStatID) ON DELETE SET NULL,
    FOREIGN KEY (DefStatID) REFERENCES DefensiveStats(DefStatID) ON DELETE SET NULL,
    FOREIGN KEY (STStatID) REFERENCES SpecialTeamStats(STStatID) ON DELETE SET NULL
);

-- 12. Weather
CREATE TABLE IF NOT EXISTS Weather (
    WeatherID SERIAL PRIMARY KEY,
    GameID INTEGER NOT NULL,
    Temperature DECIMAL(5,2),
    Condition VARCHAR(50),
    WindSpeed DECIMAL(5,2),
    Humidity DECIMAL(5,2),
    TimeObserved TIMESTAMP NOT NULL,
    FOREIGN KEY (GameID) REFERENCES Games(GameID) ON DELETE CASCADE
);-- 1. Populate Conference Table
-- NFLverse uses 'AFC' and 'NFC' strings
-- transform nflverse teams data to match the structure of the teams table in the database
CREATE TABLE IF NOT EXISTS temp_nflverse_teams (
    team_abbr VARCHAR(10),
    team_name VARCHAR(100),
    team_id INTEGER,
    team_nick VARCHAR(50),
    team_conf VARCHAR(10),
    team_division VARCHAR(50),
    team_color VARCHAR(10),
    team_color2 VARCHAR(10),
    team_color3 VARCHAR(10),
    team_color4 VARCHAR(10),
    team_logo_wikipedia TEXT,
    team_logo_espn TEXT,
    team_wordmark TEXT,
    team_conference_logo TEXT,
    team_league_logo TEXT,
    team_logo_squared TEXT
);

COPY temp_nflverse_teams
FROM 'Data(CSVs)/teams_colors_logos.csv' --CSV need to be in a PUBLIC directory or use absolute path
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

------ INSERT LOGIC DOWN HERE------------------

INSERT INTO Conference (ConfName)
SELECT DISTINCT team_conf FROM temp_nflverse_teams
ON CONFLICT DO NOTHING;

-- 2. Populate Division Table
-- This creates "AFC North", "NFC South", etc. by joining back to Conference
INSERT INTO Division (DivName, ConferenceID)
SELECT DISTINCT 
    t.team_conf || ' ' || t.team_division, 
    c.ConferenceID
FROM temp_nflverse_teams t
JOIN Conference c ON c.ConfName = t.team_conf
ON CONFLICT DO NOTHING;

-- 3. Populate Final Teams Table
-- This maps the string names to the integer IDs you need for Phase 2
INSERT INTO Teams (TeamName, TeamAbbr, City, DivisionID)
SELECT 
    t.team_name,
    t.team_abbr,
    -- REGEXP_REPLACE logic: 
    -- '(\s\S+)$' matches the last space and the following word (the nickname)
    -- and replaces it with an empty string, leaving only the city.
    REGEXP_REPLACE(t.team_name, '\s\S+$', '') as City, 
    d.DivisionID
FROM temp_nflverse_teams t
JOIN Division d ON d.DivName = (t.team_conf || ' ' || t.team_division)
ON CONFLICT DO NOTHING;

-- 4. Cleanup (Optional)
-- Uncomment the line below once you verify the data is correct
-- DROP TABLE temp_nflverse_teams;

-- 5. Verification for the team
SELECT 'Conferences:' as table, COUNT(*) FROM Conference
UNION ALL
SELECT 'Divisions:', COUNT(*) FROM Division
UNION ALL
SELECT 'Teams:', COUNT(*) FROM Teams;

DROP TABLE IF EXISTS temp_nflverse_teams;COPY Seasons(StartDate, EndDate, IsActive)
FROM 'C:/Users/Public/Documents/season_dates_1980-2026.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

SELECT 'Seasons:' as status, COUNT(*) FROM Seasons;CREATE TABLE IF NOT EXISTS Games_Staging (
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

DROP TABLE IF EXISTS Games_Staging;-- 1. Create Player Staging Table
CREATE TABLE IF NOT EXISTS temp_nflverse_players (
    gsis_id TEXT, display_name TEXT, common_first_name TEXT, 
    first_name TEXT, last_name TEXT, short_name TEXT, 
    football_name TEXT, suffix TEXT, esb_id TEXT, 
    nfl_id TEXT, pfr_id TEXT, pff_id TEXT, 
    otc_id TEXT, espn_id TEXT, smart_id TEXT, 
    birth_date DATE, position_group TEXT, position TEXT, 
    ngs_position_group TEXT, ngs_position TEXT, height TEXT, 
    weight TEXT, headshot TEXT, college_name TEXT, 
    college_conference TEXT, jersey_number TEXT, rookie_season INTEGER, 
    last_season INTEGER, latest_team TEXT, status TEXT, 
    ngs_status TEXT, ngs_status_short_description TEXT, 
    years_of_experience TEXT, pff_position TEXT, pff_status TEXT, 
    draft_year INTEGER, draft_round TEXT, draft_pick TEXT, draft_team TEXT
);

-- 2. Bulk Load 
-- Move csv to public folder b4 copy
COPY temp_nflverse_players
FROM 'C:/Temp/players.csv' -- Adjust path as needed; has to be in public folder for COPY to work
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

-- size of college name is variable, so we need to adjust the Player table schema before migrating
ALTER TABLE Player ALTER COLUMN College TYPE VARCHAR(255);
ALTER TABLE Player ADD CONSTRAINT unique_player_identity UNIQUE (FirstName, LastName, TeamID);
-- 3. Migrate to Final Player Table with Relational Join
INSERT INTO Player (FirstName, LastName, Position, DraftYear, College, TeamID)
SELECT 
    tp.first_name,
    tp.last_name,
    tp.position,
    tp.draft_year,
    tp.college_name,
    t.TeamID
FROM temp_nflverse_players tp
-- This join ensures each player is linked to the correct Team record you just created
-- It uses the abbreviation from the CSV to find your TeamID
LEFT JOIN (
    -- This subquery is necessary to get the TeamID based on the latest_team abbreviation from the CSV
    -- THIS SCRIPT ASSUMES your Teams table has an 'abbreviation' column 
    SELECT TeamID, teamabbr FROM Teams
) t ON (tp.latest_team IS NOT NULL AND t.teamabbr ILIKE tp.latest_team || '%')
WHERE tp.last_season >= 2024 -- Focuses on recent/active players to hit your 3,000 record goal
ON CONFLICT DO NOTHING;

-- 4. Verification and Cleanup
SELECT 'Players Loaded:' as status, COUNT(*) FROM Player;

DROP TABLE IF EXISTS temp_nflverse_players; -- Uncomment after confirming counts-- 1. Drop and recreate to ensure a clean match with the CSV
DROP TABLE IF EXISTS temp_off_stats_staging;

CREATE TABLE temp_off_stats_staging (
    player_id TEXT,
    player_name TEXT,
    player_display_name TEXT,
    position TEXT,
    position_group TEXT,
    headshot_url TEXT,
    recent_team TEXT,
    season INTEGER,
    week INTEGER,
    season_type TEXT,
    opponent_team TEXT,
    completions INTEGER,
    attempts INTEGER,
    passing_yards INTEGER,
    passing_tds INTEGER,
    interceptions INTEGER,
    sacks DECIMAL,
    sack_yards INTEGER,
    sack_fumbles INTEGER,
    sack_fumbles_lost INTEGER,
    passing_air_yards INTEGER,
    passing_yards_after_catch INTEGER,
    passing_first_downs INTEGER,
    passing_epa DECIMAL,
    passing_2pt_conversions INTEGER,
    pacr DECIMAL,
    dakota DECIMAL,
    carries INTEGER,
    rushing_yards INTEGER,
    rushing_tds INTEGER,
    rushing_fumbles INTEGER,
    rushing_fumbles_lost INTEGER,
    rushing_first_downs INTEGER,
    rushing_epa DECIMAL,
    rushing_2pt_conversions INTEGER,
    receptions INTEGER,
    targets INTEGER,
    receiving_yards INTEGER,
    receiving_tds INTEGER,
    receiving_fumbles INTEGER,
    receiving_fumbles_lost INTEGER,
    receiving_air_yards INTEGER,
    receiving_yards_after_catch INTEGER,
    receiving_first_downs INTEGER,
    receiving_epa DECIMAL,
    receiving_2pt_conversions INTEGER,
    racr DECIMAL,
    target_share DECIMAL,
    air_yards_share DECIMAL,
    wopr DECIMAL,
    special_teams_tds INTEGER,
    fantasy_points DECIMAL,
    fantasy_points_ppr DECIMAL
);

ALTER TABLE temp_off_stats_staging ADD COLUMN row_id SERIAL;

COPY temp_off_stats_staging (
    player_id, player_name, player_display_name, position, position_group, 
    headshot_url, recent_team, season, week, season_type, opponent_team, 
    completions, attempts, passing_yards, passing_tds, interceptions, 
    sacks, sack_yards, sack_fumbles, sack_fumbles_lost, passing_air_yards, 
    passing_yards_after_catch, passing_first_downs, passing_epa, 
    passing_2pt_conversions, pacr, dakota, carries, rushing_yards, 
    rushing_tds, rushing_fumbles, rushing_fumbles_lost, rushing_first_downs, 
    rushing_epa, rushing_2pt_conversions, receptions, targets, 
    receiving_yards, receiving_tds, receiving_fumbles, 
    receiving_fumbles_lost, receiving_air_yards, 
    receiving_yards_after_catch, receiving_first_downs, receiving_epa, 
    receiving_2pt_conversions, racr, target_share, air_yards_share, 
    wopr, special_teams_tds, fantasy_points, fantasy_points_ppr
)
FROM 'C:/Users/Public/Documents/player_stats_2021.csv' 
WITH (FORMAT CSV, HEADER TRUE, QUOTE '"', DELIMITER ',');


-- 2. Insert numerical data into OffensiveStats (Sacks removed)
WITH inserted_stats AS (
    INSERT INTO OffensiveStats (
        PassingYds, 
        PassingTDs, 
        Completions, 
        Attempts, 
        RushingYds, 
        RushingTDs, 
        ReceivingYds, 
        ReceivingTDs, 
        TwoPtConversions,
        Offensivesnaps
    )
    SELECT 
        passing_yards, 
        passing_tds, 
        completions, 
        attempts, 
        rushing_yards, 
        rushing_tds, 
        receiving_yards, 
        receiving_tds,
        (COALESCE(passing_2pt_conversions, 0) + 
         COALESCE(rushing_2pt_conversions, 0) + 
         COALESCE(receiving_2pt_conversions, 0)),0
    FROM temp_off_stats_staging
    ORDER BY row_id 
    RETURNING OffStatID
),
-- 2. Pair those new IDs with the row_id barcode
stats_with_barcode AS (
    SELECT OffStatID, ROW_NUMBER() OVER () as row_id FROM inserted_stats
)
-- 3. Link into the PlayerStats bridge table
INSERT INTO PlayerStats (PlayerID, GameID, OffStatID)
SELECT 
    p.PlayerID,
    g.GameID,
    swb.OffStatID
FROM temp_off_stats_staging t
JOIN stats_with_barcode swb ON t.row_id = swb.row_id
JOIN Player p ON (p.FirstName || ' ' || p.LastName = t.player_display_name)
JOIN Games g ON g.Week = t.week
JOIN Teams ht ON g.HomeTeamID = ht.TeamID
JOIN Teams at ON g.AwayTeamID = at.TeamID
WHERE (t.recent_team = ht.teamabbr OR t.recent_team = at.teamabbr)
  AND (SELECT EXTRACT(YEAR FROM StartDate) FROM Seasons WHERE SeasonID = g.SeasonID) = t.season

ON CONFLICT (PlayerID, GameID) 
DO UPDATE SET OffStatID = EXCLUDED.OffStatID;

-- 5. Final Cleanup
DROP TABLE IF EXISTS temp_stats_staging;
DROP TABLE IF EXISTS temp_off_stats_staging;-- 1. Create a "Resolved" table that maps CSV data directly to IDs
DROP TABLE IF EXISTS temp_def_resolved;

CREATE TEMP TABLE temp_def_resolved AS
SELECT 
    p.PlayerID,
    g.GameID,
    SUM(COALESCE(t.def_tackles, 0)) as tackles,
    SUM(COALESCE(t.def_sacks, 0)) as sacks,
    SUM(COALESCE(t.def_tackles_for_loss, 0)) as tfl,
    SUM(COALESCE(t.def_interceptions, 0)) as ints,
    SUM(COALESCE(t.def_pass_defended, 0)) as pdef,
    SUM(COALESCE(t.def_fumbles_forced, 0)) as ff,
    SUM(COALESCE(t.def_tds, 0)) as tds
FROM temp_def_stats_staging t
JOIN Player p ON (p.FirstName || ' ' || p.LastName = t.player_display_name)
JOIN Games g ON g.Week = t.week
JOIN Teams t_home ON g.HomeTeamID = t_home.TeamID
JOIN Teams t_away ON g.AwayTeamID = t_away.TeamID
JOIN Seasons s ON g.SeasonID = s.SeasonID
WHERE (t.team = t_home.teamabbr OR t.team = t_away.teamabbr)
  AND EXTRACT(YEAR FROM s.StartDate) = t.season
-- THE FIX: Grouping by the actual IDs that have the constraint
GROUP BY p.PlayerID, g.GameID;

-- 2. Add the "barcode" link
ALTER TABLE temp_def_resolved ADD COLUMN grouped_id SERIAL;

-- 3. THE UNIFIED INSERT
WITH inserted_def AS (
    INSERT INTO DefensiveStats (
        DefensiveSnaps, Tackles, Sacks, TacklesForLoss, 
        Interceptions, PassDeflections, ForcedFumbles, 
        DefensiveTDs, Pressures
    )
    SELECT 0, tackles, sacks, tfl, ints, pdef, ff, tds, 0
    FROM temp_def_resolved
    ORDER BY grouped_id -- Ensure sequential order
    RETURNING DefStatID
),
numbered_inserted AS (
    -- Pair the new IDs with our grouped_id barcode
    SELECT DefStatID, row_number() OVER () as grouped_id 
    FROM inserted_def
)
-- 4. Final Link into PlayerStats
INSERT INTO PlayerStats (PlayerID, GameID, DefStatID)
SELECT 
    tdr.PlayerID,
    tdr.GameID,
    ni.DefStatID
FROM temp_def_resolved tdr
JOIN numbered_inserted ni ON tdr.grouped_id = ni.grouped_id
-- If the row exists (Offense), update it. If not, create it (Defense only).
ON CONFLICT (PlayerID, GameID) 
DO UPDATE SET DefStatID = EXCLUDED.DefStatID;

-- 5. Final Cleanup
DROP TABLE IF EXISTS temp_def_resolved;
-- Note: temp_def_stats_staging should also be dropped if you are finished with it
DROP TABLE IF EXISTS temp_def_stats_staging;CREATE TABLE SnapCounts_Staging (
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