CREATE DATABASE ncr_ride_analysis;

USE ncr_ride_analysis;

SELECT DATABASE();
DROP TABLE IF EXISTS ncr_ride_bookings;

USE ncr_ride_analysis;

DROP TABLE IF EXISTS ride_bookings;

CREATE TABLE ride_bookings (
    booking_date DATE,
    booking_time TIME,
    booking_id VARCHAR(30),
    booking_status VARCHAR(50),
    customer_id VARCHAR(30),
    vehicle_type VARCHAR(50),
    pickup_location VARCHAR(100),
    drop_location VARCHAR(100),
    avg_vtat DECIMAL(10,2),
    avg_ctat DECIMAL(10,2),
    cancelled_rides_by_customer INT,
    customer_cancellation_reason VARCHAR(255),
    cancelled_rides_by_driver INT,
    driver_cancellation_reason VARCHAR(255),
    incomplete_rides INT,
    incomplete_rides_reason VARCHAR(255),
    booking_value DECIMAL(10,2),
    ride_distance DECIMAL(10,2),
    driver_ratings DECIMAL(3,2),
    customer_rating DECIMAL(3,2),
    payment_method VARCHAR(50)
);

SHOW TABLES;
DESCRIBE ride_bookings;

SELECT COUNT(*) AS total_records
FROM ride_bookings;

SELECT *
FROM ride_bookings
LIMIT 10;

-- NULL values check
SELECT
    COUNT(*) AS total_rows,
    SUM(booking_id IS NULL) AS null_booking_id,
    SUM(booking_status IS NULL) AS null_booking_status,
    SUM(vehicle_type IS NULL) AS null_vehicle_type,
    SUM(pickup_location IS NULL) AS null_pickup_location,
    SUM(drop_location IS NULL) AS null_drop_location,
    SUM(booking_value IS NULL) AS null_booking_value,
    SUM(ride_distance IS NULL) AS null_ride_distance,
    SUM(payment_method IS NULL) AS null_payment_method
FROM ride_bookings;

SELECT
    booking_status,
    COUNT(*) AS total_bookings,
    SUM(booking_value IS NULL) AS null_booking_value,
    SUM(ride_distance IS NULL) AS null_ride_distance,
    SUM(payment_method IS NULL) AS null_payment_method
FROM ride_bookings
GROUP BY booking_status
ORDER BY total_bookings DESC;

SELECT booking_status,
    COUNT(*) AS total_bookings
FROM ride_bookings
GROUP BY booking_status
ORDER BY total_bookings DESC;

-- Duplicate Booking IDs
SELECT booking_id, COUNT(*) AS duplicate_count
FROM ride_bookings
GROUP BY booking_id
HAVING COUNT(*) > 1;

SELECT 
    COUNT(*) - COUNT(DISTINCT booking_id) AS duplicate_records
FROM ride_bookings;

SELECT *
FROM ride_bookings
WHERE booking_id = '"CNR2726142"';

SELECT 
    booking_id,
    COUNT(*) AS duplicate_count
FROM ride_bookings
GROUP BY booking_id
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC
LIMIT 1;

-- Booking Status check
SELECT booking_status, COUNT(*) AS total_bookings
FROM ride_bookings
GROUP BY booking_status
ORDER BY total_bookings DESC;

-- Total Bookings
SELECT COUNT(*) AS total_bookings
FROM ride_bookings;

-- Q2) Completed Rides
SELECT COUNT(*) AS completed_rides
FROM ride_bookings
WHERE booking_status = 'Completed';

-- Q3) Cancellation Rate
SELECT
    ROUND(
        SUM(booking_status IN ('Cancelled by Driver', 'Cancelled by Customer'))
        * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate
FROM ride_bookings;

-- Q4) Completed Ride Rate
SELECT
    ROUND(
        SUM(booking_status = 'Completed') * 100.0 / COUNT(*),
        2
    ) AS completed_rate
FROM ride_bookings;

-- Q5) Booking Status Distribution
SELECT
    booking_status,
    COUNT(*) AS total_bookings,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ride_bookings), 2) AS percentage
FROM ride_bookings
GROUP BY booking_status
ORDER BY total_bookings DESC;

-- Q6) Total Revenue
SELECT 
    SUM(booking_value) AS total_revenue
FROM ride_bookings
WHERE booking_status = 'Completed';

-- Q7) Average Booking Value
SELECT 
    ROUND(AVG(booking_value), 2) AS avg_booking_value
FROM ride_bookings
WHERE booking_status = 'Completed';

-- Q8) Total Ride Distance
SELECT 
    ROUND(SUM(ride_distance), 2) AS total_ride_distance
FROM ride_bookings
WHERE booking_status = 'Completed';

-- Q9) Average Ride Distance
SELECT 
    ROUND(AVG(ride_distance), 2) AS avg_ride_distance
FROM ride_bookings
WHERE booking_status = 'Completed';

