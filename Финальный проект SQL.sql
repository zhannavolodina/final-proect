CREATE DATABASE customers_transactions;

UPDATE customersl SET Gender = NULL WHERE Gender ='';
UPDATE customersl SET Age = NULL WHERE Age ='';
ALTER TABLE customersl MODIFY Age INT NULL;

SELECT * FROM customersl;
SELECT * FROM Transactions;

CREATE TABLE Transactions
(date_new DATE,
Id_check INT,
ID_client INT,
Count_products DECIMAL(10,3),
Sum_payment DECIMAL(10,2));

load data infile 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TRANSACTIONS.csv'
into table Transactions
fields terminated by ','
lines terminated by '\n'
ignore 1 rows;

show variables like 'secure-file-priv';

DATE_FORMAT (date_new, '%Y-%m');

SELECT
    ID_client
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) = 12;

SELECT
    t.ID_client,
    COUNT(t.Id_check) AS total_operations,
    AVG(t.Sum_payment) AS avg_check,
    SUM(t.Sum_payment) / 12 AS avg_monthly_amount
FROM transactions t
JOIN (
    SELECT
        ID_client
    FROM transactions
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY ID_client
    HAVING COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) = 12
) active_clients
    ON t.ID_client = active_clients.ID_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY t.ID_client;


SELECT
    COUNT(*) AS total_operations_year,
    SUM(Sum_payment) AS total_amount_year
FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01';

SELECT
    DATE_FORMAT(date_new, '%Y-%m') AS month,

    AVG(Sum_payment) AS avg_check_month,

    COUNT(Id_check) AS total_operations_month,

    COUNT(DISTINCT ID_client) AS active_clients_month,

    COUNT(Id_check) /
        (SELECT COUNT(*)
         FROM transactions
         WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS share_operations_year,

    SUM(Sum_payment) /
        (SELECT SUM(Sum_payment)
         FROM transactions
         WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01') AS share_amount_year

FROM transactions
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY DATE_FORMAT(date_new, '%Y-%m')
ORDER BY month;


SELECT
    a.quarter,
    a.age_group,

    COUNT(a.Id_check) AS total_operations,

    SUM(a.Sum_payment) AS total_amount,

    AVG(a.Sum_payment) AS avg_check,

    COUNT(a.Id_check) / COUNT(DISTINCT a.ID_client) AS avg_operations_per_client,

    COUNT(a.Id_check) / q.total_operations_q AS pct_operations,

    SUM(a.Sum_payment) / q.total_amount_q AS pct_amount

FROM (
    SELECT
        t.Id_check,
        t.ID_client,
        t.Sum_payment,
        CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter,
        CASE
            WHEN c.Age IS NULL THEN 'NA'
            WHEN c.Age < 10 THEN '0-9'
            WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
            WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
            WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
            WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
            WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
            ELSE '60+'
        END AS age_group
    FROM transactions t
    JOIN customersl c
        ON t.ID_client = c.Id_client
    WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
) a
JOIN (
    SELECT
        quarter,
        COUNT(Id_check) AS total_operations_q,
        SUM(Sum_payment) AS total_amount_q
    FROM (
        SELECT
            Id_check,
            Sum_payment,
            CONCAT(YEAR(date_new), '-Q', QUARTER(date_new)) AS quarter
        FROM transactions
        WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    ) t
    GROUP BY quarter
) q
    ON a.quarter = q.quarter

GROUP BY a.quarter, a.age_group
ORDER BY a.quarter, a.age_group;



















