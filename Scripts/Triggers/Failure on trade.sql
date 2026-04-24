-- 1. The Function
CREATE OR REPLACE FUNCTION log_trade_failure()
RETURNS TRIGGER AS $$
BEGIN
    -- Detects if the TeamID is being set to NULL by the procedure
    IF (NEW.TeamID IS NULL AND OLD.TeamID IS NOT NULL) THEN
        -- This stops the update and sends an error message directly to your terminal
        RAISE EXCEPTION 'CRITICAL ERROR: Trade failed for player % % (ID: %). Invalid team abbreviation provided. Transaction rolled back.', 
            OLD.FirstName, OLD.LastName, OLD.PlayerID;
        
        -- In an EXCEPTION case, the code stops here, but RETURN OLD is a safe fallback
        RETURN OLD; 
    END IF;

    -- If the TeamID is valid, allow the update to proceed
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. The Trigger
DROP TRIGGER IF EXISTS trig_trade_failure ON Player;

CREATE TRIGGER trig_trade_failure
BEFORE UPDATE OF TeamID ON Player
FOR EACH ROW
EXECUTE FUNCTION log_trade_failure();