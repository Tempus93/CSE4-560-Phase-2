-- Adding indexes to the columns used in the JOIN and WHERE clauses
CREATE INDEX IF NOT EXISTS idx_snapcounts_player_game ON SnapCounts(PlayerID, GameID);
CREATE INDEX IF NOT EXISTS idx_snapcounts_percentage ON SnapCounts(SnapPercentage);