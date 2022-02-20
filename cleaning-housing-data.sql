/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM housing

ALTER TABLE housing
RENAME COLUMN "UniqueID " TO UniqueID;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT SaleDate, SaleDateConverted
FROM housing;

UPDATE housing
SET SaleDate = Date(Saledate)

-- If it doesn't Update properly
ALTER TABLE housing
ADD SaleDateConverted TEXT;

UPDATE housing
SET SaleDateConverted = Date(Saledate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
SELECT *
FROM housing
WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT *
FROM housing a
JOIN housing b ON a.ParcelID = b.ParcelID 
AND a.UniqueID != b.UniqueID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress,b.PropertyAddress)
FROM housing a
JOIN housing b ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE housing
SET PropertyAddress = joined.val
FROM (SELECT ifnull(a.PropertyAddress,b.PropertyAddress) as val FROM housing a
	JOIN housing b ON a.ParcelID = b.ParcelID AND a.UniqueID != b.UniqueID) AS joined
WHERE housing.PropertyAddress is NULL

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
FROM housing

SELECT substr(PropertyAddress,1, instr(PropertyAddress,",")-1) as Address, 
	substr(PropertyAddress,instr(PropertyAddress,",")+1) as City
FROM housing

SELECT substr(PropertyAddress,1, instr(PropertyAddress,",")-1) as Address, 
	substr(PropertyAddress,instr(PropertyAddress,",")+1, length(PropertyAddress)) as City
FROM housing

ALTER TABLE housing
ADD PropAddress TEXT;

ALTER TABLE housing
ADD PropCity TEXT;

UPDATE housing
SET PropAddress = substr(PropertyAddress,1, instr(PropertyAddress,",")-1),
PropCity = substr(PropertyAddress,instr(PropertyAddress,",")+1, length(PropertyAddress))

SELECT substr(OwnerAddress,1, instr(PropertyAddress,",")-1) as Address, 
	substr(substr(OwnerAddress,instr(OwnerAddress,",")+1),1,instr(substr(OwnerAddress,instr(OwnerAddress,",")+1),",")-1) as City,
	substr(substr(OwnerAddress,instr(OwnerAddress,",")+1),instr(substr(OwnerAddress,instr(OwnerAddress,",")+1),",")+1) as State
FROM housing

ALTER TABLE housing
ADD OwnAddress TEXT;

ALTER TABLE housing
ADD OwnCity TEXT;

ALTER TABLE housing
ADD OwnState TEXT;

UPDATE housing
SET OwnAddress = substr(OwnerAddress,1, instr(PropertyAddress,",")-1),
	OwnCity = substr(substr(OwnerAddress,instr(OwnerAddress,",")+1),1,instr(substr(OwnerAddress,instr(OwnerAddress,",")+1),",")-1),
	OwnState = substr(substr(OwnerAddress,instr(OwnerAddress,",")+1),instr(substr(OwnerAddress,instr(OwnerAddress,",")+1),",")+1);

--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), count(SoldAsVacant)
FROM housing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = "Y" THEN "Yes"
	WHEN SoldAsVacant = "N" THEN "No"
	ELSE SoldAsVacant
END as New
FROM housing

UPDATE housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = "Y" THEN "Yes"
	WHEN SoldAsVacant = "N" THEN "No"
	ELSE SoldAsVacant
END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
SELECT *,
row_number() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num 
FROM housing
ORDER BY row_num DESC

With CheckDupCTE as(
SELECT *,
row_number() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num 
FROM housing
)
SELECT *
FROM CheckDupCTE
WHERE row_num > 1

With CheckDupCTE as(
SELECT *,
row_number() OVER (
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num 
FROM housing
)
DELETE
FROM housing
WHERE UniqueID in (SELECT UniqueID FROM CheckDupCTE WHERE row_num > 1)

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
ALTER TABLE housing
DROP COLUMN OwnerAddress;

ALTER TABLE housing
DROP COLUMN PropertyAddress;

ALTER TABLE housing
DROP COLUMN TaxDistrict;

-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	(Havent tried)

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO
