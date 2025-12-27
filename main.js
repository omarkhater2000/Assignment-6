const express = require('express');
const mysql = require('mysql2');

const app = express();
const port = 3000;

/* ===============================
   MySQL Connection
   =============================== */
const db = mysql.createConnection({
  host: '127.0.0.1',
  port: '3306',
  user: 'root',
  password: '',
  database: 'retail_store',
});

db.connect((err) => {
  if (err) {
    console.error('DB Error:', err);
    return;
  }
  console.log('Connected to MySQL');
});

/* ===============================
   1) Create Tables
   =============================== */
app.get('/create/suppliers', (req, res) => {
  const sql = `
    CREATE TABLE IF NOT EXISTS Suppliers (
      SupplierID INT AUTO_INCREMENT PRIMARY KEY,
      SupplierName VARCHAR(100),
      ContactNumber VARCHAR(15)
    )
  `;

  db.execute(sql, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Suppliers table created' });
  });
});

app.get('/create/products', (req, res) => {
  const sql = `
    CREATE TABLE IF NOT EXISTS Products (
      ProductID INT AUTO_INCREMENT PRIMARY KEY,
      ProductName VARCHAR(100) NOT NULL,
      Price DECIMAL(10,2),
      StockQuantity INT,
      SupplierID INT,
      FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
    )
  `;

  db.execute(sql, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Products table created' });
  });
});

app.get('/create/sales', (req, res) => {
  const sql = `
    CREATE TABLE IF NOT EXISTS Sales (
      SaleID INT AUTO_INCREMENT PRIMARY KEY,
      ProductID INT,
      QuantitySold INT,
      SaleDate DATE,
      FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
    )
  `;

  db.execute(sql, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Sales table created' });
  });
});

app.get('/alter/add-category', (req, res) => {
  const sql = `
    ALTER TABLE Products
    ADD COLUMN Category VARCHAR(50)
  `;

  db.execute(sql, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Category column added to Products' });
  });
});

app.get('/alter/drop-category', (req, res) => {
  const sql = `
    ALTER TABLE Products
    DROP COLUMN Category
  `;
  db.execute(sql, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Category column removed from Products' });
  });
});

app.get('/alter/contactnumber', (req, res) => {
  const sql = `
    ALTER TABLE Suppliers
    MODIFY COLUMN ContactNumber VARCHAR(15)
  `;
  db.execute(sql, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'ContactNumber column type changed to VARCHAR(15)' });
  });
});

app.get('/alter/productname-notnull', (req, res) => {
  const sql = `
    ALTER TABLE Products
    MODIFY COLUMN ProductName VARCHAR(100) NOT NULL
  `;
  db.execute(sql, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'ProductName set to NOT NULL' });
  });
});

/* =======================
   4) Insert Data
======================= */
app.post('/insert/data', (req, res) => {
  const supplier = `
    INSERT INTO Suppliers (SupplierName, ContactNumber)
    VALUES ('FreshFoods', '01012345678')
  `;

  const products = `
    INSERT INTO Products (ProductName, Price, StockQuantity, SupplierID)
    VALUES
    ('Milk', 15, 50, 1),
    ('Bread', 10, 30, 1),
    ('Eggs', 20, 40, 1)
  `;

  const sales = `
    INSERT INTO Sales (ProductID, QuantitySold, SaleDate)
    VALUES (1, 2, '2025-05-20')
  `;

  db.execute(supplier, (err) => {
    if (err) return res.status(500).json(err);

    db.execute(products, (err) => {
      if (err) return res.status(500).json(err);

      db.execute(sales, (err) => {
        if (err) return res.status(500).json(err);
        res.json({ message: 'Data inserted successfully' });
      });
    });
  });
});

/* =======================
   5) UPDATE
======================= */
app.put('/update/bread', (req, res) => {
  const sql = `
    UPDATE Products
    SET Price = 25
    WHERE ProductName = 'Bread'
  `;

  db.execute(sql, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Bread updated' });
  });
});

/* =======================
   6) DELETE
======================= */
app.delete('/delete/eggs', (req, res) => {
  const sql = `
    DELETE FROM Products
    WHERE ProductName = 'Eggs'
  `;

  db.execute(sql, (err) => {
    if (err) return res.status(500).json(err);
    res.json({ message: 'Eggs deleted' });
  });
});

/* =======================
   7) SELECT Queries
======================= */
app.get('/reports/total-sold', (req, res) => {
  const sql = `
    SELECT p.ProductName, SUM(s.QuantitySold) AS totalSold
    FROM Products p
    LEFT JOIN Sales s ON p.ProductID = s.ProductID
    GROUP BY p.ProductName
  `;

  db.execute(sql, (err, data) => {
    if (err) return res.status(500).json(err);
    res.json(data);
  });
});

app.get('/reports/highest-stock', (req, res) => {
  const sql = `
    SELECT *
    FROM Products
    ORDER BY StockQuantity DESC
    LIMIT 1
  `;

  db.execute(sql, (err, data) => {
    if (err) return res.status(500).json(err);
    res.json(data);
  });
});

/* =======================
   Suppliers name starts with F
======================= */
app.get('/reports/suppliers-f', (req, res) => {
  const sql = `
    SELECT *
    FROM Suppliers
    WHERE SupplierName LIKE 'F%'
  `;

  db.execute(sql, (err, data) => {
    if (err) return res.status(500).json(err);
    res.json(data);
  });
});

/* =======================
   Products never sold
======================= */
app.get('/reports/never-sold', (req, res) => {
  const sql = `
    SELECT p.*
    FROM Products p
    LEFT JOIN Sales s ON p.ProductID = s.ProductID
    WHERE s.ProductID IS NULL
  `;

  db.execute(sql, (err, data) => {
    if (err) return res.status(500).json(err);
    res.json(data);
  });
});

app.get('/reports/sales-details', (req, res) => {
  const sql = `
    SELECT s.SaleID, p.ProductName, s.QuantitySold, s.SaleDate
    FROM Sales s
    JOIN Products p ON s.ProductID = p.ProductID
  `;
  db.execute(sql, (err, data) => {
    if (err) return res.status(500).json(err);
    res.json(data);
  });
});

/* ===============================
   Server
   =============================== */
app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
