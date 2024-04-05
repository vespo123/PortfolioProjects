--Cleaning Data in SQL



Select *
from [Portfolio Project].dbo.NashvilleHousing


-- Standardize Date Format 


Select SaleDateConverted, CONVERT(Date,SaleDate)
from [Portfolio Project].dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)




--- Populate Property Address data

Select *
from [Portfolio Project].dbo.NashvilleHousing
--WHERE PropertyAddress is null
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
from [Portfolio Project].dbo.NashvilleHousing a
JOIN [Portfolio Project].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



---Breaking out Adress into Individual Columns (Address, City, State)


Select PropertyAddress
from [Portfolio Project].dbo.NashvilleHousing
--WHERE PropertyAddress is null
--Order By ParcelID


Select
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as Address
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1 , LEN(PropertyAddress)) as Address

from [Portfolio Project].dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))


select *
from [Portfolio Project].dbo.NashvilleHousing



select OwnerAddress
from [Portfolio Project].dbo.NashvilleHousing


Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

from [Portfolio Project].dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)



ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)


select *
from [Portfolio Project].dbo.NashvilleHousing



-- Change Y and N to Yes and NO in "Sold as vacant" field



Select Distinct(SoldAsVacant), Count(SoldAsVacant)
from [Portfolio Project].dbo.NashvilleHousing
group by SoldAsVacant
order by 2 



select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END
from [Portfolio Project].dbo.NashvilleHousing




UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	ELSE SoldAsVacant
	END




	--remove duplicates 

WITH RowNumCTE AS(
select *,
ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			ORDER BY 
				UniqueID
				) Row_num
from [Portfolio Project].dbo.NashvilleHousing
--Order by ParcelID
)
select *
From RowNumCTE
where Row_num > 1 
--order by PropertyAddress









--- delete unused columns 







select *
from [Portfolio Project].dbo.NashvilleHousing

Alter table [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress


Alter table [Portfolio Project].dbo.NashvilleHousing
DROP COLUMN SaleDate

