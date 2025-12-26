-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 26, 2025 at 08:07 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `retail_store`
--

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `ProductID` int(11) NOT NULL,
  `ProductName` varchar(100) NOT NULL,
  `Price` decimal(10,2) DEFAULT NULL,
  `StockQuantity` int(11) DEFAULT NULL,
  `SupplierID` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`ProductID`, `ProductName`, `Price`, `StockQuantity`, `SupplierID`) VALUES
(1, 'Milk', 15.00, 50, 1),
(2, 'Bread', 25.00, 30, 1),
(4, 'Milk', 15.00, 50, 1),
(5, 'Bread', 25.00, 30, 1),
(7, 'Milk', 15.00, 50, 1),
(8, 'Bread', 25.00, 30, 1);

-- --------------------------------------------------------

--
-- Table structure for table `sales`
--

CREATE TABLE `sales` (
  `SaleID` int(11) NOT NULL,
  `ProductID` int(11) DEFAULT NULL,
  `QuantitySold` int(11) DEFAULT NULL,
  `SaleDate` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `sales`
--

INSERT INTO `sales` (`SaleID`, `ProductID`, `QuantitySold`, `SaleDate`) VALUES
(1, 1, 2, '2025-05-20'),
(2, 1, 2, '2025-05-20');

-- --------------------------------------------------------

--
-- Table structure for table `suppliers`
--

CREATE TABLE `suppliers` (
  `SupplierID` int(11) NOT NULL,
  `SupplierName` varchar(100) DEFAULT NULL,
  `ContactNumber` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `suppliers`
--

INSERT INTO `suppliers` (`SupplierID`, `SupplierName`, `ContactNumber`) VALUES
(1, 'FreshFoods', '01026319072'),
(2, 'FreshFoods', '01026319072'),
(3, 'FreshFoods', '01026319072');




--  Add + Remove Category column
ALTER TABLE products ADD COLUMN Category VARCHAR(50);
ALTER TABLE products DROP COLUMN Category;

--  SELECT Queries
SELECT p.ProductName, SUM(s.QuantitySold) AS TotalSold
FROM products p
LEFT JOIN sales s ON p.ProductID = s.ProductID
GROUP BY p.ProductName;

SELECT ProductName, StockQuantity
FROM products
ORDER BY StockQuantity DESC
LIMIT 1;

SELECT * FROM suppliers
WHERE SupplierName LIKE 'F%';

SELECT p.ProductName
FROM products p
LEFT JOIN sales s ON p.ProductID = s.ProductID
WHERE s.ProductID IS NULL;

SELECT p.ProductName, s.SaleDate, s.QuantitySold
FROM sales s
JOIN products p ON s.ProductID = p.ProductID;





-- 1 Remove duplicate products
DELETE FROM products WHERE ProductID NOT IN (
    SELECT MIN(ProductID) 
    FROM products 
    GROUP BY ProductName
);

-- 2 Add missing product 'Eggs'
INSERT INTO products (`ProductName`, `Price`, `StockQuantity`, `SupplierID`)
SELECT 'Eggs', 20.00, 40, 1
WHERE NOT EXISTS (
    SELECT 1 FROM products WHERE ProductName='Eggs'
);

-- 3 Add sale for Milk
INSERT INTO sales (`ProductID`, `QuantitySold`, `SaleDate`)
SELECT ProductID, 2, '2025-05-20'
FROM products
WHERE ProductName='Milk'
LIMIT 1;

-- 4 Update Bread price
UPDATE products
SET Price = 25.00
WHERE ProductName='Bread';

-- 5 Delete Eggs
DELETE FROM products
WHERE ProductName='Eggs';


--
-- Indexes for dumped tables
--

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`ProductID`),
  ADD KEY `SupplierID` (`SupplierID`);

--
-- Indexes for table `sales`
--
ALTER TABLE `sales`
  ADD PRIMARY KEY (`SaleID`),
  ADD KEY `ProductID` (`ProductID`);

--
-- Indexes for table `suppliers`
--
ALTER TABLE `suppliers`
  ADD PRIMARY KEY (`SupplierID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `ProductID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `sales`
--
ALTER TABLE `sales`
  MODIFY `SaleID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `suppliers`
--
ALTER TABLE `suppliers`
  MODIFY `SupplierID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`SupplierID`) REFERENCES `suppliers` (`SupplierID`);

--
-- Constraints for table `sales`
--
ALTER TABLE `sales`
  ADD CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`ProductID`) REFERENCES `products` (`ProductID`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
