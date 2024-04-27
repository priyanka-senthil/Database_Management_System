use bbjewels;
#1) Counting the no.of employees in Stock Handline Team (Simple query)
SELECT 'Stock Handling Team' AS Department, 
COUNT(*) AS Num_Employees
FROM STOCK_HANDLING_TEAM;

#2) Total Quantity Supplied by each Supplier (Aggregate Query)
SELECT s.Sup_Name, SUM(s.Quantity_Supplied) AS Total_Quantity_Supplied
FROM SUPPLIER s
GROUP BY s.Sup_Name
ORDER BY Total_Quantity_Supplied DESC;

#3) Finding the Top 5 Suppliers by Average Quality Rating (Using Inner Join)
SELECT Sup_Name, AVG(Quality_Rating) AS Avg_Quality_Rating
FROM QUALITY_CHECK_RECORDER q
join supplier s on q.Record_Number = s.Record_Number
GROUP BY Sup_Name, Date
order by Avg_Quality_Rating desc limit 5;

#4) Finding the customer from Virginia, Vermont and Kentucky 
#who received the damaged product (Nested query)
SELECT cust_id
FROM damages 
WHERE vendor_nr IN
(SELECT vendor_nr
FROM repairer
WHERE address LIKE '%virginia%'
OR address LIKE '%verm%'
OR address LIKE '%kentu%');

#5)Find the five highest priced purchases together with their Pur_IDs, Material_Name and Material Quantity (Correlated query)
SELECT PH1.Pur_ID Purchase_ID, s.Sup_name Supplier_Name, v.Material_Name, PH1.Total_Price
FROM purchase_history PH1
join supplier s on s.Pur_ID = ph1.pur_id
join quality_check_recorder q on q.Record_Number= s.Record_Number
join vault v on v.record_number= q.Record_Number
WHERE 5 > 
	(SELECT count(*)
    FROM purchase_history PH2
    WHERE PH1.Total_Price < PH2.Total_Price); 

#6) This query retrives the pur_id and supplier_name 
#where the supplies quantity is greater than 70 (>=ALL/>ANY/Exists/Not Exists)
SELECT p.Pur_ID, s.sup_name, s.Quantity_Supplied
FROM purchase_history p
JOIN supplier s ON p.Pur_ID = s.Pur_ID
WHERE EXISTS 
(SELECT 1
FROM supplier s2
WHERE s2.Pur_ID = p.Pur_ID
AND s2.Quantity_Supplied > 70)
order by quantity_supplied desc;

#7) This query returns the suppliers from New England who has sold > $5000 (Set operations (Union))
SELECT Sup_ID, Sup_Name
FROM Supplier
WHERE Sup_Address LIKE '%Rhode%'
OR Sup_Address LIKE '%Connect%'
OR Sup_Address LIKE '%Massac%'
OR Sup_Address LIKE '%Maine%'
OR Sup_Address LIKE '%New Ham%'
OR Sup_Address LIKE '%Vermont%'
UNION
SELECT S.Sup_ID, S.Sup_Name
FROM Supplier S, purchase_history PH
WHERE S.Pur_ID = PH.Pur_ID
AND PH.Total_Price > 5000
ORDER BY Sup_Name ASC;

#8) This query selects the quality_checked_date along with the suppliers information who has supplied materials 
#from August 1st untill the end of the year  (Subqueries in Select)
SELECT s.Sup_Name, s.Sup_Type, v.Material_Name,v.Material_Quantity,
    (SELECT q.Date 
     FROM quality_check_recorder q 
     WHERE q.Record_Number = s.Record_Number) AS Quality_Check_Date
FROM supplier s
INNER JOIN vault v ON s.Record_Number = v.record_number
WHERE (SELECT q.Date 
       FROM quality_check_recorder q 
       WHERE q.Record_Number = s.Record_Number) > '2023-08-01' And
       Material_Quantity > 5;

#9) This query selects the suppliers who are retailers and who have supplied materials more than 5 (Subqueries in From)
SELECT Sup_ID, Sup_name, v.Material_Name, v.Material_Quantity
FROM (
    SELECT *
    FROM supplier
    WHERE Sup_Type = 'Retailer'
) AS s
INNER JOIN quality_check_recorder q ON s.Record_Number = q.Record_Number
INNER JOIN vault v ON s.Record_Number = v.record_number
where Material_Quantity > 5;


#This query is to find the total number of quantity supplied by suppliers for each month in the year 2023

WITH Monthly_Supply AS (
    SELECT 
        YEAR(q.Date) AS Year,
        MONTHNAME(q.Date) AS Month_Name,
        SUM(s.Quantity_Supplied) AS Total_Quantity_Supplied
    FROM 
        supplier s
    INNER JOIN 
        quality_check_recorder q ON s.Record_Number = q.Record_Number
    GROUP BY 
        YEAR(q.Date), MONTHNAME(q.Date)
)
SELECT 
    Year, 
    Month_Name, 
    Total_Quantity_Supplied
FROM 
    Monthly_Supply
ORDER BY 
    Total_Quantity_Supplied DESC
;