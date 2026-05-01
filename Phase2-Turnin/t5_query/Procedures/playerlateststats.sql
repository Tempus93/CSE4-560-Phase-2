CREATE OR REPLACE FUNCTION GetPlayerLatestStats(
    p_first TEXT, 
    p_last TEXT, 
    team_abbr TEXT
)
RETURNS TABLE (
    Latest_Week INT,
    Pass_Yds DECIMAL,
    Rush_Yds DECIMAL,
    Rec_Yds DECIMAL,
    Total_Tackles DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        g.Week,
        COALESCE(o.PassingYds, 0),
        COALESCE(o.RushingYds, 0),
        COALESCE(o.ReceivingYds, 0),
        COALESCE(d.Tackles, 0)
    FROM PlayerStats ps
    JOIN Player p ON ps.PlayerID = p.PlayerID
    JOIN Teams t ON p.TeamID = t.TeamID
    JOIN Games g ON ps.GameID = g.GameID
    JOIN Seasons s ON g.SeasonID = s.SeasonID
    LEFT JOIN OffensiveStats o ON ps.OffStatID = o.OffStatID
    LEFT JOIN DefensiveStats d ON ps.DefStatID = d.DefStatID
    WHERE p.FirstName = p_first 
      AND p.LastName = p_last 
      AND t.abbreviation = team_abbr
      AND s.isactive = TRUE -- Restricts to the current active season
      -- SUBQUERY: Finds the highest week number for this specific player
      AND g.Week = (
          SELECT MAX(g2.Week)
          FROM PlayerStats ps2
          JOIN Games g2 ON ps2.GameID = g2.GameID
          WHERE ps2.PlayerID = p.PlayerID
      )
    LIMIT 1; -- Ensures only one row returns if there are data anomalies
END;
$$ LANGUAGE plpgsql;