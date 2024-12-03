
-- The objective is to calculate the total number of passengers for each pair of origin and destination airports.
use airport_db;
select* from airport_db;
select 
origin_airport,destination_airport,
sum(passengers) as total_passengers 
from airport_db
group by origin_airport,Destination_airport
order by Origin_airport , Destination_airport;

-- Here the goal is to calculate the average seat utilization for each flight by dividing the  number of passengers by the total number of seats available
select 
origin_airport,destination_airport,
avg(round(passengers ,2 )/ nullif(seats,0))*100 as average_seats_utilisation

from airport_db
group by origin_airport,Destination_airport
order by average_seats_utilisation desc;

-- The aim is to determine the top 5 origin and destination airport pairs that have the highest total passenger volume.
select 
origin_airport,destination_airport,
sum(passengers) as total_passengers 

from airport_db
group by origin_airport,Destination_airport
order by total_passengers desc 
limit 5;

 -- The objective is to calculate the total number of flights and passengers departing from each origin city. 
select 
origin_city,
count(flights ) as total_number_flights,
sum(passengers) total_passengers 
from airport_db
group by origin_city
order by Origin_city desc ;

-- The objective is to group flights by month and year using the Fly_date column to calculate the number of flights,
-- total passengers, and average distance traveled per month. 
select 
year(fly_date) as year ,
month(fly_date) as month ,
sum(passengers) as total_passengers,
avg(distance) as average_distance ,
count(flights) as total_number_flights
from airport_db
group by year(fly_date),month(fly_date);

-- The goal is to calculate the passenger-to-seats ratio for each origin and destination route
-- and filter the results to display only those routes where this ratio is less than 0.5. 

WITH total_summary AS (
    SELECT
        origin_airport,
        destination_airport,
        SUM(passengers) AS total_passengers,
        SUM(seats) AS total_seats
    FROM 
        airport_db
    GROUP BY 
        origin_airport, destination_airport
)
SELECT 
    origin_airport,
    destination_airport, 
    total_passengers,
    total_seats,
    total_passengers * 1.0 / NULLIF(total_seats, 0) AS total_passenger_seat_ratio
FROM 
    total_summary
WHERE 
    total_passengers * 1.0 / NULLIF(total_seats, 0) < 0.5
ORDER BY 
    total_passenger_seat_ratio DESC;
    
    
SELECT 
    Origin_airport, 
    Destination_airport, 
    SUM(Passengers) AS Total_Passengers, 
    SUM(Seats) AS Total_Seats, 
    (SUM(Passengers) * 1.0 / NULLIF(SUM(Seats), 0)) AS Passenger_to_Seats_Ratio
FROM 
    airports2
GROUP BY 
    Origin_airport, 
    Destination_airport
HAVING 
    (SUM(Passengers) * 1.0 / NULLIF(SUM(Seats), 0)) < 0.5
ORDER BY 
    Passenger_to_Seats_Ratio;



-- The aim is to determine the top 3 origin airports with the highest frequency of flights.
	SELECT 
    Origin_airport, 
    COUNT(Flights) AS Total_Flights
FROM 
    airports2
GROUP BY 
    Origin_airport
ORDER BY 
    Total_Flights DESC
LIMIT 3;


-- - The aim is to determine the top 3 origin airports with the highest frequency of flights. 
select origin_airport ,
count(flights) as total_number_flights 
from airport_db
group by origin_airport 
order by total_number_flights desc 
limit 3;



----- The objective is to identify the cities (excluding Bend, OR) that sends the most flights and passengers to Bend, OR. 

select
Origin_city,Destination_city,sum(passengers) as total_passengers ,count(flights) as total_flights
 from airport_db
     where Destination_city = 'Bend, OR' AND 
    Origin_city <> 'Bend, OR'
    group by origin_city
    order by total_flights, total_passengers desc;
    
    
    # Problem Statement 10 : 
-- The aim is to identify the longest flight route in terms of distance traveled, including both the origin and destination airports. 
select origin_airport,destination_airport, max(distance) as longest_distance 
from airport_db
group by origin_airport,destination_airport 
order by longest_distance desc	
limit 1;

-- pb=11 The objective is to determine the most and least busy months by flight count across multiple years. 
 use airport_db;
 with monthly_flights as ( 
 select year(fly_date) as years,
month(fly_date)as months,
count(flights) as total_flights
 from airport_db	
group by months(fly_date)
)
select months,total_flights,
case when total_flights=(select max(total_flights) from monthly_flights ) then 'most busy'
when total_flights=(select min(total_flights) from monthly_flights)then 'least_busy'
else null
end as month_status
from monthly_flights
where total_flights =(select max(total_flights) from monthly_flights)
or total_flights=(select min(total_flights) from monthly_flights);

