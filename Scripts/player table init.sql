-- 1. Create Player Staging Table
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

-- DROP TABLE temp_nflverse_players; -- Uncomment after confirming counts