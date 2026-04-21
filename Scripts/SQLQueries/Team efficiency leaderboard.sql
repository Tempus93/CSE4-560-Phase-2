SELECT 
    t.abbreviation, 
    AVG(o.PassingYds) as Avg_Passing_Yds,
    COUNT(ps.playerid) as Total_Stat_Records
FROM PlayerStats ps
JOIN OffensiveStats o ON ps.OffStatID = o.OffStatID
JOIN Games g ON ps.GameID = g.GameID
JOIN Teams t ON (t.TeamID = g.HomeTeamID OR t.TeamID = g.AwayTeamID)
GROUP BY t.abbreviation
HAVING COUNT(ps.playerid) > 5
ORDER BY Avg_Passing_Yds DESC;