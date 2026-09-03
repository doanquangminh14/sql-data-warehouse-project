/*
====================================================
CREATE DATABASE AND SCHEMA
====================================================
Script purpose:
  This  script create a new database named "DataWarehouse". Additionally, the script set up three schemas 
  within the database: 'bronze','silver','gold'.
*/

-- Create Database
USE master;
GO

CREATE DATABASE DataWarehouse;
GO
USE DataWarehouse;
GO

-- Create Schemas
CREATE SCHEMA bronze;
GO
CREATE SCHEMA silver;
GO
CREATE SCHEMA gold;
GO
