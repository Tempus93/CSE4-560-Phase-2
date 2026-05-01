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
    FOREIGN KEY (TeamID) REFERENCES Teams(TeamID) ON DELETE SET NULL,
    CONSTRAINT unique_player_identity UNIQUE (FirstName, LastName, TeamID)
);

-- 5. Seasons
CREATE TABLE IF NOT EXISTS Seasons (
    SeasonID SERIAL PRIMARY KEY,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    IsActive BOOLEAN NOT NULL DEFAULT FALSE
);

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
    FOREIGN KEY (GameID) REFERENCES Games(GameID) ON DELETE CASCADE,
    UNIQUE (PlayerID, GameID) -- Ensures one snap count record per player per game
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
    FOREIGN KEY (STStatID) REFERENCES SpecialTeamStats(STStatID) ON DELETE SET NULL,
    UNIQUE (PlayerID, GameID) -- Ensures one stats record per player per game
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
);

-- Staging: temp_nflverse_teams
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

-- Staging: Games_Staging
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

-- Staging: temp_nflverse_players
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

-- Staging: temp_off_stats_staging
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

-- Staging: temp_def_stats_staging
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

-- Staging: SnapCounts_Staging
CREATE TABLE IF NOT EXISTS SnapCounts_Staging (
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
