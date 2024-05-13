CREATE TABLE bookings (
    booking_id INT,
    booking_date DATE,
    hotel VARCHAR(50),
    is_canceled INT,
    adults INT,
    children INT,
    meal VARCHAR(25),
    country VARCHAR(23),
    market_segment VARCHAR(20),
    deposit_type VARCHAR(20),
    agent INT,
    price FLOAT,
    required_car_parking_spaces INT,
    reservation_status VARCHAR(25),
    name VARCHAR(50),
    email VARCHAR(50),
	stays_in_weekend_nights INT
);
select * from bookings;

-- 1. What is the overall cancellation rate for hotel bookings?

SELECT ROUND(
			(SELECT SUM(IS_CANCELED)
				FROM BOOKINGS
				WHERE IS_CANCELED = 1) / 
				COUNT(DISTINCT BOOKING_ID)::numeric,2) * 100 AS CANCELLATION_RATE
FROM BOOKINGS

-- 2. Which countries are the top contributors to hotel bookings?

SELECT COUNTRY,
	ROUND(SUM(PRICE)::numeric,
		2)
FROM BOOKINGS
WHERE IS_CANCELED = 0
GROUP BY 1
ORDER BY 2 DESC;

-- 3. What are the main market segments booking the hotels, such as leisure or corporate?

SELECT MARKET_SEGMENT,
	COUNT(BOOKING_ID)
FROM BOOKINGS
GROUP BY 1
ORDER BY 2 DESC;

-- 4. Is there a relationship between deposit type (e.g., non-refundable, refundable) and the likelihood of cancellation?

select distinct deposit_type from bookings;

WITH DEPOSIT_TYPE_NOCANCEL AS
	(SELECT DEPOSIT_TYPE,
			COUNT(IS_CANCELED) AS DIDNOT_CANCEL
		FROM BOOKINGS
		WHERE IS_CANCELED = 0
		GROUP BY 1),
	DEPOSIT_TYPE_CANCELED AS
	(SELECT DEPOSIT_TYPE,
			COUNT(IS_CANCELED) AS CANCELED
		FROM BOOKINGS
		WHERE IS_CANCELED = 1
		GROUP BY 1)
SELECT DTC.DEPOSIT_TYPE,
	DTNC.DIDNOT_CANCEL,
	DTC.CANCELED
FROM DEPOSIT_TYPE_NOCANCEL AS DTNC
JOIN DEPOSIT_TYPE_CANCELED AS DTC ON DTC.DEPOSIT_TYPE = DTNC.DEPOSIT_TYPE;

-- 5. How long do guests typically stay in hotels on average?
SELECT AVG(STAYS_IN_WEEKEND_NIGHTS) AS AVERAGE_STAY
FROM BOOKINGS;

-- 6. What meal options (e.g., breakfast included, half-board) are most preferred by guests?

SELECT CASE
											WHEN MEAL = 'FB' THEN 'Full Board'
											WHEN MEAL = 'BB' THEN 'Bed and Breakfast'
											WHEN MEAL = 'HB' THEN 'Half Board'
											WHEN MEAL = 'SC' THEN 'Self Catering'
											ELSE 'Undefined'
							END AS MEAL_CATEGORY,
	COUNT(BOOKING_ID) AS TOTAL_CUSTOMERS
FROM BOOKINGS
GROUP BY 1
ORDER BY 2 DESC;

-- 7. Do bookings made through agents exhibit different cancellation rates or booking durations compared to direct bookings?

-- need to find avg cancel rate and avg weekend_nights with agents_id
-- compare it with direct bookings
select * from bookings;

SELECT CASE
	WHEN AGENT IS NULL THEN 'Direct booking'
	ELSE 'Agent booking'
	END AS BOOKING_TYPE,
	ROUND(AVG(IS_CANCELED)::numeric,
		2) * 100 AS AVG_CANCELATION_RATE,
	ROUND(AVG(STAYS_IN_WEEKEND_NIGHTS)::numeric,
		2) AS AVG_STAYS
FROM BOOKINGS
GROUP BY 1

-- 8. How do prices vary across different hotels and room types? Are there any seasonal pricing trends?

select price, hotel, from bookings;

