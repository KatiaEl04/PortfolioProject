/*
Cleaning Data in SQL Queries
*/

select *
from Portfolio_Project.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------
--Standardize Data Format
select SaleDateConverted, CONVERT(Date,SaleDate)
from Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing 
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

--------------------------------------------------------------------------------------------------------------------------
--Populate Proberty Adress data
select *
from Portfolio_Project.dbo.NashvilleHousing
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
join Portfolio_Project.dbo.NashvilleHousing b
    ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from Portfolio_Project.dbo.NashvilleHousing a
join Portfolio_Project.dbo.NashvilleHousing b
    ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]

--------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into Individual Columns(Address,City,State)
select PropertyAddress
from Portfolio_Project.dbo.NashvilleHousing

select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as Address
from Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing 
Add ProbertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET ProbertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing 
Add ProbertySplitCity Nvarchar(255);

Update NashvilleHousing
SET ProbertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

select *
from Portfolio_Project.dbo.NashvilleHousing


select OwnerAddress
from Portfolio_Project.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) 
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
from Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing 
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing 
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing 
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

select *
from Portfolio_Project.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and N o is "Sold as Vacant" field
select Distinct(SoldAsVacant), count(SoldAsVacant)
from Portfolio_Project.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
from Portfolio_Project.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------------------------------
--Remove Duplicates
WITH RowNumCTE AS(
Select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
				    UniqueID
					) row_num

From Portfolio_Project.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1

--------------------------------------------------------------------------------------------------------------------------
--Delete Unused Columns
select *
from Portfolio_Project.dbo.NashvilleHousing

ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN  OwnerAddress,TaxDistrict, PropertyAddress,SaleDate



 