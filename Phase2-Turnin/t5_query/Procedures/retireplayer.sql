CREATE OR REPLACE PROCEDURE RetirePlayerByName(
    p_first TEXT, 
    p_last TEXT, 
    team_abbr TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Player 
    WHERE FirstName = p_first 
      AND LastName = p_last 
      AND TeamID = (SELECT TeamID FROM Teams WHERE teamabbr = team_abbr);
      
    COMMIT;
END;
$$;