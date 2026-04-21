SELECT 
    p.FirstName || ' ' || p.LastName AS Defender,
    SUM(d.Tackles) AS Total_Tackles,
    SUM(d.Sacks) AS Total_Sacks
FROM DefensiveStats d
JOIN PlayerStats ps ON d.DefStatID = ps.DefStatID
JOIN Player p ON ps.PlayerID = p.PlayerID
GROUP BY p.PlayerID, p.FirstName, p.LastName
HAVING SUM(d.Tackles) > (SELECT AVG(Tackles) * 5 FROM DefensiveStats) -- Adjusted subquery for season-long impact
ORDER BY Total_Tackles DESC
LIMIT 10;