-- Q10) Vehicle Type Analysis
SELECT 
    vehicle_type,
    COUNT(*) AS total_rides,
    ROUND(SUM(booking_value), 2) AS total_revenue,
    ROUND(AVG(booking_value), 2) AS avg_booking_value,
    ROUND(AVG(ride_distance), 2) AS avg_distance
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY vehicle_type
ORDER BY total_revenue DESC;

-- Q11) Top 10 Pickup Locations
SELECT pickup_location,
    COUNT(*) AS total_rides
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY pickup_location
ORDER BY total_rides DESC
LIMIT 10;

-- Q12) Top 10 Drop Locations
SELECT drop_location,
    COUNT(*) AS total_rides
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY drop_location
ORDER BY total_rides DESC
LIMIT 10;

-- Q13) Revenue by Pickup Location
SELECT pickup_location,
    COUNT(*) AS total_rides,
    ROUND(SUM(booking_value), 2) AS total_revenue
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY pickup_location
ORDER BY total_revenue DESC
LIMIT 10;

-- Q14) Payment Method Analysis
SELECT payment_method,
    COUNT(*) AS total_transactions,
    ROUND(SUM(booking_value), 2) AS total_revenue,
    ROUND(AVG(booking_value), 2) AS avg_booking_value
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- Q15) Vehicle Type vs Payment Method
SELECT vehicle_type,
    payment_method,
    COUNT(*) AS total_rides,
    ROUND(SUM(booking_value), 2) AS total_revenue
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY vehicle_type, payment_method
ORDER BY total_revenue DESC;

-- Q16) Customer Cancellation Count
SELECT COUNT(*) AS customer_cancelled_rides
FROM ride_bookings
WHERE booking_status = 'Cancelled by Customer';

-- Q17) Driver Cancellation Count
SELECT COUNT(*) AS driver_cancelled_rides
FROM ride_bookings
WHERE booking_status = 'Cancelled by Driver';

-- Q18) Customer Cancellation Reasons
SELECT customer_cancellation_reason,
    COUNT(*) AS cancellation_count
FROM ride_bookings
WHERE booking_status = 'Cancelled by Customer'
GROUP BY customer_cancellation_reason
ORDER BY cancellation_count DESC;

-- Q19) Driver Cancellation Reasons
SELECT driver_cancellation_reason,
    COUNT(*) AS cancellation_count
FROM ride_bookings
WHERE booking_status = 'Cancelled by Driver'
GROUP BY driver_cancellation_reason
ORDER BY cancellation_count DESC;

-- Q20) Customer vs Driver Cancellation Rate
SELECT booking_status,
    COUNT(*) AS cancelled_rides,
    ROUND(
        COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ride_bookings),
        2
    ) AS cancellation_rate
FROM ride_bookings
WHERE booking_status IN ('Cancelled by Customer', 'Cancelled by Driver')
GROUP BY booking_status
ORDER BY cancelled_rides DESC;

-- Q21) Cancellation Reason + Vehicle Type 
SELECT vehicle_type,
    booking_status,
    COUNT(*) AS cancellation_count
FROM ride_bookings
WHERE booking_status IN ('Cancelled by Customer', 'Cancelled by Driver')
GROUP BY vehicle_type, booking_status
ORDER BY cancellation_count DESC;

-- Q26) Average Driver Rating
SELECT
    ROUND(AVG(driver_ratings), 2) AS avg_driver_rating
FROM ride_bookings
WHERE booking_status = 'Completed';

-- Q27) Average Customer Rating
SELECT
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM ride_bookings
WHERE booking_status = 'Completed';

-- Q28) Vehicle Type-wise Driver Rating
SELECT vehicle_type,
    ROUND(AVG(driver_ratings), 2) AS avg_driver_rating,
    COUNT(*) AS total_rides
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY vehicle_type
ORDER BY avg_driver_rating DESC;

-- Q29) Vehicle Type-wise Customer Rating
SELECT vehicle_type,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,
    COUNT(*) AS total_rides
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY vehicle_type
ORDER BY avg_customer_rating DESC;

-- Q30) Top 10 Customers by Number of Completed Rides
SELECT customer_id,
    COUNT(*) AS completed_rides
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY customer_id
ORDER BY completed_rides DESC
LIMIT 10;

-- Q31) Hour-wise Booking Analysis
SELECT HOUR(booking_time) AS booking_hour,
    COUNT(*) AS total_bookings
FROM ride_bookings
GROUP BY HOUR(booking_time)
ORDER BY total_bookings DESC;

-- Q32) Peak Booking Hour
SELECT HOUR(booking_time) AS booking_hour,
    COUNT(*) AS total_bookings
FROM ride_bookings
GROUP BY HOUR(booking_time)
ORDER BY total_bookings DESC
LIMIT 1;

-- Q33) Date-wise Booking Trend
SELECT booking_date,
    COUNT(*) AS total_bookings
FROM ride_bookings
GROUP BY booking_date
ORDER BY booking_date;

