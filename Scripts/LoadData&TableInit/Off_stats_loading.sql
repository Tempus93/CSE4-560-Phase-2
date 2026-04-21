-- 1. Insert numerical data into OffensiveStats (Sacks removed)
WITH inserted_stats AS (
    INSERT INTO OffensiveStats (
        PassingYds, 
        PassingTDs, 
        Completions, 
        Attempts, 
        RushingYds, 
        RushingTDs, 
        ReceivingYds, 
        ReceivingTDs, 
        TwoPtConversions,
        Offensivesnaps
    )
    SELECT 
        passing_yards, 
        passing_tds, 
        completions, 
        attempts, 
        rushing_yards, 
        rushing_tds, 
        receiving_yards, 
        receiving_tds,
        (COALESCE(passing_2pt_conversions, 0) + 
         COALESCE(rushing_2pt_conversions, 0) + 
         COALESCE(receiving_2pt_conversions, 0)),0
    FROM temp_stats_staging
    ORDER BY row_id 
    RETURNING OffStatID
),
-- 2. Pair those new IDs with the row_id barcode
stats_with_barcode AS (
    SELECT OffStatID, ROW_NUMBER() OVER () as row_id FROM inserted_stats
)
-- 3. Link into the PlayerStats bridge table
INSERT INTO PlayerStats (PlayerID, GameID, OffStatID)
SELECT 
    p.PlayerID,
    g.GameID,
    swb.OffStatID
FROM temp_stats_staging t
JOIN stats_with_barcode swb ON t.row_id = swb.row_id
JOIN Player p ON (p.FirstName || ' ' || p.LastName = t.player_display_name)
JOIN Games g ON g.Week = t.week
JOIN Teams ht ON g.HomeTeamID = ht.TeamID
JOIN Teams at ON g.AwayTeamID = at.TeamID
WHERE (t.recent_team = ht.abbreviation OR t.recent_team = at.abbreviation)
  AND (SELECT EXTRACT(YEAR FROM StartDate) FROM Seasons WHERE SeasonID = g.SeasonID) = t.season
ON CONFLICT DO NOTHING;