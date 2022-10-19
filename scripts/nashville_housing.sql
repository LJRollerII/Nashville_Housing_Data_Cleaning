/*Testing to see if query runs successfully
SELECT *
FROM nashville_housing*/




--===============================================================================================================--
--Standardize Date Format

SELECT sale_date, CONVERT(DATE,sale_date)
FROM nashville_housing


UPDATE nashville_housing
SET sale_date = CONVERT(DATE,sale_date)

--Alternative method if the query above doesn't work

ALTER TABLE nashville_housing
ADD sale_date_converted DATE;

Update nashville_housing
SET sale_date_converted = CONVERT(DATE,sale_date)

--You can add sale_date_converted to the select statement in the first query instead of sale_date and it will work.


--===============================================================================================================--
--Populate Property Address Data

SELECT property_address
FROM nashville_housing


SELECT property_address
FROM nashville_housing
WHERE property_address IS NULL
--We have a significant amount of null values (29) in this column.

--Alternative way to look at the null vlaues (Including the remaining columns)
SELECT *
FROM nashville_housing
WHERE property_address IS NULL

--We are now going to use Parcel ID to fill in vacant property addresses.
--Rows with the same Parcel ID should have the same property address.
--We will need to self join the table to do this.

SELECT a.parcel_id, 
	   a.property_address, 
	   b.parcel_id, 
	   b.property_address
FROM nashville_housing AS a
JOIN nashville_housing AS b
	ON a.parcel_id = b.parcel_id
	AND a.[unique_id] <> b.[unique_id]
WHERE a.property_address IS NULL
--This gives us the row and columns we want
--We'll need to add ISNULL to the select statment in order to fill in vacant property addresses.

--Let's see th results with ISNULL added to the select statement.
--ISNULL will put the vlaues from the a.property_address column into the b.property_address column.
SELECT a.parcel_id, 
	   a.property_address, 
	   b.parcel_id, 
	   b.property_address,
	   ISNULL(a.property_address, b.property_address)
FROM nashville_housing AS a
JOIN nashville_housing AS b
	ON a.parcel_id = b.parcel_id
	AND a.[unique_id] <> b.[unique_id]
WHERE a.property_address IS NULL

--When doing joins in an update statement you need to use the alias not the actual table name.
UPDATE a
SET property_address = ISNULL(a.property_address, b.property_address)
FROM nashville_housing AS a
JOIN nashville_housing AS b
	ON a.parcel_id = b.parcel_id
	AND a.[unique_id] <> b.[unique_id]
WHERE a.property_address IS NULL

--===============================================================================================================--
--Breaking out address into individual columns (Adress, City, State)