select CASE
	WHEN EXTRACT(MONTH FROM BOOKING_DATE) >= 2 AND EXTRACT(MONTH FROM BOOKING_DATE) <= 5 THEN 'Summer'
	WHEN EXTRACT(MONTH FROM BOOKING_DATE) >= 6 AND EXTRACT(MONTH FROM BOOKING_DATE) <= 9 THEN 'Monsoon' 
	ELSE 'Winter' END AS SEASON,
	
	hotel, round(sum(price)::numeric,2 )as PRICE
from bookings
group by 1,2
order by 2


-- 9. What percentage of bookings require car parking spaces, and does this vary by hotel location or other factors?
 

SELECT HOTEL,
	COUNT(*) AS TOTAL_BOOKINGS,
	SUM(REQUIRED_CAR_PARKING_SPACES) AS TOTAL_BOOKINGS_WITH_PARKING,
	ROUND((SUM(REQUIRED_CAR_PARKING_SPACES) * 100.0 / COUNT(*))::NUMERIC,
		2) AS PERCENTAGE_BOOKINGS_WITH_PARKING
FROM BOOKINGS
GROUP BY HOTEL;

 
 -- 10. What are the main reservation statuses (e.g., confirmed, canceled, checked-in),and how do they change over time?
 select * from bookings;

SELECT EXTRACT(MONTH
					FROM BOOKING_DATE) AS MONTH,
	RESERVATION_STATUS,
	COUNT(2) AS STATUS_COUNT
FROM BOOKINGS
GROUP BY 1,2
ORDER BY 1;
	
-- 11.What is the distribution of guests based on the number of adults, children, and stays on weekend nights?

select * from bookings;

SELECT STAYS_IN_WEEKEND_NIGHTS,
	SUM(ADULTS) TOTAL_ADULTS,
	SUM(CHILDREN) TOTAL_CHILDREN
FROM BOOKINGS
GROUP BY 1
ORDER BY 1


-- 12.Which email domains are most commonly used for making hotel bookings?

SELECT 
    SUBSTRING(email FROM POSITION('@' IN email) + 1) AS email_domain,
    COUNT(*) AS domain_count
FROM 
    bookings
GROUP BY 
    email_domain
ORDER BY 
    domain_count DESC;
	
-- 13.Are there any frequently occurring names in hotel bookings, and do they exhibit any specific booking patterns?
select * from bookings;

WITH NAME_FREQUENCY AS
	(SELECT NAME,
			COUNT(1) AS OCCUR_FREQUENCY
		FROM BOOKINGS
		GROUP BY 1
		ORDER BY 2 DESC
		LIMIT 10)
SELECT B.NAME,
	F.OCCUR_FREQUENCY,
	ROUND(AVG(B.STAYS_IN_WEEKEND_NIGHTS)::NUMERIC,2) AS  Avg_stay_weekends,
	ROUND(AVG(B.PRICE)::NUMERIC, 2) AS Avg_Price,
	ROUND(AVG(B.IS_CANCELED)::NUMERIC,2) AS Avg_Cancellation_Rate
FROM BOOKINGS B
JOIN NAME_FREQUENCY F ON B.NAME = F.NAME
GROUP BY 1,2
ORDER BY 2 DESC

	
 
-- 14.Which market segments contribute the most revenue to the hotels?

SELECT MARKET_SEGMENT,
	SUM(PRICE) AS PRICE
FROM BOOKINGS
GROUP BY MARKET_SEGMENT
ORDER BY PRICE DESC;
 
-- 15.How do booking patterns vary across different seasons or months of the year?

SELECT CASE
	WHEN EXTRACT(MONTH FROM BOOKING_DATE) >= 2 AND EXTRACT(MONTH FROM BOOKING_DATE) <= 5 THEN 'Summer'
	WHEN EXTRACT(MONTH FROM BOOKING_DATE) >= 6 AND EXTRACT(MONTH FROM BOOKING_DATE) <= 9 THEN 'Monsoon' 
	ELSE 'Winter' END AS SEASON,
	COUNT(BOOKING_ID) AS TOTAL_BOOKINGS
FROM BOOKINGS
GROUP BY 1
ORDER BY 2 DESC
	

