EXPLAIN ANALYZE
SELECT p.FirstName, p.LastName, g.Week, s.SnapPercentage
FROM Player p
JOIN SnapCounts s ON p.PlayerID = s.PlayerID
JOIN Games g ON s.GameID = g.GameID
WHERE s.SnapPercentage > 80.00
  AND g.SeasonID = (SELECT SeasonID FROM Seasons WHERE StartDate >= '2024-01-01' LIMIT 1);