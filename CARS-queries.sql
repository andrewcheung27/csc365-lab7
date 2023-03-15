-- Lab 7 - CARS
-- Name: Andrew Cheung
-- Email: acheun29@calpoly.edu


USE `CARS`;
-- Q1
SELECT Make, Year, Horsepower
FROM makes JOIN cardata USING(Id)
WHERE Horsepower = (SELECT MAX(HORSEPOWER) FROM cardata);


USE `CARS`;
-- Q2
WITH mpgVehicles AS
    (SELECT *
    FROM makes JOIN cardata USING(Id)
    WHERE MPG = (SELECT MAX(MPG) FROM cardata))
SELECT Make, Year
FROM mpgVehicles
WHERE Accelerate = (SELECT MIN(Accelerate) FROM mpgVehicles);


USE `CARS`;
-- Q3
WITH makers AS
    (SELECT countries.Id AS CountryId, countries.Name AS CountryName,
        carmakers.Maker, COUNT(*) AS NumMakes
    FROM ((makes JOIN models USING(Model))
        JOIN carmakers ON models.Maker = carmakers.Id)
        JOIN countries ON carmakers.Country = countries.Id
    GROUP BY countries.Id, carmakers.Id)
SELECT CountryName AS Country, Maker
FROM makers AS m
WHERE NumMakes = (SELECT MAX(NumMakes) FROM makers WHERE m.CountryId = makers.CountryId)
ORDER BY CountryName;


USE `CARS`;
-- Q4
WITH avgWeights AS
    (SELECT carmakers.Id AS MakerId, carmakers.Maker, Year,
        AVG(Weight) AS AvgWeight, COUNT(*) AS NumVehicles,
        AVG(Accelerate) AS AvgAcc
    FROM ((makes JOIN cardata USING(Id))
        JOIN models USING(Model))
        JOIN carmakers ON models.Maker = carmakers.Id
    GROUP BY MakerId, Year)
SELECT Year, Maker, NumVehicles, AvgAcc
FROM avgWeights AS a
WHERE AvgWeight = (SELECT MAX(AvgWeight)
                    FROM avgWeights
                    WHERE a.Year = avgWeights.Year AND NumVehicles > 1)
ORDER BY Year;


USE `CARS`;
-- Q5
SELECT
    (SELECT MAX(MPG)
        FROM makes JOIN cardata USING(Id)
        WHERE Cylinders = 8)
    -
    (SELECT MIN(MPG)
        FROM makes JOIN cardata USING(Id)
        WHERE Cylinders = 4)
    AS difference;


USE `CARS`;
-- Q6
WITH usa AS
    (SELECT Year, COUNT(*) AS USCars
    FROM (((makes JOIN cardata USING(Id))
        JOIN models USING(Model))
        JOIN carmakers ON models.Maker = carmakers.Id)
        JOIN countries ON carmakers.Country = countries.Id
    WHERE countries.Name = 'usa'
        AND Year >= 1972 AND Year <= 1976
    GROUP BY Year),
non_usa AS
    (SELECT Year, COUNT(*) AS nonUSCars
    FROM (((makes JOIN cardata USING(Id))
        JOIN models USING(Model))
        JOIN carmakers ON models.Maker = carmakers.Id)
        JOIN countries ON carmakers.Country = countries.Id
    WHERE countries.Name != 'usa'
        AND Year >= 1972 AND Year <= 1976
    GROUP BY Year)
SELECT Year,
    CASE
        WHEN USCars > nonUSCars THEN 'us'
        WHEN USCars < nonUSCars THEN 'rest of the world'
        ELSE 'tie'
    END AS CarLeader
FROM usa JOIN non_usa USING(Year);
