CREATE TABLE staging_games (
    game_id         VARCHAR(50),
    season          TEXT,
    stadium_name    VARCHAR(100),
    time_start_game TEXT,
    time_end_game   TEXT,
    tz_offset       TEXT
);

CREATE TABLE staging_weather (
    game_id             VARCHAR(50),
    source              VARCHAR(100),
    distance_to_station TEXT,
    time_measure        TEXT,
    temperature         TEXT,
    dew_point           TEXT,
    humidity            TEXT,
    precipitation       TEXT,
    wind_speed          TEXT,
    wind_direction      TEXT,
    pressure            TEXT,
    estimated_condition VARCHAR(50)
);

COPY staging_games
FROM 'Data(CSVs)/GameStats/games_weather_info.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', NULL 'NA');

COPY staging_weather
FROM 'Data(CSVs)/GameStats/games_weather.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', NULL 'NA');



-- Clean wind_direction of non-numeric values (e.g. "N", "SW")
UPDATE staging_weather
SET wind_direction = NULL
WHERE wind_direction !~ '^\s*-?\d+(\.\d+)?\s*$';

-- Null out empty strings in all numeric columns
UPDATE staging_weather
SET
    distance_to_station = NULLIF(distance_to_station, ''),
    temperature         = NULLIF(temperature, ''),
    dew_point           = NULLIF(dew_point, ''),
    humidity            = NULLIF(humidity, ''),
    precipitation       = NULLIF(precipitation, ''),
    wind_speed          = NULLIF(wind_speed, ''),
    wind_direction      = NULLIF(wind_direction, ''),
    pressure            = NULLIF(pressure, '');

UPDATE staging_games
SET
    season    = NULLIF(season, ''),
    tz_offset = NULLIF(tz_offset, '');


CREATE TABLE combined_game_weather AS
SELECT
    sg.game_id,
    sg.season::INTEGER                      AS season,
    sg.stadium_name,
    sg.time_start_game,
    sg.time_end_game,
    sg.tz_offset::INTEGER                   AS tz_offset,
    sw.source,
    sw.distance_to_station::DECIMAL(10,2)   AS distance_to_station,
    sw.time_measure,
    sw.temperature::DECIMAL(5,2)            AS temperature,
    sw.dew_point::DECIMAL(5,2)              AS dew_point,
    sw.humidity::DECIMAL(5,2)               AS humidity,
    sw.precipitation::DECIMAL(5,2)          AS precipitation,
    sw.wind_speed::DECIMAL(5,2)             AS wind_speed,
    sw.wind_direction::DECIMAL(6,2)         AS wind_direction,
    sw.pressure::DECIMAL(6,2)               AS pressure,
    sw.estimated_condition
FROM staging_games sg
JOIN staging_weather sw ON sw.game_id = sg.game_id;

DROP TABLE IF EXISTS staging_games;
DROP TABLE IF EXISTS staging_weather;

SELECT 'Combined rows:' AS status, COUNT(*) FROM combined_game_weather;
SELECT * FROM combined_game_weather LIMIT 20;