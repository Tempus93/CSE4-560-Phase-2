We created the tables with the CREATE TABLE IF NOT EXISTS command for all the tables required of the project along with temporary
tables to load the data from the CSVs to them. Reason we used temporary tables was so the ease of moving and joining data from 
table to table, rather than from csv to table.   

We then load the temporary tables with all the data from the CSVs then select all the data points we would want from the raw data,
we move it to the final/main tables. after we are done with the temporary tables , we delete them from the schema. 
------------------------------------------------------------HOW TO LOAD THE DATA------------------------------------------------
Contained in the data(csvs) file is all the data needed to load into the tables.
To load them on your local machine, the csvs must be in a publicily accessable directory on your machine.
when you've placed them there you now have to update the file locations the "load.sql" file grabs the data from.

replace all "C:/Users/Public/Documents/" texts in the file the location you stored the data csvs.
