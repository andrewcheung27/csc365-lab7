-- Lab 7 - BAKERY
-- Name: Andrew Cheung
-- Email: acheun29@calpoly.edu


USE `BAKERY`;
-- Q1
WITH money_spent AS
    (SELECT c.CId, c.FirstName, c.LastName, SUM(g.PRICE) AS TotalSpent
    FROM ((items AS i JOIN receipts AS r ON i.Receipt = r.RNumber)
        JOIN goods AS g ON i.Item = g.GId)
        JOIN customers AS c ON c.CId = r.Customer
    WHERE MONTH(r.SaleDate) = 10 AND YEAR(r.SaleDate) = 2007
    GROUP BY c.CId)
SELECT FirstName, LastName
FROM money_spent
WHERE TotalSpent = (SELECT MAX(TotalSpent) FROM money_spent);


USE `BAKERY`;
-- Q2
WITH eclair_fiends AS
    (SELECT *
    FROM ((items AS i JOIN receipts AS r ON i.Receipt = r.RNumber)
        JOIN goods AS g ON i.Item = g.GId)
        JOIN customers AS c ON c.CId = r.Customer
    WHERE MONTH(r.SaleDate) = 10 AND YEAR(r.SaleDate) = 2007
        AND g.Food = 'Eclair')
SELECT FirstName, LastName
FROM customers
WHERE customers.CId NOT IN(SELECT CId FROM eclair_fiends)
ORDER BY LastName;


USE `BAKERY`;
-- Q3
WITH cakes AS
    (SELECT c.CId, c.FirstName, c.LastName, COUNT(*) AS NumCakes
    FROM ((items AS i JOIN receipts AS r ON i.Receipt = r.RNumber)
        JOIN goods AS g ON i.Item = g.GId)
        JOIN customers AS c ON c.CId = r.Customer
    WHERE MONTH(r.SaleDate) = 10 AND YEAR(r.SaleDate) = 2007
        AND g.Food = 'Cake'
    GROUP BY c.CId),
cookies AS
    (SELECT c.CId, c.FirstName, c.LastName, COUNT(*) AS NumCookies
    FROM ((items AS i JOIN receipts AS r ON i.Receipt = r.RNumber)
        JOIN goods AS g ON i.Item = g.GId)
        JOIN customers AS c ON c.CId = r.Customer
    WHERE MONTH(r.SaleDate) = 10 AND YEAR(r.SaleDate) = 2007
        AND g.Food = 'Cookie'
    GROUP BY c.CId)
SELECT FirstName, LastName
FROM cakes JOIN cookies USING(CId, FirstName, LastName)
WHERE NumCakes > NumCookies
ORDER BY LastName;


USE `BAKERY`;
-- Q4
WITH goods_sold AS
    (SELECT g.Food, g.Flavor, COUNT(*) AS NumSold
    FROM items AS i JOIN goods AS g ON i.Item = g.GId
    GROUP BY g.GId)
SELECT Flavor, Food, NumSold
FROM goods_sold
WHERE NumSold = (SELECT MAX(NumSold) FROM goods_sold);


USE `BAKERY`;
-- Q5
WITH daily_revenue AS
    (SELECT r.SaleDate, SUM(g.PRICE) AS Revenue
    FROM (items AS i JOIN goods AS g ON i.Item = g.GId)
        JOIN receipts AS r ON r.RNumber = i.Receipt
    WHERE MONTH(r.SaleDate) = 10 AND YEAR(r.SaleDate) = 2007
    GROUP BY r.SaleDate)
SELECT SaleDate
FROM daily_revenue
WHERE Revenue = (SELECT MAX(Revenue) FROM daily_revenue);


USE `BAKERY`;
-- Q6
WITH magic_date AS
    (WITH daily_revenue AS
        (SELECT r.SaleDate, SUM(g.PRICE) AS Revenue
        FROM (items AS i JOIN receipts AS r ON i.Receipt = r.RNumber)
            JOIN goods AS g ON i.Item = g.GId
        WHERE MONTH(r.SaleDate) = 10 AND YEAR(r.SaleDate) = 2007
        GROUP BY r.SaleDate)
    SELECT SaleDate
    FROM daily_revenue
    WHERE Revenue = (SELECT MAX(Revenue) FROM daily_revenue)),
