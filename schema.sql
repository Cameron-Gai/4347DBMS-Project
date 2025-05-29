-- USERS
CREATE TABLE Users (
  user_id           INT            PRIMARY KEY AUTO_INCREMENT,
  first_name        VARCHAR(50)    NOT NULL,
  middle_name       VARCHAR(50),
  last_name         VARCHAR(50)    NOT NULL,
  gender            CHAR(1)        CHECK (gender IN ('M','F','O')),
  date_of_birth     DATE           NOT NULL,
  address           VARCHAR(200)
);

-- USER_PHONES
CREATE TABLE User_Phones (
  user_id           INT            NOT NULL,
  phone_number      VARCHAR(20)    NOT NULL,
  PRIMARY KEY(user_id, phone_number),
  FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE CASCADE
);

-- EMPLOYEES & subtypes
CREATE TABLE Employees (
  employee_id       INT            PRIMARY KEY AUTO_INCREMENT,
  user_id           INT            NOT NULL UNIQUE,
  title             VARCHAR(50),
  salary            DECIMAL(10,2),
  department        VARCHAR(50),
  start_date        DATE          NOT NULL,
  FOREIGN KEY(user_id) REFERENCES Users(user_id) ON DELETE RESTRICT
);
CREATE TABLE Support_Agents (
  employee_id       INT PRIMARY KEY,
  FOREIGN KEY(employee_id) REFERENCES Employees(employee_id)
);
CREATE TABLE Platform_Managers (
  employee_id       INT PRIMARY KEY,
  FOREIGN KEY(employee_id) REFERENCES Employees(employee_id)
);
CREATE TABLE Delivery_Coordinators (
  employee_id       INT PRIMARY KEY,
  FOREIGN KEY(employee_id) REFERENCES Employees(employee_id)
);

-- CUSTOMERS, DRIVERS, OWNERS
CREATE TABLE Customers (
  customer_id       INT PRIMARY KEY,
  FOREIGN KEY(customer_id) REFERENCES Users(user_id)
);
CREATE TABLE Drivers (
  driver_id         INT PRIMARY KEY,
  user_id           INT    NOT NULL UNIQUE,
  vehicle_type      VARCHAR(30),
  vehicle_plate     VARCHAR(20),
  experience        INT,
  FOREIGN KEY(driver_id) REFERENCES Users(user_id)
);
CREATE TABLE Restaurant_Owners (
  owner_id          INT PRIMARY KEY,
  FOREIGN KEY(owner_id) REFERENCES Users(user_id)
);

-- RESTAURANTS
CREATE TABLE Restaurants (
  restaurant_id     INT            PRIMARY KEY AUTO_INCREMENT,
  owner_id          INT            NOT NULL,
  name              VARCHAR(100)   NOT NULL,
  address           VARCHAR(200),
  cuisine           VARCHAR(50),
  operational_hours VARCHAR(100),
  FOREIGN KEY(owner_id) REFERENCES Restaurant_Owners(owner_id)
);

-- MENU items
CREATE TABLE Menu_Items (
  restaurant_id     INT         NOT NULL,
  item_name         VARCHAR(100) NOT NULL,
  description       TEXT,
  price             DECIMAL(8,2),
  category          VARCHAR(50),
  PRIMARY KEY(restaurant_id, item_name),
  FOREIGN KEY(restaurant_id) REFERENCES Restaurants(restaurant_id)
);

-- PROMOTIONS & link to items
CREATE TABLE Promotions (
  promotion_id      INT            PRIMARY KEY AUTO_INCREMENT,
  restaurant_id     INT            NOT NULL,
  description       TEXT,
  valid_from        DATE,
  valid_to          DATE,
  FOREIGN KEY(restaurant_id) REFERENCES Restaurants(restaurant_id)
);
CREATE TABLE Promotion_Items (
  promotion_id      INT            NOT NULL,
  restaurant_id     INT            NOT NULL,
  item_name         VARCHAR(100)   NOT NULL,
  PRIMARY KEY(promotion_id, restaurant_id, item_name),
  FOREIGN KEY(promotion_id) REFERENCES Promotions(promotion_id),
  FOREIGN KEY(restaurant_id, item_name)
    REFERENCES Menu_Items(restaurant_id, item_name)
);

-- FOOD ORDERS & their items
CREATE TABLE Food_Orders (
  order_id          INT            PRIMARY KEY AUTO_INCREMENT,
  order_date        DATE           NOT NULL,
  customer_id       INT            NOT NULL,
  restaurant_id     INT            NOT NULL,
  coordinator_id    INT,
  driver_id         INT,
  total_amount      DECIMAL(10,2),
  payment_method    VARCHAR(20),
  delivery_status   VARCHAR(20),
  FOREIGN KEY(customer_id) REFERENCES Customers(customer_id),
  FOREIGN KEY(restaurant_id) REFERENCES Restaurants(restaurant_id),
  FOREIGN KEY(coordinator_id) REFERENCES Delivery_Coordinators(employee_id),
  FOREIGN KEY(driver_id) REFERENCES Drivers(driver_id)
);
CREATE TABLE Order_Items (
  order_id          INT            NOT NULL,
  item_name         VARCHAR(100)   NOT NULL,
  restaurant_id     INT            NOT NULL,
  quantity          INT            NOT NULL CHECK (quantity>0),
  PRIMARY KEY(order_id, item_name),
  FOREIGN KEY(order_id) REFERENCES Food_Orders(order_id) ON DELETE CASCADE,
  FOREIGN KEY(restaurant_id, item_name)
    REFERENCES Menu_Items(restaurant_id, item_name)
);

-- REVIEWS
CREATE TABLE Restaurant_Reviews (
  review_id         INT            PRIMARY KEY AUTO_INCREMENT,
  restaurant_id     INT            NOT NULL,
  customer_id       INT            NOT NULL,
  rating            DECIMAL(2,1)   NOT NULL CHECK (rating BETWEEN 0 AND 5),
  feedback          TEXT,
  review_date       DATE           NOT NULL,
  FOREIGN KEY(restaurant_id) REFERENCES Restaurants(restaurant_id),
  FOREIGN KEY(customer_id) REFERENCES Customers(customer_id)
);
CREATE TABLE Item_Reviews (
  review_id         INT            PRIMARY KEY AUTO_INCREMENT,
  restaurant_id     INT            NOT NULL,
  item_name         VARCHAR(100)   NOT NULL,
  customer_id       INT            NOT NULL,
  rating            DECIMAL(2,1)   NOT NULL CHECK (rating BETWEEN 0 AND 5),
  feedback          TEXT,
  review_date       DATE           NOT NULL,
  FOREIGN KEY(restaurant_id, item_name)
    REFERENCES Menu_Items(restaurant_id, item_name),
  FOREIGN KEY(customer_id) REFERENCES Customers(customer_id)
);

-- RIDES & their reviews
CREATE TABLE Rides (
  ride_id           INT            PRIMARY KEY AUTO_INCREMENT,
  rider_id          INT            NOT NULL,
  pickup_location   VARCHAR(200),
  dropoff_location  VARCHAR(200),
  ride_date         DATE           NOT NULL,
  pickup_time       TIME,
  dropoff_time      TIME,
  ride_fare         DECIMAL(8,2),
  ride_distance     DECIMAL(6,2),
  payment_status    VARCHAR(20),
  FOREIGN KEY(rider_id) REFERENCES Customers(customer_id)
);
CREATE TABLE Ride_Reviews (
  review_id         INT            PRIMARY KEY AUTO_INCREMENT,
  ride_id           INT            NOT NULL,
  customer_id       INT            NOT NULL,
  rating            DECIMAL(2,1)   NOT NULL CHECK (rating BETWEEN 0 AND 5),
  feedback          TEXT,
  review_date       DATE           NOT NULL,
  FOREIGN KEY(ride_id) REFERENCES Rides(ride_id),
  FOREIGN KEY(customer_id) REFERENCES Customers(customer_id)
);
