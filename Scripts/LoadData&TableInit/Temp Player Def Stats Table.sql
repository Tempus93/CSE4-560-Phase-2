DROP TABLE IF EXISTS temp_def_stats_staging;

CREATE TABLE temp_def_stats_staging (
    season INTEGER, week INTEGER, season_type TEXT, player_id TEXT, 
    player_name TEXT, player_display_name TEXT, position TEXT, 
    position_group TEXT, headshot_url TEXT, team TEXT, 
    def_tackles DECIMAL, def_tackles_solo DECIMAL, def_tackles_with_assist DECIMAL, 
    def_tackle_assists DECIMAL, def_tackles_for_loss DECIMAL, 
    def_tackles_for_loss_yards DECIMAL, def_fumbles_forced DECIMAL, 
    def_sacks DECIMAL, def_sack_yards DECIMAL, def_qb_hits DECIMAL, 
    def_interceptions DECIMAL, def_interception_yards DECIMAL, 
    def_pass_defended DECIMAL, def_tds DECIMAL, def_fumbles DECIMAL, 
    def_fumble_recovery_own DECIMAL, def_fumble_recovery_yards_own DECIMAL, 
    def_fumble_recovery_opp DECIMAL, def_fumble_recovery_yards_opp DECIMAL, 
    def_safety DECIMAL, def_penalty DECIMAL, def_penalty_yards DECIMAL
);

-- Add the internal barcode
ALTER TABLE temp_def_stats_staging ADD COLUMN row_id SERIAL;

COPY temp_def_stats_staging (
    season, week, season_type, player_id, player_name, player_display_name, 
    position, position_group, headshot_url, team, def_tackles, def_tackles_solo, 
    def_tackles_with_assist, def_tackle_assists, def_tackles_for_loss, 
    def_tackles_for_loss_yards, def_fumbles_forced, def_sacks, def_sack_yards, 
    def_qb_hits, def_interceptions, def_interception_yards, def_pass_defended, 
    def_tds, def_fumbles, def_fumble_recovery_own, def_fumble_recovery_yards_own, 
    def_fumble_recovery_opp, def_fumble_recovery_yards_opp, def_safety, 
    def_penalty, def_penalty_yards
)
FROM 'C:/Users/Public/Documents/player_stats_def_2021.csv' 
WITH (FORMAT CSV, HEADER TRUE, QUOTE '"', DELIMITER ',');