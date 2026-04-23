CREATE OR REPLACE PROCEDURE UpdatePlayerTeamByName(
    p_first TEXT, 
    p_last TEXT, 
    old_team_abbr TEXT, 
    new_team_abbr TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE Player 
    SET TeamID = (SELECT TeamID FROM Teams WHERE abbreviation = new_team_abbr)
    WHERE FirstName = p_first 
      AND LastName = p_last 
      AND TeamID = (SELECT TeamID FROM Teams WHERE abbreviation = old_team_abbr);
    
    COMMIT;
END;
$$;