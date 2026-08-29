/*-----------------------------------------------------------------------------
Hands-On Lab: Data Engineering with Snowpark
Script:       01_setup_snowflake.sql
Author:       Jeremiah Hansen
Last Updated: 1/1/2023
-----------------------------------------------------------------------------*/


-- ----------------------------------------------------------------------------
-- Step #1: Accept Anaconda Terms & Conditions
-- ----------------------------------------------------------------------------

-- See Getting Started section in Third-Party Packages (https://docs.snowflake.com/en/developer-guide/udf/python/udf-python-packages.html#getting-started)


-- ----------------------------------------------------------------------------
-- Step #2: Create the account level objects
-- ----------------------------------------------------------------------------
USE ROLE ACCOUNTADMIN;

-- Roles
SET MY_USER = CURRENT_USER();
CREATE OR REPLACE ROLE HOL_ROLE;
GRANT ROLE HOL_ROLE TO ROLE SYSADMIN;
GRANT ROLE HOL_ROLE TO USER IDENTIFIER($MY_USER);

GRANT EXECUTE TASK ON ACCOUNT TO ROLE HOL_ROLE;
GRANT MONITOR EXECUTION ON ACCOUNT TO ROLE HOL_ROLE;
GRANT IMPORTED PRIVILEGES ON DATABASE SNOWFLAKE TO ROLE HOL_ROLE;

-- Databases
CREATE OR REPLACE DATABASE HOL_DB;
GRANT OWNERSHIP ON DATABASE HOL_DB TO ROLE HOL_ROLE;

-- Warehouses
CREATE OR REPLACE WAREHOUSE HOL_WH WAREHOUSE_SIZE = XSMALL, AUTO_SUSPEND = 300, AUTO_RESUME= TRUE;
GRANT OWNERSHIP ON WAREHOUSE HOL_WH TO ROLE HOL_ROLE;


-- ----------------------------------------------------------------------------
-- Step #3: Create the database level objects
-- ----------------------------------------------------------------------------
USE ROLE HOL_ROLE;
USE WAREHOUSE HOL_WH;
USE DATABASE HOL_DB;

-- Schemas
CREATE OR REPLACE SCHEMA EXTERNAL;
CREATE OR REPLACE SCHEMA RAW_POS;
CREATE OR REPLACE SCHEMA RAW_CUSTOMER;
CREATE OR REPLACE SCHEMA HARMONIZED;
CREATE OR REPLACE SCHEMA ANALYTICS;

-- External Frostbyte objects
USE SCHEMA EXTERNAL;
CREATE OR REPLACE FILE FORMAT PARQUET_FORMAT
    TYPE = PARQUET
    COMPRESSION = SNAPPY
;
CREATE OR REPLACE STAGE FROSTBYTE_RAW_STAGE
    URL = 's3://sfquickstarts/data-engineering-with-snowpark-python/'
;

-- ANALYTICS objects
USE SCHEMA ANALYTICS;
-- This will be added in step 5
--CREATE OR REPLACE FUNCTION ANALYTICS.FAHRENHEIT_TO_CELSIUS_UDF(TEMP_F NUMBER(35,4))
--RETURNS NUMBER(35,4)
--AS
--$$
--    (temp_f - 32) * (5/9)
--$$;

CREATE OR REPLACE FUNCTION ANALYTICS.INCH_TO_MILLIMETER_UDF(INCH NUMBER(35,4))
RETURNS NUMBER(35,4)
    AS
$$
    inch * 25.4
$$;


-- ----------------------------------------------------------------------------
-- Step #4: Create tables
-- ----------------------------------------------------------------------------

create or replace TABLE HOL_DB.HARMONIZED.ORDERS (
	ORDER_ID          NUMBER(38,0),
	TRUCK_ID          NUMBER(38,0),
	ORDER_TS          TIMESTAMP_NTZ(9),
	ORDER_TS_DATE     DATE,
	ORDER_DETAIL_ID   NUMBER(38,0),
	LINE_NUMBER       NUMBER(38,0),
	TRUCK_BRAND_NAME  VARCHAR(16777216),
	MENU_TYPE         VARCHAR(16777216),
	PRIMARY_CITY      VARCHAR(16777216),
	REGION            VARCHAR(16777216),
	COUNTRY           VARCHAR(16777216),
	FRANCHISE_FLAG    NUMBER(38,0),
	FRANCHISE_ID      NUMBER(38,0),
	FRANCHISEE_FIRST_NAME VARCHAR(16777216),
	FRANCHISEE_LAST_NAME  VARCHAR(16777216),
	LOCATION_ID      FLOAT,
	MENU_ITEM_ID     NUMBER(38,0),
	MENU_ITEM_NAME   VARCHAR(16777216),
	QUANTITY         NUMBER(38,0),
	UNIT_PRICE       NUMBER(38,4),
	PRICE            NUMBER(38,4),
	ORDER_AMOUNT     NUMBER(38,4),
	ORDER_TAX_AMOUNT      VARCHAR(16777216),
	ORDER_DISCOUNT_AMOUNT VARCHAR(16777216),
	ORDER_TOTAL           NUMBER(38,4),
	META_UPDATED_AT       TIMESTAMP_NTZ(9)
);


create or replace TABLE HOL_DB.ANALYTICS.DAILY_CITY_METRICS (
	DATE                           DATE,
	CITY_NAME                      VARCHAR(134217728),
	COUNTRY_DESC                   VARCHAR(134217728),
	DAILY_SALES                    VARCHAR(134217728),
	AVG_TEMPERATURE_FAHRENHEIT     NUMBER(38,0),
	AVG_TEMPERATURE_CELSIUS        NUMBER(38,0),
	AVG_PRECIPITATION_INCHES       NUMBER(38,0),
	AVG_PRECIPITATION_MILLIMETERS  NUMBER(38,0),
	MAX_WIND_SPEED_100M_MPH        NUMBER(38,0),
	META_UPDATED_AT                TIMESTAMP_NTZ(9)
);
