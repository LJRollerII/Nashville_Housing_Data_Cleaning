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
--Breaking out address into individual columns (Address, City, State)
--We will do this with the property address and owner's address columns

SELECT property_address
FROM nashville_housing

--We'll need to use a substring
--Substrings require 3 arguments
--For the substring 1 = position 1
--Use -1 to get rid of the comma when you run the query.
--For the second substring CHARINDEX(',', property_address) + 1 will be the position
SELECT
SUBSTRING(property_address, 1, CHARINDEX(',', PropertyAddress) -1) AS address,
SUBSTRING(property_address, CHARINDEX(',', property_address) + 1 , LEN(property_address)) AS address
FROM nashville_housing

--We'll need to add two new cloumns to seperate City & State
--In python you can seperate two values in one column without making two new columns.
--It's recommended to run the add query first, then the update query.

ALTER TABLE nashville_housing
ADD popertysplit_address Nvarchar(255);

UPDATE nashville_housing
SET popertysplit_address = SUBSTRING(property_address, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE nashville_housing
ADD popertysplit_city Nvarchar(255);

UPDATE nashville_housing
SET popertysplit_city = SUBSTRING(property_address, CHARINDEX(',', property_address) + 1 , LEN(property_address))

--Let's use select all once we've altered and updated table to see if the new columns/updates are present.
SELECT *
FROM nashville_housing



--Now let's work on the owner's address
SELECT owner_address
FROM nashville_housing

--In this query we'll use PARSENAME
--PARSENAME is only useful with periods, so we'll have to replace our commas with periods.
--We use 3,2,1 because that will give us the Address, City, & State in the order we want.
--Using 1,2,3 would make our order(Address, City, & State) backwards.
SELECT
PARSENAME(REPLACE(owner_address, ',', '.') , 3),
PARSENAME(REPLACE(owner_address, ',', '.') , 2),
PARSENAME(REPLACE(owner_address, ',', '.') , 1)
FROM nashville_housing

ALTER TABLE nashville_housing
ADD ownersplit_address Nvarchar(255);

UPDATE nashville_housing
SET ownersplit_address = PARSENAME(REPLACE(owner_address, ',', '.') , 3)


ALTER TABLE nashville_housing
ADD ownersplit_city Nvarchar(255);

UPDATE nashville_housing
SET ownersplit_city = PARSENAME(REPLACE(owner_address, ',', '.') , 2)

ALTER TABLE nashville_housing
ADD ownersplit_state Nvarchar(255);

UPDATE nashville_housing
SET ownersplit_state = PARSENAME(REPLACE(owner_address, ',', '.') , 1)

--Let's use select all once we've altered and updated table to see if the new columns/updates are present.
SELECT *
FROM nashville_housing

--===============================================================================================================--

-- Change Y and N to Yes and No in "Sold as Vacant" column

SELECT DISTINCT sold_as_vacant
FROM nashville_housing
--As of now the values once you run the query are Yes,Y,No, N

--Let's look at this in a count
SELECT DISTINCT sold_as_vacant, COUNT(sold_as_vacant)
FROM nashville_housing
GROUP BY sold_as_vacant
ORDER BY 2
-- Y = 52, N = 399, Y = 4623 , N = 51403
-- When we clean this data, it should look like  Yes = 4675 & No = 51802

--We'll use a CASE statement to clean this data
SELECT sold_as_vacant,
CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
WHEN sold_as_vacant = 'N' THEN 'No'
ELSE sold_as_vacant
END
FROM nashville_housing

UPDATE nashville_housing
SET sold_as_vacant = CASE WHEN sold_as_vacant = 'Y' THEN 'Yes'
WHEN sold_as_vacant = 'N' THEN 'No'
ELSE sold_as_vacant
END
--Update worked and numbers are correct

--===============================================================================================================--
-- Remove Duplicates

--We will run a CTE with some windom functions to do this.
--The window functions will help us find the duplicates
-- We will partition by things that are unique to the rows

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY parcel_id,
				 property_address,
				 sale_price,
				 sale_date,
				 legal_reference
				 ORDER BY
					unique_id
					) row_num

FROM nashville_housing
)

SELECT * --Insert DELETE here to delete the duplicate rows. Then use SELECT * again to make sure they're deleted.
FROM RowNumCTE
WHERE row_num > 1
ORDER BY property_address



SELECT *
FROM nashville_housing

--===============================================================================================================--
-- Delete Unused Columns

SELECT *
FROM nashville_housing


ALTER TABLE nashville_housing
DROP COLUMN owner_address, tax_district, property_address, sale_date

--===============================================================================================================--
