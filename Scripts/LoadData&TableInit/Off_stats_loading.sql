-- 1. Drop and recreate to ensure a clean match with the CSV
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
DROP TABLE IF EXISTS temp_off_stats_staging;