-- The aim is to calculate the year-over-year percentage growth in the total number of passengers for each origin and destination airport pair.

 with passenger_summary as (
 select origin_airport,destination_airport,sum(passengers) as total_passengers,
year(fly_date) as years
from airport_db
group by origin_airport,destination_airport,year(fly_date)
),
passenger_growth as ( 
select origin_airport,destination_airport,total_passengers,years,
 LAG(Total_Passengers) OVER (PARTITION BY Origin_airport, Destination_airport ORDER BY Years ) as previous_passengers
from passenger_summary
)
select origin_airport ,destination_airport,total_passengers,years, 
case when total_passengers is not null then (total_passengers-previous_passengers)*100 /nullif(previous_Passengers,0)
else null 
end as growth_percentage
from passenger_growth
order by origin_airport,destination_airport,years desc;


-- pb-13 -- The objective is to identify routes (from origin to destination) that have demonstrated consistent year-over-year growth in the number of flights. 
with flight_summary as(
select origin_airport,destination_airport,count(flights) as total_flights,year(fly_date) as years 
from airport_db
group by origin_airport, destination_airport,year(fly_date) 
),
flight_growth as ( select 
 origin_airport,destination_airport,total_flights,years,
 LAG(Total_Flights) OVER (PARTITION BY Origin_airport, Destination_airport ORDER BY Years )Previous_Year_Flights
 from flight_summary
 ),
 growth_rates as (
 select  origin_airport,destination_airport,total_flights,years	,
 case 
 when  Previous_Year_Flights IS NOT NULL AND Previous_Year_Flights > 0 THEN ( total_flights -previous_year_flights) / nullif(previous_year_flights ,0)
 
 else null  
 end as growth_rates,
 CASE 
            WHEN Previous_Year_Flights IS NOT NULL AND Total_Flights > Previous_Year_Flights THEN 1
      ELSE 0 
        END AS Growth_Indicator
 from flight_growth 
 )
 select origin_airport,destination_airport,
 min(growth_rates) as minimum_growth_rates,
 max(growth_rates) as maximum_growth_rates 
 from growth_rates 
 where growth_indicator = 1
 group by origin_airport,destination_airport 
 having min(growth_indicator) =1
 order by origin_airport,destination_airport desc ;

-- pb-4 -- The aim is to determine the top 3 origin airports with the highest weighted passenger-to-seats utilization ratio, 
 -- sidering the total number of flights for weighting.
 
 use airport_db;
 WITH Utilization_Ratio AS (
    -- Step 1: Calculate the passenger-to-seats ratio for each flight
    SELECT 
        Origin_airport, 
        SUM(Passengers) AS Total_Passengers, 
        SUM(Seats) AS Total_Seats, 
        COUNT(Flights) AS Total_Flights,
        SUM(Passengers) * 1.0 / SUM(Seats) AS Passenger_Seat_Ratio
    FROM 
        airport_db
    GROUP BY 
        Origin_airport
),

Weighted_Utilization AS (
    -- Step 2: Calculate the weighted utilization by flights for each origin airport
    SELECT 
        Origin_airport, 
        Total_Passengers, 
        Total_Seats, 
        Total_Flights,
        Passenger_Seat_Ratio, 
        -- Weight the passenger-to-seat ratio by the total number of flights
        (Passenger_Seat_Ratio * Total_Flights) / SUM(Total_Flights) OVER () AS Weighted_Utilization
    FROM 
        Utilization_Ratio
)

-- Step 3: Select the top 3 airports by weighted utilization
SELECT 
    Origin_airport, 
    Total_Passengers, 
    Total_Seats, 
    Total_Flights, 
    Weighted_Utilization
FROM 
    Weighted_Utilization
ORDER BY 
    Weighted_Utilization DESC
LIMIT 3;

--  pb 5  The objective is to identify the peak traffic month for each origin city based on the highest number of passengers, 
-- including any ties where multiple months have the same passenger count. 
use airport_db;
WITH Monthly_Passenger_Count AS (
    SELECT 
        Origin_city,
        YEAR(Fly_date) AS Years,
        MONTH(Fly_date) AS Months,
        SUM(Passengers) AS Total_Passengers  -- Handling NULLs and non-integer values
    FROM 
        airport_db
    GROUP BY 
        Origin_city, 
        YEAR(Fly_date), 
        MONTH(Fly_date)
),

Max_Passengers_Per_City AS (
    SELECT 
        Origin_city, 
        MAX(Total_Passengers) AS Peak_Passengers
    FROM 
        Monthly_Passenger_Count
    GROUP BY 
        Origin_city
)

SELECT 
    mpc.Origin_city, 
    mpc.Years, 
    mpc.Months, 
    mpc.Total_Passengers
FROM 
    Monthly_Passenger_Count mpc
JOIN 
    Max_Passengers_Per_City mp ON mpc.Origin_city = mp.Origin_city 
                               AND mpc.Total_Passengers = mp.Peak_Passengers
ORDER BY 
    mpc.Origin_city, 
    mpc.Years, 
    mpc.Months;
    -- The aim is to identify the routes (origin-destination pairs) that have experienced the largest decline in passenger numbers year-over-year. 
WITH year_passenger_count AS (
    SELECT 
        origin_airport,
        destination_airport,
        SUM(passengers) AS total_passenger,
        YEAR(fly_date) AS years
    FROM airport_db
    GROUP BY origin_airport, destination_airport, YEAR(fly_date)
),
yearly_decline AS (
    SELECT 
        y1.origin_airport,
        y1.destination_airport,
        y1.years AS year1,
        y2.years AS year2,
        y1.total_passenger AS Passengers_Year1,
        y2.total_passenger AS Passengers_Year2,
        ((y2.total_passenger - y1.total_passenger) / NULLIF(y1.total_passenger, 0)) * 100 AS percentage_change
    FROM year_passenger_count y1
    JOIN year_passenger_count y2 
        ON y1.origin_airport = y2.origin_airport 
        AND y1.destination_airport = y2.destination_airport
        AND y2.years = y1.years + 1
)
SELECT 
    origin_airport,
    destination_airport,
    year1,
    year2,
    Passengers_Year1,
    Passengers_Year2,
    percentage_change
FROM yearly_decline
WHERE percentage_change < 0
ORDER BY percentage_change DESC;

-- pb 7 -- The objective is to list all origin and destination airports that had at least 10 flights
-- but maintained an average seat utilization (passengers/seats) of less than 50%.

WITH Flight_Stats AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        COUNT(Flights) AS Total_Flights,
        SUM(Passengers) AS Total_Passengers,
        SUM(Seats) AS Total_Seats,
        -- Calculate average seat utilization as (Total Passengers / Total Seats)
        (SUM(Passengers) / NULLIF(SUM(Seats), 0)) AS Avg_Seat_Utilization
    FROM 
        airport_db
    GROUP BY 
        Origin_airport, Destination_airport
)

SELECT 
    Origin_airport,
    Destination_airport,
    Total_Flights,
    Total_Passengers,
    Total_Seats,
    ROUND(Avg_Seat_Utilization * 100, 2) AS Avg_Seat_Utilization_Percentage
FROM 
    Flight_Stats
WHERE 
    Total_Flights >= 10 -- At least 10 flights
    AND Avg_Seat_Utilization < 0.5 -- Less than 50% seat utilization
ORDER BY 
    Avg_Seat_Utilization_Percentage ASC;
 

 
 
 WITH Distance_Stats AS (
    SELECT 
        Origin_city,
        Destination_city,
        AVG(Distance) AS Avg_Flight_Distance
    FROM 
        airports2
    GROUP BY 
        Origin_city, 
        Destination_city
)

SELECT 
    Origin_city,
    Destination_city,
    ROUND(Avg_Flight_Distance, 2) AS Avg_Flight_Distance
FROM 
    Distance_Stats
ORDER BY 
    Avg_Flight_Distance DESC;  -- Sort by average distance in descending order

-- The objective is to calculate the total number of flights and passengers for each year, 
-- along with the percentage growth in both flights and passengers compared to the previous year. 
with yearly_passenger_summary as(
select year(fly_date) as years,sum(passengers)as total_passenger,count(flights) as total_flight
from airport_db
group by years
),
 yearly_growth as(
select years,total_passenger,total_flight,
lag(total_flight) over(order by years) as previous_passenger,
lag(total_passenger) over(order by years) as previous_flight
from yearly_passenger_summary
)
select years,total_passenger,total_flight,
round((total_passenger-previous_passenger)*100,2) as passeger_growth,
round((total_flight-previous_flight)*100,2) as flight_growth
from yearly_growth
order by years desc;


-- The aim is to identify the top 3 busiest routes (origin-destination pairs) based on the total distance flown,
--  weighted by the number of flights. 

WITH Route_Distance AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        SUM(Distance) AS Total_Distance,
        SUM(Flights) AS Total_Flights
    FROM 
        airport_db
    GROUP BY 
        Origin_airport, 
        Destination_airport
),

Weighted_Routes AS (
    SELECT 
        Origin_airport,
        Destination_airport,
        Total_Distance,
        Total_Flights,
        Total_Distance * Total_Flights AS Weighted_Distance
    FROM 
        Route_Distance
)

SELECT 
    Origin_airport,
    Destination_airport,
    Total_Distance,
    Total_Flights,
    Weighted_Distance
FROM 
    Weighted_Routes
ORDER BY 
    Weighted_Distance DESC
LIMIT 3;  






