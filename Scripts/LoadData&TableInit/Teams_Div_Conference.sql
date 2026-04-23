-- 1. Populate Conference Table
-- NFLverse uses 'AFC' and 'NFC' strings
-- transform nflverse teams data to match the structure of the teams table in the database
CREATE TABLE temp_nflverse_teams (
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

DROP TABLE temp_nflverse_teams;