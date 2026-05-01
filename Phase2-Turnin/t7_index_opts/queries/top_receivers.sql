EXPLAIN ANALYZE
SELECT  p.LastName, p.FirstName, o.receivingyds
FROM Player p
JOIN SnapCounts s ON p.PlayerID = s.PlayerID
JOIN PlayerStats ps ON p.PlayerID = ps.PlayerID AND s.GameID = ps.GameID
JOIN OffensiveStats o ON ps.OffStatID = o.OffStatID
JOIN Games g ON s.GameID = g.GameID
WHERE p.Position = 'WR' 
    AND g.SeasonID = 2025
ORDER BY o.receivingyds DESC, o.receivingtds DESC
LIMIT 10;