-- Lab 7 - INN
-- Name: Andrew Cheung
-- Email: acheun29@calpoly.edu


USE `INN`;
-- Q1
WITH numres AS
    (SELECT RoomName, RoomCode, COUNT(*) AS NumReservations
    FROM reservations JOIN rooms ON reservations.Room = rooms.RoomCode
    GROUP BY RoomCode)
SELECT RoomName, RoomCode, NumReservations
FROM numres
GROUP BY RoomCode
HAVING NumReservations = (SELECT MAX(NumReservations) FROM numres);


USE `INN`;
-- Q2
SELECT RoomName, RoomCode, SUM(DATEDIFF(CheckOut, CheckIn)) AS Days
FROM rooms JOIN reservations ON rooms.RoomCode = reservations.Room
GROUP BY RoomCode
HAVING Days =
    (SELECT MAX(Days)
    FROM
        (SELECT RoomName, RoomCode, SUM(DATEDIFF(CheckOut, CheckIn)) AS Days
        FROM rooms JOIN reservations ON rooms.RoomCode = reservations.Room
        WHERE RoomName != 'Stay all year'
        GROUP BY RoomCode)
    AS numdays);


USE `INN`;
-- Q3
WITH maxprice AS
    (SELECT RoomCode, MAX(DATEDIFF(CheckOut, CheckIn) * Rate) AS MaxTotalPrice
    FROM reservations JOIN rooms ON reservations.Room = rooms.RoomCode
    GROUP BY RoomCode)
SELECT RoomName, CheckIn, CheckOut, LastName, Rate, MaxTotalPrice
FROM (maxprice JOIN rooms USING(RoomCode))
    JOIN reservations ON reservations.Room = rooms.RoomCode
WHERE DATEDIFF(CheckOut, CheckIn) * Rate = MaxTotalPrice
ORDER BY MaxTotalPrice DESC;


USE `INN`;
-- Q4
WITH revenue AS
    (SELECT MONTH(CheckIn) AS Month,
        SUM(DATEDIFF(CheckOut, CheckIn) * Rate) AS Revenue
    FROM reservations
    GROUP BY MONTH(CheckIn))
SELECT DATE_FORMAT(CheckIn, '%M'), Revenue, COUNT(*) AS NumReservations
FROM reservations JOIN revenue ON revenue.Month = MONTH(CheckIn)
WHERE Revenue = (SELECT MAX(Revenue) FROM revenue)
GROUP BY Month, DATE_FORMAT(CheckIn, '%M');


USE `INN`;
-- Q5
SELECT DISTINCT RoomName, RoomCode,
    CASE
        WHEN EXISTS(SELECT *
                    FROM reservations AS r
                    WHERE CheckIn <= '2010-08-10'
                        AND CheckOut > '2010-08-10'
                        AND r.Room = RoomCode) THEN 'Occupied'
        ELSE 'Empty'
    END AS Status
FROM reservations JOIN rooms ON reservations.Room = rooms.RoomCode
ORDER BY RoomCode;
