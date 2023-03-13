-- Lab 7 - KATZENJAMMER
-- Name: Andrew Cheung
-- Email: acheun29@calpoly.edu


USE `KATZENJAMMER`;
-- Q1
SELECT FirstName
FROM Band
WHERE Id NOT IN(SELECT DISTINCT b.Id
                FROM Instruments AS i JOIN Band AS b ON i.Bandmate = b.Id
                WHERE Instrument = 'accordion');


USE `KATZENJAMMER`;
-- Q2
SELECT s.Title
FROM Songs AS s
WHERE s.SongId NOT IN(SELECT v.Song FROM Vocals AS v)
ORDER BY s.Title;


USE `KATZENJAMMER`;
-- Q3
WITH numinstruments AS
    (SELECT s.Title, COUNT(*) AS NumInstruments
    FROM Instruments AS i JOIN Songs AS s ON i.Song = s.SongId
    GROUP BY SongId)
SELECT Title
FROM numinstruments
WHERE NumInstruments = (SELECT MAX(NumInstruments) FROM numinstruments)
ORDER BY Title;


USE `KATZENJAMMER`;
-- Q4
WITH s_per_i AS
    (SELECT b.Id, b.Firstname, b.Lastname, i.Instrument, COUNT(*) AS NumSongs
    FROM Instruments AS i JOIN Band AS b ON i.Bandmate = b.Id
    GROUP BY b.Id, i.Instrument)
SELECT Firstname, Instrument, NumSongs
FROM s_per_i AS s
WHERE NumSongs = (SELECT MAX(NumSongs) FROM s_per_i WHERE s_per_i.Id = s.Id)
ORDER BY Firstname;


USE `KATZENJAMMER`;
-- Q5
WITH anne AS
    (SELECT *
    FROM Instruments AS i JOIN Band AS b ON i.Bandmate = b.Id
    WHERE b.Firstname = 'Anne-Marit'),
not_anne AS
    (SELECT *
    FROM Instruments AS i JOIN Band AS b ON i.Bandmate = b.Id
    WHERE b.Firstname != 'Anne-Marit')
SELECT Instrument
FROM Instruments AS i
WHERE i.Instrument IN(SELECT Instrument FROM anne)
    AND i.Instrument NOT IN(SELECT Instrument FROM not_anne)
ORDER BY i.Instrument;


USE `KATZENJAMMER`;
-- Q6
WITH numInstruments AS
    (SELECT b.Id, b.Firstname, COUNT(DISTINCT i.Instrument) AS NumInstruments
    FROM Instruments AS i JOIN Band AS b ON i.Bandmate = b.Id
    GROUP BY b.Id)
SELECT Firstname
FROM numInstruments
WHERE NumInstruments = (SELECT MAX(NumInstruments) FROM numInstruments);


USE `KATZENJAMMER`;
-- Q7
WITH lead_singers AS
(SELECT t.Position, s.Title, b.Firstname
FROM Tracklists AS t JOIN Songs AS s ON t.Song = s.SongId
    JOIN Albums AS a ON t.Album = a.AId
    JOIN Vocals AS v USING(Song)
    JOIN Band AS b ON v.Bandmate = b.Id
WHERE a.Title = 'Le Pop'
    AND v.VocalType = 'lead')

SELECT s.Title, lead_singers.Firstname
FROM Tracklists AS t JOIN Songs AS s ON t.Song = s.SongId
    JOIN Albums AS a ON t.Album = a.AId
    LEFT OUTER JOIN lead_singers ON s.Title = lead_singers.Title
WHERE a.Title = 'Le Pop'
ORDER BY t.Position, lead_singers.Firstname;


USE `KATZENJAMMER`;
-- Q8
WITH numsongs AS
    (SELECT i.Instrument, COUNT(DISTINCT i.Song) AS NumSongs
    FROM Instruments AS i JOIN Songs AS s ON i.Song = s.SongId
    GROUP BY i.Instrument)
SELECT Instrument
FROM numsongs
WHERE NumSongs = (SELECT MAX(NumSongs) FROM numsongs);
