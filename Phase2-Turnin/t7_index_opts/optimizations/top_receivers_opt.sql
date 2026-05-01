CREATE INDEX idx_player_position ON Player (Position);
CREATE INDEX idx_games_seasonid ON Games (SeasonID);
CREATE INDEX idx_snapcounts_player_game ON SnapCounts (PlayerID, GameID);
CREATE INDEX idx_playerstats_player_game ON PlayerStats (PlayerID, GameID);
CREATE INDEX idx_playerstats_offstatid ON PlayerStats (OffStatID);
