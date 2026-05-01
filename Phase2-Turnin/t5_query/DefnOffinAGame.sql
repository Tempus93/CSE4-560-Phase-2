SELECT 
    p.FirstName || ' ' || p.LastName AS Player,
    g.Week,
    o.PassingYds,
    d.Tackles
FROM PlayerStats ps
JOIN Player p ON ps.PlayerID = p.PlayerID
JOIN Games g ON ps.GameID = g.GameID
JOIN OffensiveStats o ON ps.OffStatID = o.OffStatID
JOIN DefensiveStats d ON ps.DefStatID = d.DefStatID
WHERE o.PassingYds > 0 AND d.Tackles > 0
ORDER BY o.PassingYds DESC;