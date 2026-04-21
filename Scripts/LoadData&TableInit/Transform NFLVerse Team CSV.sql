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

-- 3. Verification (Optional but recommended for the team)
SELECT 'Staging load complete. Total rows:' as status, COUNT(*) FROM temp_nflverse_teams;