items_sold AS
    (SELECT r.SaleDate, g.Food, g.Flavor, COUNT(*) AS ItemsSold
    FROM (items AS i JOIN receipts AS r ON i.Receipt = r.RNumber)
        JOIN goods AS g ON g.GId = i.Item
    WHERE r.SaleDate IN (SELECT SaleDate FROM magic_date)
    GROUP BY r.SaleDate, g.GId)
SELECT Food, Flavor, ItemsSold
FROM items_sold
WHERE ItemsSold = (SELECT MAX(ItemsSold) FROM items_sold);


USE `BAKERY`;
-- Q7
WITH customer_cakes AS
    (SELECT c.CId, c.FirstName, c.LastName, g.Food, g.Flavor, COUNT(*) AS NumPurchases
    FROM ((items AS i JOIN receipts AS r ON r.RNumber = i.Receipt)
        JOIN goods AS g ON i.Item = g.GId)
        JOIN customers AS c ON c.CId = r.Customer
    WHERE MONTH(r.SaleDate) = 10 AND YEAR(r.SaleDate) = 2007
        AND g.Food = 'Cake'
    GROUP BY c.CId, g.Flavor)
SELECT Flavor, Food, FirstName, LastName, NumPurchases
FROM customer_cakes AS cc
WHERE NumPurchases = (SELECT MAX(NumPurchases) FROM customer_cakes WHERE customer_cakes.Flavor = cc.Flavor)
ORDER BY NumPurchases DESC, Flavor, LastName;


USE `BAKERY`;
-- Q8
WITH made_purchase AS
    (SELECT *
    FROM (items AS i JOIN receipts AS r ON i.Receipt = r.RNumber)
        JOIN customers AS c ON r.Customer = c.CId
    WHERE r.SaleDate >= '2007-10-19'
        AND r.SaleDate <= '2007-10-23')
SELECT FirstName, LastName
FROM customers
WHERE CId NOT IN(SELECT CId FROM made_purchase)
ORDER BY LastName;


USE `BAKERY`;
-- Q9
WITH eclairs AS
    (SELECT c.CId, c.FirstName, c.LastName, COUNT(*) AS NumEclairs
    FROM ((items AS i JOIN goods AS g ON i.Item = g.GId)
        JOIN receipts AS r ON i.Receipt = r.RNumber)
        JOIN customers AS c ON c.CId = r.Customer
    WHERE g.Food = 'Eclair'
    GROUP BY c.CId),
danishes AS
    (SELECT c.CId, c.FirstName, c.LastName, COUNT(*) AS NumDanishes
    FROM ((items AS i JOIN goods AS g ON i.Item = g.GId)
        JOIN receipts AS r ON i.Receipt = r.RNumber)
        JOIN customers AS c ON c.CId = r.Customer
    WHERE g.Food = 'Danish'
    GROUP BY c.CId),
pies AS
    (SELECT c.CId, c.FirstName, c.LastName, COUNT(*) AS NumPies
    FROM ((items AS i JOIN goods AS g ON i.Item = g.GId)
        JOIN receipts AS r ON i.Receipt = r.RNumber)
        JOIN customers AS c ON c.CId = r.Customer
    WHERE g.Food = 'Pie'
    GROUP BY c.CId)
SELECT FirstName, LastName, NumEclairs, NumDanishes, NumPies
FROM ((customers LEFT JOIN eclairs USING(CId, FirstName, LastName))
    LEFT JOIN danishes USING(CId, FirstName, LastName))
    LEFT JOIN pies USING(CId, FirstName, LastName)
ORDER BY LastName;


USE `BAKERY`;
-- Q10
WITH choc AS
    (SELECT SUM(g.PRICE) AS ChocSales
    FROM (items AS i JOIN goods AS g ON i.Item = g.GId)
        JOIN receipts AS r ON i.Receipt = r.RNumber
    WHERE MONTH(r.SaleDate) = 10 AND YEAR(r.SaleDate) = 2007
        AND g.Flavor = 'Chocolate'),
crois AS
    (SELECT SUM(g.PRICE) AS CrossSales
    FROM (items AS i JOIN goods AS g ON i.Item = g.GId)
        JOIN receipts AS r ON i.Receipt = r.RNumber
    WHERE MONTH(r.SaleDAte) = 10 AND YEAR(r.SaleDate) = 2007
        AND g.Food = 'Croissant')
SELECT CASE
    WHEN (SELECT * FROM choc) > (SELECT * FROM crois) THEN 'Chocolate'
    WHEN (SELECT * FROM crois) > (SELECT * FROM choc) THEN 'Croissant'
    ELSE 'Tie'
    END AS HigherRevenue;
