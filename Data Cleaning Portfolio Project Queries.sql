
--Clearing Data in SQL Queries


SELECT * FROM PortfolioProject.DBO.NashvilleHousing

------------------------------------------------------------------------------------------------

--Standarize Date Format

SELECT SaleDate, CONVERT(date, SaleDate) FROM PortfolioProject.DBO.NashvilleHousing


ALTER TABLE NashvilleHousing ALTER COLUMN SaleDate DATE

------------------------------------------------------------------------------------------------

-- Populate Propoery Address data

SELECT * FROM PortfolioProject.DBO.NashvilleHousing
--WHERE PropertyAddress is null
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.DBO.NashvilleHousing a
JOIN PortfolioProject.DBO.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null


UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.DBO.NashvilleHousing a
JOIN PortfolioProject.DBO.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
-- 1. Using substrings

SELECT PropertyAddress 
FROM PortfolioProject.DBO.NashvilleHousing


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.DBO.NashvilleHousing


-- Add new columns to the table
ALTER TABLE PortfolioProject.DBO.NashvilleHousing
ADD StreetAddress NVARCHAR(255), City NVARCHAR(255);
 
-- Update the new columns with the extracted substrings

UPDATE PortfolioProject.dbo.NashvilleHousing
SET StreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));


-- 2. Parse name
SELECT OwnerAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.DBO.NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255), OwnerCity NVARCHAR(255), OwnerState NVARCHAR(255);

UPDATE PortfolioProject.dbo.NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM PortfolioProject.dbo.NashvilleHousing


UPDATE PortfolioProject.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

------------------------------------------------------------------------------------------------

-- Remove Duplicates 

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1

------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * 
FROM PortfolioProject.DBO.NashvilleHousing

ALTER TABLE PortfolioProject.DBO.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

------------------------------------------------------------------------------------------------