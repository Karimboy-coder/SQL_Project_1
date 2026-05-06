-- ══════════════════════════════════════════════════════════════
--  Database: SQL
--  Author: Karimboy
--  Description: COUNTRIES ANALYTICS PROJECT
-- ══════════════════════════════════════════════════════════════

-- ============================================
-- CREATE TABLE
-- ============================================

CREATE TABLE countries (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    region VARCHAR(100),
    population BIGINT,
    area_km2 FLOAT,
    gdp_billion FLOAT,
    unemployment_rate FLOAT,
    inflation_rate FLOAT,
    safety_index FLOAT,
    education_index FLOAT,
    pollution_index FLOAT
);

-- ============================================
-- SAMPLE DATA
-- ============================================

INSERT INTO countries 
(id,name, region, population, area_km2, gdp_billion, unemployment_rate, inflation_rate, safety_index, education_index, pollution_index)
VALUES
(1,'USA','North America',331000000,9834000,25400,3.5,6.5,70,0.90,60),
(2,'Germany','Europe',83000000,357000,4200,3.0,5.0,80,0.92,40),
(3,'Uzbekistan','Asia',36000000,448978,80,9.0,10.5,60,0.75,55),
(4,'Japan','Asia',125000000,377975,5000,2.5,3.0,85,0.95,35),
(6,'India','Asia',1400000000,3287000,3400,7.5,6.8,50,0.70,75),
(7,'Canada','North America',38000000,9985000,2200,5.0,4.0,82,0.93,30),
(8,'Brazil','South America',213000000,8516000,1800,8.5,7.5,55,0.72,70),
(9,'France','Europe',67000000,551695,3000,4.5,5.5,78,0.91,45),
(10,'China','Asia',1410000000,9597000,18000,5.2,2.5,65,0.85,80),
(11,'Australia','Oceania',26000000,7692000,1700,4.0,3.5,83,0.94,25);

-- ============================================
-- 1. GDP per capita calculation
-- ============================================

SELECT name,
(gdp_billion * 1000000000) / population AS gdp_per_capita
FROM countries;

-- ============================================
-- 2. Most developed countries (composite score)
-- ============================================

SELECT name,
(safety_index + education_index*100 - pollution_index) AS score
FROM countries
ORDER BY score DESC;

-- ============================================
-- 3. Global GDP ranking
-- ============================================

SELECT name,
RANK() OVER (ORDER BY gdp_billion DESC) AS rnk
FROM countries;

-- ============================================
-- 4. Top 2 countries per region
-- ============================================

SELECT * FROM (
    SELECT name, region, gdp_billion,
    RANK() OVER (PARTITION BY region ORDER BY gdp_billion DESC) AS rnk
    FROM countries
) t
WHERE rnk <= 2;

-- ============================================
-- 5. Average GDP per region comparison
-- ============================================

SELECT name, region, gdp_billion
FROM countries c1
WHERE gdp_billion > (
    SELECT AVG(gdp_billion)
    FROM countries c2
    WHERE c1.region = c2.region
);

-- ============================================
-- 6. Population density ranking
-- ============================================

SELECT name,
(population / area_km2) AS density
FROM countries
ORDER BY density DESC;

-- ============================================
-- 7. Outlier GDP detection
-- ============================================
SELECT c.name, c.gdp_billion
FROM countries c
JOIN (
    SELECT AVG(gdp_billion) AS avg_gdp
    FROM countries
) s
ON 1=1
WHERE c.gdp_billion > s.avg_gdp * 2;
-- ============================================
-- 8. Best balanced country
-- ============================================

SELECT TOP 1
name,
(safety_index + education_index*100 - pollution_index - unemployment_rate*10) AS balance
FROM countries
ORDER BY balance DESC;

-- ============================================
-- 9. Cumulative GDP share (Pareto idea)
-- ============================================

SELECT name, gdp_billion,
SUM(gdp_billion) OVER (ORDER BY gdp_billion DESC) /
SUM(gdp_billion) OVER () AS cumulative_share
FROM countries;


-- ============================================
-- 10. Lowest unemployment countries
-- ============================================

SELECT TOP 3 name, unemployment_rate
FROM countries
ORDER BY unemployment_rate ASC;

-- ============================================
-- 11. Efficiency (GDP per population)
-- ============================================

SELECT name,
gdp_billion / population AS efficiency
FROM countries
ORDER BY efficiency DESC;


-- ============================================
-- 12. Category classification
-- ============================================

SELECT name,
CASE
    WHEN gdp_billion > 10000 THEN 'SUPER ECONOMY'
    WHEN gdp_billion > 3000 THEN 'STRONG ECONOMY'
    ELSE 'DEVELOPING'
END AS category
FROM countries;


-- ============================================
-- 13. Most unstable country
-- ============================================

SELECT TOP 1
name,
(inflation_rate + unemployment_rate) AS instability
FROM countries
ORDER BY instability DESC;


-- ============================================
-- 14. Moving GDP average simulation
-- ============================================

SELECT name, gdp_billion,
AVG(gdp_billion) OVER (
    ORDER BY gdp_billion
    ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
) AS moving_avg
FROM countries;


-- ============================================
-- 15. FINAL COMPOSITE RANKING MODEL
-- ============================================

SELECT name,
(
    gdp_billion * 0.3 +
    safety_index * 0.2 +
    education_index * 100 * 0.2 +
    (100 - pollution_index) * 0.2 +
    (100 - unemployment_rate * 10) * 0.1
) AS final_score
FROM countries
ORDER BY final_score DESC;


-- ============================================
-- END OF PROJECT
-- ============================================