-- Create a Temporary Table to store the data for the three years
With hotels as (
SELECT * FROM dbo.['2018$']
union --union allows all sheets to be combined to one
SELECT * FROM dbo.['2019$']
union
SELECT * FROM dbo.['2020$']
)

/*
--ADR is daily rate for hotel, this is to calculate revenue for weekends/weeknights
SELECT arrival_date_year, hotel, ROUND(SUM((stays_in_week_nights+stays_in_weekend_nights)*adr),0) as Revenue
From hotels
Group By arrival_date_year, hotel
*/

--Discount and Market Segment combined
SELECT * 
FROM hotels
LEFT JOIN dbo.market_segment$
ON hotels.market_segment = market_segment$.market_segment
LEFT JOIN dbo.meal_cost$
ON hotels.meal = meal_cost$.meal
