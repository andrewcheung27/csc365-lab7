-- Lab 7 - WINE
-- Name: Andrew Cheung
-- Email: acheun29@calpoly.edu


USE `WINE`;
-- Q1
WITH numwines AS
    (SELECT Grape, COUNT(*) AS NumWines
    FROM (wine JOIN grapes USING(Grape))
        JOIN appellations USING(Appellation)
    WHERE Color = 'Red'
        AND County = 'San Luis Obispo'
    GROUP BY Grape)
SELECT Grape
FROM (wine JOIN grapes USING(Grape))
    JOIN appellations USING(Appellation)
WHERE Color = 'Red'
    AND County = 'San Luis Obispo'
GROUP BY Grape
HAVING COUNT(*) = (SELECT MAX(NumWines) FROM numwines)
ORDER BY Grape;


USE `WINE`;
-- Q2
WITH numwines AS
    (SELECT Grape, COUNT(*) AS NumWines
    FROM wine
    WHERE Score >= 93
    GROUP BY Grape)
SELECT Grape
FROM wine
WHERE Score >= 93
GROUP BY Grape
HAVING COUNT(*) = (SELECT MAX(NumWines) FROM numwines);


USE `WINE`;
-- Q3
WITH numcases AS
    (SELECT ROW_NUMBER() OVER(ORDER BY Cases DESC) AS CaseRank, Cases
    FROM wine)
SELECT Winery, Name, Cases
FROM wine
WHERE wine.Cases = (SELECT Cases FROM numcases WHERE CaseRank = 37);


USE `WINE`;
-- Q4
WITH grenaches AS
    (SELECT Score
    FROM wine
    WHERE Vintage = 2007
        AND Grape = 'Grenache')
SELECT Winery, Name, Appellation, Score, Price
FROM wine
WHERE Grape = 'Zinfandel'
    AND Vintage = 2008
    AND Score >= (SELECT MAX(Score) FROM grenaches);


USE `WINE`;
-- Q5
WITH dcv AS
    (SELECT Appellation, Vintage, MAX(Score) AS maxscore
    FROM wine
    WHERE Appellation = 'Dry Creek Valley'
        AND Vintage >= 2005
        AND Vintage <= 2009
    GROUP BY Appellation, Vintage),
carn AS
    (SELECT Appellation, Vintage, MAX(Score) AS maxscore
    FROM wine
    WHERE Appellation = 'Carneros'
        AND Vintage >= 2005
        AND Vintage <= 2009
    GROUP BY Appellation, Vintage)
SELECT DISTINCT
    (SELECT COUNT(*)
    FROM dcv JOIN carn USING(Vintage)
    WHERE dcv.maxscore > carn.maxscore) AS DCV,
    (SELECT COUNT(*)
    FROM carn JOIN dcv USING(Vintage)
        WHERE carn.maxscore > dcv.maxscore) AS Carneros;


USE `WINE`;
-- Q6
WITH numwineries AS
    (SELECT Area, COUNT(DISTINCT Winery) AS NumWineries
    FROM wine JOIN appellations USING(Appellation)
    WHERE State = 'California'
        AND Grape = 'Grenache'
    GROUP BY Area),
areas AS
    (SELECT DISTINCT Area
    FROM wine JOIN appellations USING(Appellation)
    WHERE Area NOT IN('N/A', 'California'))
SELECT Area, IFNULL(NumWineries, 0) AS NumWineries
FROM areas LEFT OUTER JOIN numwineries USING(Area)
ORDER BY Area, NumWineries;
