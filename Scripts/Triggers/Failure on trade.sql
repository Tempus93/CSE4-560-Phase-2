-- 1. Create the Log Table first
CREATE TABLE IF NOT EXISTS Trade_Failure_Log (
    LogID SERIAL PRIMARY KEY,
    PlayerID INT,
    AttemptedTeamID INT,
    ErrorMessage TEXT,
    LogTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Define the Trigger Function
CREATE OR REPLACE FUNCTION log_trade_failure()
RETURNS TRIGGER AS $$
BEGIN
    -- This captures the data from the failed transaction attempt
    INSERT INTO Trade_Failure_Log (PlayerID, AttemptedTeamID, ErrorMessage)
    VALUES (OLD.PlayerID, NEW.TeamID, 'Constraint Violation: Team ID does not exist in Teams table.');
    RETURN NULL; 
END;
$$ LANGUAGE plpgsql;

-- 3. Bind the Trigger to the Player Table
DROP TRIGGER IF EXISTS trg_check_trade_validity ON Player;
CREATE TRIGGER trg_check_trade_validity
BEFORE UPDATE ON Player
FOR EACH ROW
WHEN (NEW.TeamID IS NOT NULL)
EXECUTE FUNCTION log_trade_failure();