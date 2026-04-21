-- 1. Drop and recreate to ensure a clean match with the CSV
DROP TABLE IF EXISTS temp_stats_staging;

CREATE TABLE temp_stats_staging (
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

-- 2. Add the "Identity" column AFTER the table is created
-- This way, it doesn't look for a 'row_id' in the CSV, but generates it locally
ALTER TABLE temp_stats_staging ADD COLUMN row_id SERIAL;

-- 3. Execute the COPY with Quote handling
COPY temp_stats_staging (
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