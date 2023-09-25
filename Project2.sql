-- Data Cleaning Project --
SELECT * FROM NashvilleHousing

-- Convert SaleDate from Date-Time format to Date format 

SELECT NewSaleDate, CONVERT(DATE, SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashvilleHousing
ADD NewSaleDate DATE;
UPDATE NashvilleHousing
SET NewSaleDate = CONVERT(Date, SaleDate) 

-- Populate Property Address Data -- 
SELECT *
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-- Each ParcelID has a property address assocuated with it
-- For the null values in the address, we will populate it with the address which has the same ParcelID
-- For this, we will have to perform Self-Join

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

-- Breaking out PropertyAddress into individual columns ( Address, City, State)
SELECT PropertyAddress
FROM NashVilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress)) AS City
FROM NashVilleHousing 

ALTER TABLE NashvilleHousing 
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing 
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+ 1, LEN(PropertyAddress))

SELECT * FROM NashvilleHousing

-- Breaking out OwnerAddress into individual columns ( Address, City, State)

SELECT OwnerAddress FROM NashvilleHousing

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(20)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change 'Y' and 'N' to Yes and No in SoldAsVacant field

SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2 

SELECT SoldAsVacant,
CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE 
WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END 
FROM NashvilleHousing

-- Remove Duplicates 
-- We first assign these duplicates row numbers 

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) AS RowNum
FROM NashvilleHousing
)
SELECT * FROM RowNumCTE
WHERE RowNum >1

-- Now we delete these duplicates
WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
ORDER BY UniqueID) AS RowNum
FROM NashvilleHousing
)
DELETE FROM RowNumCTE
WHERE RowNum >1

-- Delete unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

SELECT * FROM NashvilleHousing



