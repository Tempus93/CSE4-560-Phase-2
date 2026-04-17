CREATE TABLE if NOT EXISTS temp_stats_staging (
    player_id TEXT, player_name TEXT, player_display_name TEXT, position TEXT, 
    position_group TEXT, headshot_url TEXT, recent_team TEXT, season INTEGER, 
    week INTEGER, season_type TEXT, opponent_team TEXT, completions INTEGER, 
    attempts INTEGER, passing_yards INTEGER, passing_tds INTEGER, interceptions INTEGER, 
    sacks DECIMAL, sack_yards INTEGER, sack_fumbles INTEGER, sack_fumbles_lost INTEGER, 
    passing_air_yards INTEGER, passing_yards_after_catch INTEGER, passing_first_downs INTEGER, 
    passing_epa DECIMAL, passing_2pt_conversions INTEGER, pacr DECIMAL, dakota DECIMAL, 
    carries INTEGER, rushing_yards INTEGER, rushing_tds INTEGER, rushing_fumbles INTEGER, 
    rushing_fumbles_lost INTEGER, rushing_first_downs INTEGER, rushing_epa DECIMAL, 
    rushing_2pt_conversions INTEGER, receptions INTEGER, targets INTEGER, 
    receiving_yards INTEGER, receiving_tds INTEGER, receiving_fumbles INTEGER, 
    receiving_fumbles_lost INTEGER, receiving_air_yards INTEGER, 
    receiving_yards_after_catch INTEGER, receiving_first_downs INTEGER, 
    receiving_epa DECIMAL, receiving_2pt_conversions INTEGER, racr DECIMAL, 
    target_share DECIMAL, air_yards_share DECIMAL, wopr DECIMAL, 
    special_teams_tds INTEGER, fantasy_points DECIMAL, fantasy_points_ppr DECIMAL
);

COPY temp_stats_staging
FROM 'C:/Users/Public/Documents/player_stats_2021.csv' 
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');
