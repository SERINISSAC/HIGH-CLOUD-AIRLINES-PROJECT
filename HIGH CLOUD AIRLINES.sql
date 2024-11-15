use high_cloud;
select * from maindata;
select count(*) from maindata;
Describe maindata;
alter table maindata change `%Airline ID` Airline_ID int DEFAULT NULL;
alter table maindata change `%Carrier Group ID` Carrier_Group_ID int DEFAULT NULL;
alter table maindata change `%Unique Carrier Code` Unique_Carrier_Code text;
alter table maindata change `%Unique Carrier Entity Code` Unique_Carrier_Entity_Code int default null;
alter table maindata change `%Region Code` Region_Code text;
alter table maindata change `%Origin Airport ID` Origin_Airport_ID int default null;
alter table maindata change `%Origin Airport Sequence ID` Origin_Airport_Sequence_ID int default null;
alter table maindata change `%Origin Airport Market ID` Origin_Airport_Market_ID int default null;
alter table maindata change `%Origin World Area Code` Origin_World_Area_Code int default null;
alter table maindata change `%Destination Airport ID` Destination_Airport_ID int default null;
alter table maindata change `%Destination Airport Sequence ID` Destination_Airport_Sequence_ID int default null;
alter table maindata change  `Destination City` Destination_City text;
alter table maindata change  `Destination State Code` Destination_State_Code text;
alter table maindata change  `Destination State FIPS` Destination_State_FIPS int default null;
alter table maindata change  `Destination State` Destination_State text;
alter table maindata change  `Destination Country Code` Destination_Country_Code text;
alter table maindata change  `Destination Country` Destination_Country text;
alter table maindata change  `From - To Airport Code` From_To_Airport_Code text;
alter table maindata change  `From - To Airport ID` From_To_Airport_ID text;
alter table maindata change  `From - To City` From_To_City text;
alter table maindata change  `From - To State Code` From_To_State_Code text;
alter table maindata change  `From - To State` From_To_State text;
Select * from maindata;



UPDATE maindata
SET date_field = STR_TO_DATE(CONCAT(`Year`, '-', `Month (#)`, '-', `Day`), "%Y-%m-%d");
SELECT YEAR(date_field) AS Year FROM maindata;
SELECT MONTH(date_field) AS Monthno FROM maindata;
SELECT MONTHNAME(date_field) AS Monthfullname FROM maindata;
SELECT QUARTER(date_field) AS Quarter FROM maindata;
SELECT CONCAT(YEAR(date_field), '-', LEFT(MONTHNAME(date_field), 3)) AS YearMonth FROM maindata;
SELECT DAYOFWEEK(date_field) AS Weekdayno FROM maindata;
SELECT DAYNAME(date_field) AS Weekdayname FROM maindata;
SELECT CASE
    WHEN MONTH(date_field) >= 4 THEN MONTH(date_field) - 3
    ELSE MONTH(date_field) + 9
END AS FinancialMonth
FROM maindata;
SELECT CASE
    WHEN MONTH(date_field) BETWEEN 4 AND 6 THEN 'Q1'
    WHEN MONTH(date_field) BETWEEN 7 AND 9 THEN 'Q2'
    WHEN MONTH(date_field) BETWEEN 10 AND 12 THEN 'Q3'
    ELSE 'Q4'
END AS FinancialQuarter
FROM maindata;

-- KPI 1 (calcuate the following fields from the Year	Month (#)	Day  fields ( First Create a Date Field from Year , Month , Day fields)

SELECT 
    YEAR(date_field) AS Year,
    MONTH(date_field) AS Monthno,
    MONTHNAME(date_field) AS Monthfullname,
    QUARTER(date_field) AS Quarter,
    CONCAT(YEAR(date_field), '-', LEFT(MONTHNAME(date_field), 3)) AS YearMonth,
    DAYOFWEEK(date_field) AS Weekdayno,
    DAYNAME(date_field) AS Weekdayname,
    CASE
        WHEN MONTH(date_field) >= 4 THEN MONTH(date_field) - 3
        ELSE MONTH(date_field) + 9
    END AS FinancialMonth,
    CASE
        WHEN MONTH(date_field) BETWEEN 4 AND 6 THEN 'Q1'
        WHEN MONTH(date_field) BETWEEN 7 AND 9 THEN 'Q2'
        WHEN MONTH(date_field) BETWEEN 10 AND 12 THEN 'Q3'
        ELSE 'Q4'
    END AS FinancialQuarter
FROM maindata;

-- KPI 2 (Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

-- Yearly Load Factor
SELECT 
    YEAR(date_field) AS Year,
    SUM(`# Transported Passengers`) AS Total_Transported_Passengers,
    SUM(`# Available Seats`) AS Total_Available_Seats,
    (SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100) AS Load_Factor_Percentage
FROM maindata
GROUP BY YEAR(date_field);

-- Quarterly Load Factor
SELECT 
    CONCAT(YEAR(date_field), '-Q', QUARTER(date_field)) AS Year_Quarter,
    SUM(`# Transported Passengers`) AS Total_Transported_Passengers,
    SUM(`# Available Seats`) AS Total_Available_Seats,
    (SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100) AS Load_Factor_Percentage
FROM maindata
GROUP BY Year_Quarter;

-- Monthly Load Factor
SELECT 
    CONCAT(YEAR(date_field), '-', LPAD(MONTH(date_field), 2, '0')) AS Month_Year,
    SUM(`# Transported Passengers`) AS Total_Transported_Passengers,
    SUM(`# Available Seats`) AS Total_Available_Seats,
    (SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100) AS Load_Factor_Percentage
FROM maindata
GROUP BY Month_year;

-- KPI 3 (Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)

SELECT 
    `Carrier Name` AS Carrier_Name,
    SUM(`# Transported Passengers`) AS Total_Transported_Passengers,
    SUM(`# Available Seats`) AS Total_Available_Seats,
    (SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100) AS Load_Factor_Percentage
FROM maindata
GROUP BY `Carrier Name`
ORDER BY Load_Factor_Percentage DESC;

-- KPI 4 ( Identify Top 10 Carrier Names based passengers preference )

SELECT 
    `Carrier Name` AS Carrier_Name,
    SUM(`# Transported Passengers`) AS Total_Transported_Passengers
FROM maindata
GROUP BY `Carrier Name`
ORDER BY Total_Transported_Passengers DESC
LIMIT 10;

-- KPI5 ( Display top Routes ( from-to City) based on Number of Flights )
SELECT 
    CONCAT(`Origin City`, ' - ', `Destination_City`) AS Route,
    COUNT(`# Departures Performed`) AS Total_Flights
FROM maindata
GROUP BY `Origin City`, `Destination_City`
ORDER BY Total_Flights DESC
LIMIT 10;

-- KPI6 (Identify the how much load factor is occupied on Weekend vs Weekdays)

SELECT 
    CASE 
        WHEN DAYOFWEEK(date_field) IN (1, 7) THEN 'Weekend'  -- 1 = Sunday, 7 = Saturday
        ELSE 'Weekday'
    END AS Day_Type,
    SUM(`# Transported Passengers`) AS Total_Transported_Passengers,
    SUM(`# Available Seats`) AS Total_Available_Seats,
    (SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100) AS Load_Factor_Percentage
FROM maindata
GROUP BY Day_Type;

-- KPI7 (Identify number of flights based on Distance group)
SELECT 
    `%Distance Group ID` AS Distance_Group,
    COUNT(`# Departures Performed`) AS Total_Flights
FROM maindata
GROUP BY `%Distance Group ID`
ORDER BY Total_Flights DESC;

