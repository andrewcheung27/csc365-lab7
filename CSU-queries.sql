-- Lab 7 - CSU
-- Name: Andrew Cheung
-- Email: acheun29@calpoly.edu


USE `CSU`;
-- Q1
WITH totaldegs AS
    (SELECT c.Campus, SUM(d.degrees) AS TotalDegrees
    FROM degrees AS d JOIN campuses AS c ON d.CampusId = c.Id
    WHERE d.year >= 1990
        AND d.year <= 2004
    GROUP BY c.Id)
SELECT c.Campus, c.County, SUM(d.degrees) AS TotalDegrees
FROM degrees AS d JOIN campuses AS c ON d.CampusId = c.Id
GROUP BY c.Id
HAVING TotalDegrees = (SELECT MAX(TotalDegrees) FROM totaldegs);


USE `CSU`;
-- Q2
WITH numdegs AS
    (SELECT c.Campus, SUM(d.degrees) AS TotalDegrees
    FROM campuses AS c JOIN degrees AS d ON c.Id = d.CampusId
    WHERE d.year >= 1990
        AND d.year <= 2004
    GROUP BY c.Id)
SELECT MAX(TotalDegrees) / MIN(TotalDegrees) AS Ratio
FROM numdegs;


USE `CSU`;
-- Q3
WITH ratio AS
    (SELECT c.Id, c.Campus, e.Year, e.FTE / f.FTE AS sfRatio
    FROM enrollments AS e JOIN campuses AS c ON e.CampusId = c.Id
        JOIN faculty AS f ON f.CampusId = e.CampusId AND f.Year = e.Year
    GROUP BY c.Id, e.Year)
SELECT Campus, Year, sfRatio
FROM ratio AS r
WHERE sfRatio = (SELECT MIN(sfRatio) FROM ratio WHERE Id = r.Id)
ORDER BY sfRatio;


USE `CSU`;
-- Q4
WITH numcampuses AS
    -- minratios: the minimum s/f ratio per campus
    (WITH minratios AS
        -- ratio: the s/f ratio per campus per year
        (WITH ratio AS
            (SELECT c.Id, c.Campus, e.Year, e.FTE / f.FTE AS sfRatio
            FROM campuses AS c JOIN enrollments AS e ON c.Id = e.CampusId
                JOIN faculty AS f ON f.CampusId = e.CampusId AND f.Year = e.Year
            GROUP BY c.Id, e.Year)
        SELECT *
        FROM ratio AS r
        WHERE r.sfRatio = (SELECT MIN(sfRatio) FROM ratio WHERE Id = r.Id))
    SELECT Year, COUNT(*) AS NumCampuses
    FROM minratios
    GROUP BY Year)
SELECT Year,
    NumCampuses / (SELECT SUM(NumCampuses) FROM numcampuses) * 100 AS Percent
FROM numcampuses
GROUP BY Year, NumCampuses
HAVING NumCampuses = (SELECT MAX(NumCampuses) FROM numcampuses);


USE `CSU`;
-- Q5
WITH fte AS
    (SELECT c.Id, c.Campus, f.Year, f.FTE
    FROM campuses AS c JOIN faculty AS f ON c.Id = f.CampusId
    WHERE f.Year >= 2002
        AND f.Year <= 2004),

badcampuses AS
    (SELECT c.Id
    FROM disciplines AS d JOIN discEnr ON d.Id = discEnr.Discipline
        JOIN campuses AS c ON c.Id = discEnr.CampusId
    WHERE discEnr.Year = 2004
        AND d.Name = 'Engineering')

SELECT Campus, AVG(FTE) AS avgFTE
FROM fte AS f
WHERE Id NOT IN(SELECT Id FROM badcampuses)
GROUP BY Id
ORDER BY avgFTE DESC;


USE `CSU`;
-- Q6
SELECT c.Campus,
    CASE
        WHEN c.Year <= 1955 THEN 'existed'
        ELSE 'did not exist'
    END AS Status
FROM campuses AS c
ORDER BY c.Campus;
