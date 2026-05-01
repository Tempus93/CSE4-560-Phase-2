EXPLAIN ANALYZE
SELECT p.FirstName, p.LastName, p.Position, p.DraftYear, p.College
FROM Player p 
JOIN Teams t ON p.TeamID = t.TeamID
WHERE t.TeamName = 'Buffalo Bills'
ORDER BY p.Position ASC, p.LastName ASC;