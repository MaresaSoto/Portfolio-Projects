/*
Cleaning Data in SQL Queries
*/

SELECT *
FROM NashvilleHousing

-- Standardize Date Format

SELECT SaleDateConverted, Convert(Date, SaleDate)
FROM NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(Date, Saledate)


ALter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)


--Populate Property Address Date

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID, NH2.PropertyAddress, ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM NashvilleHousing NH1
JOIN NashvilleHousing NH2
on NH1.ParcelID = NH2.ParcelID
and NH1.[UniqueID ] <> NH2. [UniqueID ]
WHERE NH1.PropertyAddress is NULL

Update NH1
SET PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM NashvilleHousing NH1
JOIN NashvilleHousing NH2
on NH1.ParcelID = NH2.ParcelID
and NH1.[UniqueID ] <> NH2. [UniqueID ]
WHERE NH1.PropertyAddress is NULL

-- Breaking out Address into Individual Columns (address, City, State)

Select PropertyAddress 
From NashvilleHousing

Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, Len(PropertyAddress))


--Use Parsename instead of Substring to break up address into individual columns

Select OwnerAddress
from NashvilleHousing

Select
Parsename(Replace(OwnerAddress, ',', '.'), 3),
Parsename(Replace(OwnerAddress, ',', '.'), 2),
Parsename(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = Parsename(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = Parsename(Replace(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant) as CountSoldAsVacant 
From NashvilleHousing 
Group By SoldAsVacant
Order By CountSoldAsVacant

Select SoldAsVacant,
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
From NashvilleHousing 

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

-- Remove Duplicates
With RowNumCTE AS(
Select *, 
	ROW_NUMBER() Over (
	Partition By ParcelID, 
				 PropertyAddress,
				 SalePRice,
				 SaleDate,
				 LegalReference
				 Order By 
					UniqueID
					) row_num
From NashvilleHousing
--Order By ParcelID
)
Delete
From RowNumCTE
Where row_num >1
--Order by PropertyAddress

--Delete Unused Columns

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate