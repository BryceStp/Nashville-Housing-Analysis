SELECT *
FROM NashHousing.dbo.HousingDB

--Clean up SaleDate (for some reason time was included, but not actually provided)

/*
SELECT CONVERT(Date,SaleDate)
FROM NashHousing.dbo.HousingDB
*/

ALTER TABLE NashHousing.dbo.HousingDB
ADD SaleDateConvert Date

UPDATE NashHousing.dbo.HousingDB
SET SaleDateConvert = CONVERT(Date,SaleDate)

/*SELECT *
FROM NashHousing.dbo.HousingDB*/

--Fill null Values in Property Address

/*SELECT *
FROM NashHousing.dbo.HousingDB
WHERE PropertyAddress IS NULL
ORDER BY ParcelID*/

--Null values in Fill are getting populated with values that share the same ParcelID in Popu, but also have different UniqueIDs
--Works because we have duplicate ParcelIDs already linked to an address

SELECT Fill.ParcelID,Fill.PropertyAddress,Popu.ParcelID,Popu.PropertyAddress, ISNULL(Fill.PropertyAddress,Popu.PropertyAddress) 
FROM NashHousing.dbo.HousingDB Fill
JOIN NashHousing.dbo.HousingDB Popu
ON Fill.ParcelID=Popu.ParcelID
AND Fill.UniqueID <> Popu.UniqueID
WHERE Fill.PropertyAddress IS NULL

UPDATE Fill
SET PropertyAddress=ISNULL(Fill.PropertyAddress,Popu.PropertyAddress)
FROM NashHousing.dbo.HousingDB Fill
JOIN NashHousing.dbo.HousingDB Popu
ON Fill.ParcelID=Popu.ParcelID
AND Fill.UniqueID <> Popu.UniqueID
WHERE Fill.PropertyAddress IS NULL

/*SELECT *
FROM NashHousing.dbo.HousingDB*/

--Separating PropertyAddress into (Address,City)

SELECT PropertyAddress
FROM NashHousing.dbo.HousingDB

SELECT SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM NashHousing.dbo.HousingDB

ALTER TABLE NashHousing.dbo.HousingDB
ADD PropertySplitAddress Nvarchar(255)

ALTER TABLE NashHousing.dbo.HousingDB
ADD PropertySplitCity Nvarchar(255)

UPDATE NashHousing.dbo.HousingDB
SET PropertySplitAddress=SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1) 

UPDATE NashHousing.dbo.HousingDB
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

/*SELECT *
FROM NashHousing.dbo.HousingDB*/

SELECT OwnerAddress
FROM NashHousing.dbo.HousingDB

--Now We split the OwnerAddress into (Address,City,State)

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashHousing.dbo.HousingDB

ALTER TABLE NashHousing.dbo.HousingDB
ADD OwnerSplitAddress Nvarchar(255)

ALTER TABLE NashHousing.dbo.HousingDB
ADD OwnerSplitCity Nvarchar(255)

ALTER TABLE NashHousing.dbo.HousingDB
ADD OwnerSplitState Nvarchar(255)

UPDATE NashHousing.dbo.HousingDB
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

UPDATE NashHousing.dbo.HousingDB
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

UPDATE NashHousing.dbo.HousingDB
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

/*SELECT *
FROM NashHousing.dbo.HousingDB*/

--Change Y and N to Yes and No in Sold as Vacant (we currently have Y,N,Yes,No filling the field)

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashHousing.dbo.HousingDB
GROUP BY SoldAsVacant

SELECT SoldAsVacant,CASE WHEN SoldAsVacant='Y' Then 'Yes'
WHEN SoldAsVacant='N' Then'No'
ELSE SoldAsVacant
END
FROM NashHousing.dbo.HousingDB

UPDATE NashHousing.dbo.HousingDB
SET SoldAsVacant = CASE WHEN SoldAsVacant='Y' Then 'Yes'
WHEN SoldAsVacant='N' Then'No'
ELSE SoldAsVacant
END
FROM NashHousing.dbo.HousingDB

--Removing Duplicates

WITH ROWNUMCTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY ParcelID,SalePrice,SaleDate,LegalReference,PropertyAddress
ORDER BY UniqueID) AS RowNum
FROM NashHousing.dbo.HousingDB)
SELECT *
FROM ROWNUMCTE
where RowNum>1

SELECT *
FROM NashHousing.dbo.HousingDB

--Delete unwanted columns

ALTER TABLE NashHousing.dbo.HousingDB
DROP COLUMN OwnerAddress,PropertyAddress,SaleDate



