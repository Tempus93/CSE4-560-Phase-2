SELECT 
    t.abbreviation,
    COUNT(CASE 
        WHEN (g.HomeTeamID = t.TeamID AND g.HomeScore > g.AwayScore) OR 
             (g.AwayTeamID = t.TeamID AND g.AwayScore > g.HomeScore) 
        THEN 1 END) AS Total_Wins,
    ROUND(AVG(CASE 
        WHEN g.HomeTeamID = t.TeamID THEN g.HomeScore 
        ELSE g.AwayScore END), 2) AS Avg_PPG
FROM Teams t
JOIN Games g ON (t.TeamID = g.HomeTeamID OR t.TeamID = g.AwayTeamID)
JOIN Seasons s ON g.SeasonID = s.SeasonID
-- This filters for seasons that started within the last 3 years
WHERE s.StartDate >= (CURRENT_DATE - INTERVAL '3 years')
GROUP BY t.abbreviation
ORDER BY Total_Wins DESC
LIMIT 5;