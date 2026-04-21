-- 1. Create a "Resolved" table that maps CSV data directly to IDs
DROP TABLE IF EXISTS temp_def_resolved;

CREATE TEMP TABLE temp_def_resolved AS
SELECT 
    p.PlayerID,
    g.GameID,
    SUM(COALESCE(t.def_tackles, 0)) as tackles,
    SUM(COALESCE(t.def_sacks, 0)) as sacks,
    SUM(COALESCE(t.def_tackles_for_loss, 0)) as tfl,
    SUM(COALESCE(t.def_interceptions, 0)) as ints,
    SUM(COALESCE(t.def_pass_defended, 0)) as pdef,
    SUM(COALESCE(t.def_fumbles_forced, 0)) as ff,
    SUM(COALESCE(t.def_tds, 0)) as tds
FROM temp_def_stats_staging t
JOIN Player p ON (p.FirstName || ' ' || p.LastName = t.player_display_name)
JOIN Games g ON g.Week = t.week
JOIN Teams t_home ON g.HomeTeamID = t_home.TeamID
JOIN Teams t_away ON g.AwayTeamID = t_away.TeamID
JOIN Seasons s ON g.SeasonID = s.SeasonID
WHERE (t.team = t_home.abbreviation OR t.team = t_away.abbreviation)
  AND EXTRACT(YEAR FROM s.StartDate) = t.season
-- THE FIX: Grouping by the actual IDs that have the constraint
GROUP BY p.PlayerID, g.GameID;

-- 2. Add the "barcode" link
ALTER TABLE temp_def_resolved ADD COLUMN grouped_id SERIAL;

-- 3. THE UNIFIED INSERT
WITH inserted_def AS (
    INSERT INTO DefensiveStats (
        DefensiveSnaps, Tackles, Sacks, TacklesForLoss, 
        Interceptions, PassDeflections, ForcedFumbles, 
        DefensiveTDs, Pressures
    )
    SELECT 0, tackles, sacks, tfl, ints, pdef, ff, tds, 0
    FROM temp_def_resolved
    ORDER BY grouped_id -- Ensure sequential order
    RETURNING DefStatID
),
numbered_inserted AS (
    -- Pair the new IDs with our grouped_id barcode
    SELECT DefStatID, row_number() OVER () as grouped_id 
    FROM inserted_def
)
-- 4. Final Link into PlayerStats
INSERT INTO PlayerStats (PlayerID, GameID, DefStatID)
SELECT 
    tdr.PlayerID,
    tdr.GameID,
    ni.DefStatID
FROM temp_def_resolved tdr
JOIN numbered_inserted ni ON tdr.grouped_id = ni.grouped_id
-- If the row exists (Offense), update it. If not, create it (Defense only).
ON CONFLICT (PlayerID, GameID) 
DO UPDATE SET DefStatID = EXCLUDED.DefStatID;