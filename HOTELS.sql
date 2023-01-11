with hotels AS (
SELECT * FROM hotel_revenue_2018
UNION
SELECT * FROM hotel_revenue_2019
UNION
SELECT * FROM hotel_revenue_2020)

SELECT * FROM HOTELS
LEFT JOIN hotel_revenue_market_segment
	ON hotels.market_segment= hotel_revenue_market_segment.market_segment
LEFT JOIN hotel_revenue_meal_cost
	ON hotel_revenue_meal_cost.meal=hotels.meal