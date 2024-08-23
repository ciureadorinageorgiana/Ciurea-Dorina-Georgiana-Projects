Select *
From ProjectPortfolio.dbo.NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From ProjectPortfolio.dbo.NashvilleHousing

--Updating the date format in the original table

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


--Populate property address data where the adress is null

Select *
From ProjectPortfolio.dbo.NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE  a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--Separating the address into individual columns (PropertyAddress: PropertySplitAddress and PropertySplitCity)  USING SUBSTRING method

Select PropertyAddress
From ProjectPortfolio.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From ProjectPortfolio.dbo.NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From ProjectPortfolio.dbo.NashvilleHousing

--Separating the address into individual columns (OwnerAddress: SplitAddress and SplitCity) USING PARSENAME method

Select OwnerAddress
From ProjectPortfolio.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From ProjectPortfolio.dbo.NashvilleHousing

Alter table NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)


Select *
From ProjectPortfolio.dbo.NashvilleHousing

--Change Y and N to Yes and No in "SoldAsVacant" field

Select Distinct SoldAsVacant, Count(SoldAsVacant)
From ProjectPortfolio.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
CASE when SoldAsVacant = 'Y' THEN 'Yes'
	 when SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From ProjectPortfolio.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
						When SoldAsVacant = 'N' Then 'No'
						ELSE SoldAsVacant
						END

--Removing Duplicates
With RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
From ProjectPortfolio.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1


--Delete Unused Column

Select *
From ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate