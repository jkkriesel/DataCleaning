Select *
From NashvilleHousing

--Standardized the date format

Select SaleDate, CONVERT(Date,SaleDate)
From NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

--It is not updating the date, so I decided to alter the table to see if that would update the column

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


--Populated property address data

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Broke the address into individual columns

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
From NashvilleHousing

Alter Table NashvilleHousing
Add 
PropertySplitAddress Nvarchar(255),
PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET 
PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1),
PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Cleaning up the owner address

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State
From NashvilleHousing

Alter Table NashvilleHousing
Add 
OwnerSplitAddress Nvarchar(255),
OwnerSplitCity Nvarchar(255),
OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET 
OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Changed the Y/N in SoldAsVacant column to Yes/No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--Removing Duplicates in the data

--WITH RowNumCTE AS(
--Select *,
--	ROW_NUMBER() OVER (
--	PARTITION BY ParcelID,
--				 PropertySplitAddress,
--				 SalePrice,
--				 SaleDateConverted,
--				 LegalReference
--				 ORDER BY
--					UniqueID
--					) row_num

--From NashvilleHousing
--)
--Delete
--From RowNumCTE
--Where row_num > 1
----Order by PropertySplitAddress


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertySplitAddress,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
--Order by PropertySplitAddress





--Deleted unused columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate