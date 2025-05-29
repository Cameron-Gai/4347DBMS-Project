-- 1. LoyalCustomers: orders every month in the past year
CREATE VIEW LoyalCustomers AS
SELECT customer_id
FROM Food_Orders
WHERE order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 YEAR)
GROUP BY customer_id
HAVING COUNT(DISTINCT MONTH(order_date)) = 12;

-- 2. TopRatedRestaurants: avg rating ≥4.5 in past 6 months
CREATE VIEW TopRatedRestaurants AS
SELECT restaurant_id
FROM Restaurant_Reviews
WHERE review_date >= DATE_SUB(CURRENT_DATE, INTERVAL 6 MONTH)
GROUP BY restaurant_id
HAVING AVG(rating) >= 4.5;

-- 3. ActiveDrivers: ≥20 deliveries in last 2 weeks
CREATE VIEW ActiveDrivers AS
SELECT driver_id
FROM Food_Orders
WHERE driver_id IS NOT NULL
  AND order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 14 DAY)
GROUP BY driver_id
HAVING COUNT(*) >= 20;

-- 4. PopularMenuItems: top 10 by qty in past 3 months
CREATE VIEW PopularMenuItems AS
SELECT oi.restaurant_id, oi.item_name,
       SUM(oi.quantity) AS total_ordered
FROM Order_Items oi
JOIN Food_Orders fo ON fo.order_id = oi.order_id
WHERE fo.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 3 MONTH)
GROUP BY oi.restaurant_id, oi.item_name
ORDER BY total_ordered DESC
LIMIT 10;

-- 5. ProminentOwners: owners w/ ≥50 combined orders last month
CREATE VIEW ProminentOwners AS
SELECT ro.owner_id
FROM Restaurants r
JOIN Food_Orders fo ON fo.restaurant_id = r.restaurant_id
JOIN Restaurant_Owners ro ON ro.owner_id = r.owner_id
WHERE fo.order_date >= DATE_SUB(CURRENT_DATE, INTERVAL 1 MONTH)
GROUP BY ro.owner_id
HAVING COUNT(*) >= 50;