COPY Seasons(StartDate, EndDate, IsActive)
FROM 'C:/Users/Public/Documents/season_dates_1980-2026.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');

SELECT 'Seasons:' as status, COUNT(*) FROM Seasons;