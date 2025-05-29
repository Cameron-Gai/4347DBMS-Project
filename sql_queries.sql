-- TopEarningDrivers: top 5 drivers by sum(ride_fare + order delivery fees)
SELECT d.driver_id, u.first_name, u.last_name,
       SUM(COALESCE(fo.total_amount,0)) AS total_earnings
FROM Drivers d
JOIN Users u        ON u.user_id = d.driver_id
LEFT JOIN Food_Orders fo
  ON fo.driver_id = d.driver_id
GROUP BY d.driver_id, u.first_name, u.last_name
ORDER BY total_earnings DESC
LIMIT 5;

-- HighSpendingCustomers: spent >1000
SELECT c.customer_id, u.first_name, u.last_name,
       SUM(fo.total_amount) AS total_spent
FROM Customers c
JOIN Users u        ON u.user_id = c.customer_id
JOIN Food_Orders fo ON fo.customer_id = c.customer_id
GROUP BY c.customer_id, u.first_name, u.last_name
HAVING SUM(fo.total_amount) > 1000;

-- FrequentReviewers: ≥10 reviews + avg rating
SELECT rv.customer_id, u.first_name, u.last_name,
       COUNT(*)       AS num_reviews,
       AVG(rv.rating) AS avg_rating
FROM (
  SELECT customer_id, rating FROM Restaurant_Reviews
  UNION ALL
  SELECT customer_id, rating FROM Item_Reviews
) rv
JOIN Users u ON u.user_id = rv.customer_id
GROUP BY rv.customer_id, u.first_name, u.last_name
HAVING COUNT(*) >= 2;

-- InactiveRestaurants: no orders in past month
SELECT r.restaurant_id, r.name
FROM Restaurants r
LEFT JOIN Food_Orders fo
  ON fo.restaurant_id = r.restaurant_id
	AND fo.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
	AND fo.order_date <= CURDATE()
WHERE fo.order_id IS NULL;

-- PeakOrderDay: weekday w/ most orders last month
SELECT DAYNAME(order_date) AS weekday,
       COUNT(*)          AS orders_count
FROM Food_Orders
WHERE order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
AND order_date <= CURDATE()
GROUP BY DAYNAME(order_date)
ORDER BY orders_count DESC
LIMIT 1;

-- HighEarningRestaurants: top 3 by revenue past year
SELECT r.restaurant_id, r.name,
       SUM(fo.total_amount) AS revenue
FROM Restaurants r
JOIN Food_Orders fo
  ON fo.restaurant_id = r.restaurant_id
WHERE fo.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
AND fo.order_date <= CURDATE()
GROUP BY r.restaurant_id, r.name
ORDER BY revenue DESC
LIMIT 3;

-- PopularCuisineType: most ordered cuisine past 6 months
SELECT r.cuisine,
       SUM(oi.quantity) AS total_orders
FROM Restaurants r
JOIN Order_Items oi
  ON oi.restaurant_id = r.restaurant_id
JOIN Food_Orders fo
  ON fo.order_id = oi.order_id
WHERE fo.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
AND fo.order_date <= CURDATE()
GROUP BY r.cuisine
ORDER BY total_orders DESC
LIMIT 1;

-- LongestRideRoutes: top 5 by ride_distance
SELECT ride_id, rider_id, ride_distance
FROM Rides
ORDER BY ride_distance DESC
LIMIT 5;

-- DriverRideCounts: # rides per driver past 3 months
SELECT fo.driver_id, u.first_name, u.last_name,
       COUNT(*) AS ride_count
FROM Food_Orders fo
JOIN Drivers d ON d.driver_id = fo.driver_id
JOIN Users u   ON u.user_id   = d.driver_id
WHERE fo.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
AND fo.order_date <= CURDATE()
GROUP BY fo.driver_id, u.first_name, u.last_name;

-- UndeliveredOrders:
SELECT
	order_id,
    delivery_status
FROM Food_Orders AS fo
WHERE fo.delivery_status <> 'delivered';

-- MostCommonPaymentMethods: across rides & food
SELECT payment_method, COUNT(*) AS usage_count
FROM (
  SELECT payment_method FROM Food_Orders
  UNION ALL
  SELECT payment_status AS payment_method FROM Rides
) AS pm
GROUP BY payment_method
ORDER BY usage_count DESC
LIMIT 1;

-- MultiRoleUsers: users who are both drivers & owners
SELECT u.user_id, u.first_name, u.last_name
FROM Users u
WHERE u.user_id IN (SELECT user_id FROM Drivers)
  AND u.user_id IN (SELECT user_id  FROM Restaurant_Owners);

-- DriverVehicleTypes: distribution by type
SELECT vehicle_type, COUNT(*) AS num_drivers
FROM Drivers
GROUP BY vehicle_type;
