/* 
Cleaning  Data in SQL
*/

-----------------------------------------------------------------------------------------------------------------------------------------
--Standardise Date Format--

Select SaleDate from PortfolioProject.dbo.HousingData;

Select saleDateConverted, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.HousingData

Update HousingData
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE HousingData
Add SaleDateConverted Date;

Update HousingData
SET SaleDateConverted = CONVERT(Date,SaleDate)

-----------------------------------------------------------------------------------------------------------------------------------------
--Populate Property Address  ,to find null values, i.e., 47293

Select * from PortfolioProject.dbo.HousingData
where PropertyAddress is NULL;

Select a.parcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress
from PortfolioProject.dbo.HousingData a 
join PortfolioProject.dbo.HousingData b 
on a.uniqueID <> b.uniqueID and a.parcelID = b.ParcelID
where a.propertyAddress is null;

--found null values in coloumn and filling them with details of matching record
update a 
SET propertyAddress = isnull(a.propertyAddress, b.propertyAddress)
from PortfolioProject.dbo.HousingData a 
join PortfolioProject.dbo.HousingData b 
on a.uniqueID <> b.uniqueID and a.parcelID = b.ParcelID
where a.propertyAddress is null;

-----------------------------------------------------------------------------------------------------------------------------------------
--Breaking Address in individual columns (ADDRESS, CITY, STATE)
Select PropertyAddress
From PortfolioProject.dbo.HousingData
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From PortfolioProject.dbo.HousingData;


ALTER TABLE HousingData
Add PropertySplitAddress Nvarchar(255);

Update HousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE HousingData
Add PropertySplitCity Nvarchar(255);

Update HousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


--Spliting OwnerAddress Column as well into street address, city,State

Select OwnerAddress
From PortfolioProject.dbo.HousingData


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.HousingData

--Adding Columns in table and updating columns--

ALTER TABLE HousingData
Add OwnerSplitAddress Nvarchar(255);

Update HousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE HousingData
Add OwnerSplitCity Nvarchar(255);

Update HousingData
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE HousingData
Add OwnerSplitState Nvarchar(255);

Update HousingData
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


Select *
From PortfolioProject.dbo.HousingData



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.HousingData
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.HousingData


Update HousingData
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

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

From PortfolioProject.dbo.HousingData
--order by ParcelID
)
Select *
--Delete
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress



Select *
From PortfolioProject.dbo.HousingData




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
From PortfolioProject.dbo.HousingData


ALTER TABLE PortfolioProject.dbo.HousingData
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------




