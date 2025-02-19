create database ev_sales;
 use ev_sales;
 
 # rename table name as it is same as the database name
 
 alter table ev_sales
 rename to electric_vehicle ;
 
 -- first thing we want to do is create a staging table. This is the one we will work in and clean the data. We want a table with the raw data in case something happens
 
 create table electric_vehicles
 like electric_vehicle;
 
 insert into electric_vehicles
 select * from electric_vehicle;
 
 # checking first few rows
 
 select * from electric_vehicles
 limit 10;



-- now when we are data cleaning we usually follow a few steps
-- 1. check for duplicates and remove any
-- 2. standardize data and fix errors
-- 3. Look at null values and see what 
-- 4. remove any columns and rows that are not necessary - few ways

-- A. Remove Duplicates

-- we can do this by different ways but we dont have any unique column here so we have to do it by differnt method

# First let's check for duplicates

select * from electric_vehicles;

select *, row_number() over( partition by `year` , month_name , `date` , state , vehicle_class , vehicle_category , vehicle_type , ev_sales_quantity ) as row_num
from electric_vehicles;

# TO CHECK DUPLICATES , CHECK WHERE ROW_NUM > 1

with duplicates as(
select *, row_number() over( partition by `year` , month_name , `date` , state , vehicle_class , vehicle_category , vehicle_type , ev_sales_quantity ) as row_num
from electric_vehicles )

select * from duplicates
where row_num>1;

# as we dont get any data here , therefore we dont have any duplicate values 



-- B. Standardizing Data ( finding issues in data and fixing it)

select * from electric_vehicles;


-- check for distinct values in every column
select distinct `year` from electric_vehicles;

select distinct month_name from electric_vehicles;

select distinct state from electric_vehicles;

select distinct vehicle_class from electric_vehicles;

select distinct Vehicle_Category from electric_vehicles;

select distinct vehicle_type from electric_vehicles;

select distinct ev_sales_quantity from electric_vehicles;

-- now , getting column details

describe electric_vehicles;

-- it shows datatype of year as float , date as text , ev_sales_quantity as float . which are not correct. so we need to change them
-- 1. for year column
     
     select `year` from electric_vehicles;
     
      -- changing datatype 
      alter table electric_vehicles
      modify column `year` int;
      
-- 2. for date column
     
     -- changing format
     select `date` , str_to_date(`date` , "%m/%d/%Y")
     from electric_vehicles;
     
      -- updating (changing format first)
      update electric_vehicles
      set `date`= str_to_date(`date`,'%m/%d/%Y');
      
      -- this will not change the datatype of date , so we have to do one more step for it

      alter table electric_vehicles
      modify column `date` date;
      -- datatype changed
     
-- 3. for ev_sales_quantity column
     
     select ev_sales_quantity from electric_vehicles;
     
      -- changing datatype 
      alter table electric_vehicles
      modify column ev_sales_quantity int;




-- C. Look at Null Values

select sum( case when `year` is null then 1 else 0 end),
sum( case when month_name is null then 1 else 0 end),
sum( case when `date` is null then 1 else 0 end),
sum( case when state is null then 1 else 0 end),
sum( case when vehicle_class is null then 1 else 0 end),
sum( case when vehicle_category is null then 1 else 0 end),
sum( case when vehicle_type is null then 1 else 0 end),
sum( case when ev_sales_quantity is null then 1 else 0 end)
 from electric_vehicles;
 
 -- no null values present
 
 
 
 
 -- D. remove any columns and rows we need to
 
 -- no columns to remove . DATA IS CLEANED
 
 
 
 
 
 
 ----------- FEATURE ENGINEERING ------------
 
 -- ADD QUARTER COLUMN
 
 alter table electric_vehicles
 add column quarters varchar(10);
 
 update electric_vehicles
 set quarters= case when month_name in("jan","feb","mar") then "Q1"
                                 when month_name in("apr","may","jun") then "Q2"
                                 when month_name in("jul","aug","sep") then "Q3"
                                 else "Q4"
                            END ;
                            
 

 
 ---- ADD DAY OF WEEK COLUMN
 
  alter table electric_vehicles
  add column day_of_week varchar(20);
  
  update electric_vehicles
  set day_of_week = dayname(`date`);