/*Standardize Date Formate*/

SELECT saledate,
		CONVERT(DATE, SALEDATE)
FROM Nashville;

UPDATE Nashville
SET SaleDate = CONVERT(DATE, SaleDate);


SELECT *
FROM Nashville;

ALTER TABLE Nashville
ADD SaleDate_converted date;

UPDATE Nashville
SET SaleDate_converted = CONVERT(DATE, SaleDate);

/*Populate property address data to make sure there are no null values*/

SELECT
	a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville a
JOIN Nashville b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null;

/*Breaking out address into individual columns (address, city, state)  */

SELECT PropertyAddress
FROM Nashville ;

SELECT SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1) as Property_Split_Address,
SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(propertyaddress)) as Property_Split_City
FROM Nashville ;

ALTER TABLE Nashville
ADD Property_Split_Address TEXT,
	Property_Split_City TEXT;

UPDATE Nashville
SET Property_Split_Address =  SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress)-1),
	Property_Split_City = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, LEN(propertyaddress))
FROM Nashville ;

/*Breaking out address into individual columns (address, city, state) - Use parsename */

SELECT *
FROM Nashville;

SELECT
		parsename(replace(OwnerAddress, ',', '.'), 3),
		parsename(replace(OwnerAddress, ',', '.'), 2),
		parsename(replace(OwnerAddress, ',', '.'), 1)
FROM Nashville;

ALTER TABLE Nashville
ADD Owner_Split_Address TEXT,
	Owner_Split_City TEXT,
	Owner_Split_State TEXT;

UPDATE Nashville
SET Owner_Split_Address =  parsename(replace(OwnerAddress, ',', '.'), 3),
	Owner_Split_City = parsename(replace(OwnerAddress, ',', '.'), 2),
	Owner_Split_State = parsename(replace(OwnerAddress, ',', '.'), 1)
FROM Nashville ;

----
/*Change Y and N to Yes and No in "Sold as Vacant" field - after checking the counts for Y/N/Yes/No. Decided to change Y/N to Yes/No */

SELECT distinct SoldAsVacant,
		count(SoldAsVacant)
FROM Nashville
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT
		SoldAsVacant,
		CASE When SoldAsVacant = 'Y' Then 'Yes'
			 When SoldAsVacant = 'N' Then 'No'
			 ELSE  SoldAsVacant END
FROM Nashville;

UPDATE Nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
			 When SoldAsVacant = 'N' Then 'No'
			 ELSE  SoldAsVacant END ;

/*Remove Duplicates*/

WITH Row_num_cte AS (
SELECT *,
		ROW_NUMBER() OVER(PARTITION BY ParcelID,
									PropertyAddress,
									SalePrice,
									SaleDate,
									LegalReference
						   ORDER BY UniqueID) RowNum
FROM Nashville
)
DELETE
FROM Row_num_cte
WHERE RowNum>1;

/*Delete unused columns*/
SELECT *
FROM Nashville;

ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress;

ALTER TABLE Nashville
DROP COLUMN SaleDate;
