
SELECT * FROM PortfolioProject..NashVilleHousing

--Standardize date format
SELECT SaleDateConverted, CAST(SaleDate as date) FROM PortfolioProject..NashVilleHousing

UPDATE NashVilleHousing
SET SaleDate = CAST(SaleDate as date)

ALTER TABLE NashVilleHousing
ADD SaleDateConverted Date

UPDATE NashVilleHousing
SET SaleDateConverted = CAST(SaleDate as date)


--populate Property Address

SELECT * FROM PortfolioProject..NashVilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashVilleHousing a
JOIN PortfolioProject..NashVilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Breaking out Address into individual column (Address,City,State)
SELECT PropertyAddress 
FROM PortfolioProject..NashVilleHousing
--ORDER BY ParcelID 

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) City
FROM PortfolioProject..NashVilleHousing

ALTER TABLE NashVilleHousing
ADD PropertySplitAddress nvarchar(255)

Update NashVilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashVilleHousing
ADD PropertySplitCity nvarchar(255)

Update NashVilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT * FROM NashVilleHousing

SELECT OwnerAddress
FROM NashVilleHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM NashVilleHousing

ALTER TABLE NashVilleHousing
ADD OwnerSplitAddress nvarchar(255)

Update NashVilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashVilleHousing
ADD OwnerSplitCity nvarchar(255)

Update NashVilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashVilleHousing
ADD OwnerSplitState nvarchar(255)

Update NashVilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

SELECT * FROM NashVilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant)
FROM NashVilleHousing

SELECT SoldAsVacant ,CASE
			WHEN SoldAsVacant = 'N' THEN 'No'
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
		END
FROM NashVilleHousing

Update NashVilleHousing
SET SoldAsVacant = CASE
			WHEN SoldAsVacant = 'N' THEN 'No'
			WHEN SoldAsVacant = 'Y' THEN 'Yes'
			ELSE SoldAsVacant
		END


--Remove Duplicates
WITH RowNumCTE
as(
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
FROM NashVilleHousing)
SELECT * FROM RowNumCTE
WHERE row_num > 1
--ORDER BY ParcelID


--Delete Unused Columns
SELECT *
FROM NashVilleHousing 

ALTER TABLE NashVilleHousing
DROP COLUMN OwnerAddress, TaxDistrict ,PropertyAddress

ALTER TABLE NashVilleHousing
DROP COLUMN SaleDate