-- Q34) Date-wise Revenue
SELECT booking_date,
    ROUND(SUM(booking_value), 2) AS total_revenue
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY booking_date
ORDER BY booking_date;

-- Q35) Top 5 Vehicle Types by Revenue 
WITH vehicle_revenue AS (
    SELECT
        vehicle_type,
        SUM(booking_value) AS total_revenue
    FROM ride_bookings
    WHERE booking_status = 'Completed'
    GROUP BY vehicle_type
),
ranked_vehicles AS (
    SELECT
        vehicle_type,
        ROUND(total_revenue, 2) AS total_revenue,
        DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
    FROM vehicle_revenue
)
SELECT
    vehicle_type,
    total_revenue,
    revenue_rank
FROM ranked_vehicles
WHERE revenue_rank <= 5
ORDER BY revenue_rank;

-- Q36) Top 10 Pickup Locations by Revenue
WITH location_revenue AS (
    SELECT
        pickup_location,
        SUM(booking_value) AS total_revenue
    FROM ride_bookings
    WHERE booking_status = 'Completed'
    GROUP BY pickup_location
)
SELECT
    pickup_location,
    ROUND(total_revenue, 2) AS total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM location_revenue
ORDER BY revenue_rank
LIMIT 10;

-- Q37) Vehicle Type Revenue Percentage
WITH vehicle_revenue AS (
    SELECT
        vehicle_type,
        SUM(booking_value) AS total_revenue
    FROM ride_bookings
    WHERE booking_status = 'Completed'
    GROUP BY vehicle_type
)
SELECT
    vehicle_type,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(
        total_revenue * 100.0 /
        SUM(total_revenue) OVER (),
        2
    ) AS revenue_percentage
FROM vehicle_revenue
ORDER BY total_revenue DESC;

-- Q38) Each Vehicle Type Top Pickup Location
WITH location_ranking AS (
    SELECT
        vehicle_type,
        pickup_location,
        COUNT(*) AS total_rides,
        ROW_NUMBER() OVER (
            PARTITION BY vehicle_type
            ORDER BY COUNT(*) DESC
        ) AS location_rank
    FROM ride_bookings
    WHERE booking_status = 'Completed'
    GROUP BY vehicle_type, pickup_location
)
SELECT
    vehicle_type,
    pickup_location,
    total_rides,
    location_rank
FROM location_ranking
WHERE location_rank = 1
ORDER BY vehicle_type;

-- Q39) Month-wise Revenue + Previous Month Revenue — LAG()
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(booking_date, '%Y-%m') AS month,
        SUM(booking_value) AS total_revenue
    FROM ride_bookings
    WHERE booking_status = 'Completed'
    GROUP BY DATE_FORMAT(booking_date, '%Y-%m')
)
SELECT
    month,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(
        LAG(total_revenue) OVER (ORDER BY month),
        2
    ) AS previous_month_revenue
FROM monthly_revenue
ORDER BY month;

-- Q40) Month-over-Month Revenue Growth
WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(booking_date, '%Y-%m') AS month,
        SUM(booking_value) AS total_revenue
    FROM ride_bookings
    WHERE booking_status = 'Completed'
    GROUP BY DATE_FORMAT(booking_date, '%Y-%m')
),
revenue_comparison AS (
    SELECT
        month,
        total_revenue,
        LAG(total_revenue) OVER (ORDER BY month) AS previous_revenue
    FROM monthly_revenue
)
SELECT
    month,
    ROUND(total_revenue, 2) AS total_revenue,
    ROUND(previous_revenue, 2) AS previous_revenue,
    ROUND(
        (total_revenue - previous_revenue)
        * 100.0 / previous_revenue,
        2
    ) AS growth_percentage
FROM revenue_comparison
ORDER BY month;

-- insights  
SELECT
    COUNT(*) AS total_bookings,

    SUM(booking_status = 'Completed') AS completed_rides,

    ROUND(
        SUM(booking_status = 'Completed') * 100.0 / COUNT(*),
        2
    ) AS completion_rate,

    ROUND(
        SUM(booking_status IN ('Cancelled by Customer', 'Cancelled by Driver'))
        * 100.0 / COUNT(*),
        2
    ) AS cancellation_rate,

    ROUND(
        SUM(CASE
            WHEN booking_status = 'Completed'
            THEN booking_value
            ELSE 0
        END), 2
    ) AS total_revenue,

    ROUND(
        AVG(CASE
            WHEN booking_status = 'Completed'
            THEN booking_value
        END), 2
    ) AS avg_booking_value,

    ROUND(
        SUM(CASE
            WHEN booking_status = 'Completed'
            THEN ride_distance
            ELSE 0
        END), 2
    ) AS total_ride_distance,

    ROUND(
        AVG(CASE
            WHEN booking_status = 'Completed'
            THEN customer_rating
        END), 2
    ) AS avg_customer_rating

FROM ride_bookings;