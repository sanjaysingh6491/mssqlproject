--Select all columns from Product table
SELECT 
  * 
FROM 
  [SalesLT].[Product];

--Select CustomerID, FirstName, and LastName from the Customer table
SELECT 
  [CustomerID], 
  [FirstName], 
  [LastName] 
FROM 
  [SalesLT].[Customer];

--Count the number of rows in ProductModel table
SELECT 
  COUNT(*) AS ProductModelCount 
FROM 
  [SalesLT].[ProductModel];

--Filter the Product table to find the ProductIDs greater than 750 and less than 850
SELECT 
  * 
FROM 
  [SalesLT].[Product] 
WHERE 
  [ProductID] > 750 
  AND [ProductID] < 850;

--Order Products by ListPrice in descending order
SELECT 
  * 
FROM 
  [SalesLT].[Product] 
ORDER BY 
  [ListPrice] DESC;

--Find Products with ListPrice greater than $1000
SELECT 
  * 
FROM 
  [SalesLT].[Product] 
WHERE 
  [ListPrice] > 1000;

--Join the Product and ProductCategory tables to get Product names along with their Category names
SELECT 
  p.[ProductID], 
  p.[Name], 
  pc.[Name] AS CategoryName 
FROM 
  [SalesLT].[Product] p 
  JOIN [SalesLT].[ProductCategory] pc ON p.[ProductCategoryID] = pc.[ProductCategoryID];

--Aggregate functions: Calculate the average ListPrice of all Products
SELECT 
  AVG([ListPrice]) AS AverageListPrice 
FROM 
  [SalesLT].[Product];

--Group Products by ProductCategoryID and count the number of Products in each category
SELECT 
  [ProductCategoryID], 
  COUNT(*) AS ProductCount 
FROM 
  [SalesLT].[Product] 
GROUP BY 
  [ProductCategoryID];

--Find the latest modified Product based on the ModifiedDate column
SELECT 
  TOP 1 * 
FROM 
  [SalesLT].[Product] 
ORDER BY 
  [ModifiedDate] DESC;

--Subquery: Find Products with ListPrice greater than the average ListPrice
SELECT 
  * 
FROM 
  [SalesLT].[Product] 
WHERE 
  [ListPrice] > (
    SELECT 
      AVG([ListPrice]) 
    FROM 
      [SalesLT].[Product]
  );

--Use a Common Table Expression (CTE) to calculate the running total of Product ListPrice
WITH RunningTotal AS (
  SELECT 
    [ProductID], 
    [ListPrice], 
    SUM([ListPrice]) OVER (
      ORDER BY 
        [ProductID]
    ) AS RunningTotal 
  FROM 
    [SalesLT].[Product]
) 
SELECT 
  * 
FROM 
  RunningTotal;

--Use a window function to rank Products by ListPrice within each ProductCategoryID
SELECT 
  [ProductID], 
  [Name], 
  [ListPrice], 
  [ProductCategoryID], 
  RANK() OVER (
    PARTITION BY [ProductCategoryID] 
    ORDER BY 
      [ListPrice] DESC
  ) AS PriceRank 
FROM 
  [SalesLT].[Product];

--Perform a self join to find Customers who have the same last name
SELECT 
  c1.[CustomerID], 
  c1.[FirstName], 
  c1.[LastName], 
  c2.[CustomerID] AS MatchedCustomerID 
FROM 
  [SalesLT].[Customer] c1 
  JOIN [SalesLT].[Customer] c2 ON c1.[LastName] = c2.[LastName] 
  AND c1.[CustomerID] != c2.[CustomerID];

--Insert a new Product into the Product table
INSERT INTO [SalesLT].[Product] (
  [ProductNumber], [Name], [Color], 
  [StandardCost], [ListPrice], [SellStartDate]
) 
VALUES 
  (
    3456, 
    'New Product', 
    'Red', 
    50.00, 
    100.00, 
    GETDATE()
  );

--Update the ListPrice of a Product with a specific ProductID, such as 100?
UPDATE 
  [SalesLT].[Product] 
SET 
  [ListPrice] = [ListPrice] * 1.10 
WHERE 
  [ProductID] = 100;

--Delete Product with specific ProductID
DELETE FROM 
  [SalesLT].[Product] 
WHERE 
  [ProductID] = 10;

--Create a view to display Product information including Category names
CREATE VIEW vw_ProductInfo AS 
SELECT 
  p.[ProductID], 
  p.[Name], 
  p.[ListPrice], 
  pc.[Name] AS CategoryName 
FROM 
  [SalesLT].[Product] p 
  JOIN [SalesLT].[ProductCategory] pc ON p.[ProductCategoryID] = pc.[ProductCategoryID];

--Select data from the created view vw_ProductInfo
SELECT 
  * 
FROM 
  vw_ProductInfo;

--Join multiple tables, such as Product, ProductModel, and ProductDescription, to get detailed Product information
SELECT 
  p.[ProductID], 
  p.[Name], 
  pm.[Name] AS ModelName, 
  pd.[Description] 
FROM 
  [SalesLT].[Product] p 
  JOIN [SalesLT].[ProductModel] pm ON p.[ProductModelID] = pm.[ProductModelID] 
  JOIN [SalesLT].[ProductModelProductDescription] pmpd ON pm.[ProductModelID] = pmpd.[ProductModelID] 
  JOIN [SalesLT].[ProductDescription] pd ON pmpd.[ProductDescriptionID] = pd.[ProductDescriptionID];

--Find Customers with more than one address using a correlated subquery
SELECT 
  c.[CustomerID], 
  c.[FirstName], 
  c.[LastName] 
FROM 
  [SalesLT].[Customer] c 
WHERE 
  (
    SELECT 
      COUNT(*) 
    FROM 
      [SalesLT].[CustomerAddress] ca 
    WHERE 
      ca.[CustomerID] = c.[CustomerID]
  ) > 1;

--List Product categories and their hierarchy using a recursive CTE
WITH CategoryHierarchy AS (
  SELECT 
    [ProductCategoryID], 
    [ParentProductCategoryID], 
    [Name], 
    0 AS Level 
  FROM 
    [SalesLT].[ProductCategory] 
  WHERE 
    [ParentProductCategoryID] IS NULL 
  UNION ALL 
  SELECT 
    pc.[ProductCategoryID], 
    pc.[ParentProductCategoryID], 
    pc.[Name], 
    ch.Level + 1 
  FROM 
    [SalesLT].[ProductCategory] pc 
    JOIN CategoryHierarchy ch ON pc.[ParentProductCategoryID] = ch.[ProductCategoryID]
) 
SELECT 
  * 
FROM 
  CategoryHierarchy;

--Use TRY...CATCH to handle errors during an update
BEGIN TRY 
UPDATE 
  [SalesLT].[Product] 
SET 
  [ListPrice] = -100 
WHERE 
  [ProductID] = 10;
END TRY BEGIN CATCH 
SELECT 
  ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

--Generate a dynamic SELECT statement using Dynamic SQL
DECLARE @sql NVARCHAR(MAX);
SET 
  @sql = N 'SELECT [ProductID], [Name] FROM [SalesLT].[Product] WHERE [ListPrice] > @price';
EXEC sp_executesql @sql, 
N '@price money', 
@price = 100;

--Use a CROSS APPLY to get the top-selling Products for each ProductCategory
SELECT 
  pc.[Name] AS CategoryName, 
  p.[Name] AS ProductName, 
  p.[ListPrice] 
FROM 
  [SalesLT].[ProductCategory] pc CROSS APPLY (
    SELECT 
      TOP 1 [Name], 
      [ListPrice] 
    FROM 
      [SalesLT].[Product] 
    WHERE 
      [ProductCategoryID] = pc.[ProductCategoryID] 
    ORDER BY 
      [ListPrice] DESC
  ) AS p;

--Use the COALESCE function to handle NULL values in the Customer table
SELECT 
  [CustomerID], 
  [FirstName], 
  [LastName], 
  COALESCE([Phone], 'No Phone') AS Phone 
FROM 
  [SalesLT].[Customer];

--Use the FOR XML PATH clause to generate XML output from a query
SELECT 
  [ProductID], 
  [Name] 
FROM 
  [SalesLT].[Product] FOR XML PATH('Product'), 
  ROOT('Products');

--Use the FOR JSON PATH clause to generate JSON output from a query
SELECT 
  [ProductID], 
  [Name] 
FROM 
  [SalesLT].[Product] FOR JSON PATH, 
  ROOT('Products');

--Implement a stored procedure to insert a new Product
CREATE PROCEDURE InsertProduct @Name NVARCHAR(100), 
@Color NVARCHAR(15), 
@StandardCost MONEY, 
@ListPrice MONEY, 
@SellStartDate DATETIME AS BEGIN INSERT INTO [SalesLT].[Product] (
  [Name], [Color], [StandardCost], [ListPrice], 
  [SellStartDate]
) 
VALUES 
  (
    @Name, @Color, @StandardCost, @ListPrice, 
    @SellStartDate
  );
END;

--Call the stored procedure InsertProduct to add a new Product
EXEC InsertProduct 'New Product', 
'Green', 
75.00, 
150.00, 
GETDATE();

--How do you use a cursor to iterate through each row in the Customer table
DECLARE @CustomerID INT, 
@FirstName NVARCHAR(50), 
@LastName NVARCHAR(50);
DECLARE customer_cursor CURSOR FOR 
SELECT 
  [CustomerID], 
  [FirstName], 
  [LastName] 
FROM 
  [SalesLT].[Customer];
OPEN customer_cursor;
FETCH NEXT 
FROM 
  customer_cursor INTO @CustomerID, 
  @FirstName, 
  @LastName;
WHILE @@FETCH_STATUS = 0 BEGIN PRINT @FirstName + ' ' + @LastName;
FETCH NEXT 
FROM 
  customer_cursor INTO @CustomerID, 
  @FirstName, 
  @LastName;
END;
CLOSE customer_cursor;
DEALLOCATE customer_cursor;

--Use a trigger to log changes to the Product table
CREATE TRIGGER trg_ProductChange ON [SalesLT].[Product] 
AFTER 
  INSERT, 
UPDATE 
  , 
  DELETE AS BEGIN IF EXISTS (
    SELECT 
      * 
    FROM 
      inserted
  ) BEGIN INSERT INTO [SalesLT].[ProductLog] (
    [ProductID], [ChangeDate], [ChangeType]
  ) 
SELECT 
  [ProductID], 
  GETDATE(), 
  'INSERT' 
FROM 
  inserted;
END IF EXISTS (
  SELECT 
    * 
  FROM 
    deleted
) BEGIN INSERT INTO [SalesLT].[ProductLog] (
  [ProductID], [ChangeDate], [ChangeType]
) 
SELECT 
  [ProductID], 
  GETDATE(), 
  'DELETE' 
FROM 
  deleted;
END END;

--Implement a transaction to ensure data integrity during updates

BEGIN TRANSACTION;

BEGIN TRY
    -- Update product price
    UPDATE [SalesLT].[Product]
    SET [ListPrice] = [ListPrice] * 1.10
    WHERE [ProductID] = 200;

    -- Insert a new product
    INSERT INTO [SalesLT].[Product] (
        [ProductNumber], [Name], [Color], [StandardCost], [ListPrice], [SellStartDate]
    )
    VALUES (7890, 'Transactional Product', 'Blue', 30.00, 60.00, GETDATE());

    -- Commit transaction if both operations succeed
    COMMIT;
END TRY
BEGIN CATCH
    -- Rollback transaction in case of error
    ROLLBACK;

    -- Output error message
    SELECT ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

--Use the RANK() function to rank products within each category based on their sales
WITH RankedProducts AS (
    SELECT p.[ProductID], p.[Name], p.[ListPrice], p.[ProductCategoryID],
           RANK() OVER (PARTITION BY p.[ProductCategoryID] ORDER BY SUM(s.[Quantity]) DESC) AS SalesRank
    FROM [SalesLT].[Product] p
    JOIN [SalesLT].[SalesOrderDetail] s ON p.[ProductID] = s.[ProductID]
    GROUP BY p.[ProductID], p.[Name], p.[ListPrice], p.[ProductCategoryID]
)
SELECT * FROM RankedProducts
WHERE SalesRank <= 10;

--Generate a report of total sales per month using GROUP BY and DATEPART
SELECT DATEPART(YEAR, [OrderDate]) AS [Year], DATEPART(MONTH, [OrderDate]) AS [Month],
       SUM([TotalDue]) AS TotalSales
FROM [SalesLT].[SalesOrderHeader]
GROUP BY DATEPART(YEAR, [OrderDate]), DATEPART(MONTH, [OrderDate]);

--Create and use a temporary table to store intermediate results
CREATE TABLE #TempProductSummary (
    [ProductID] INT,
    [TotalQuantity] INT
);

-- Insert data into temporary table
INSERT INTO #TempProductSummary
SELECT [ProductID], SUM([Quantity]) AS TotalQuantity
FROM [SalesLT].[SalesOrderDetail]
GROUP BY [ProductID];

-- Query data from temporary table
SELECT p.[Name], t.[TotalQuantity]
FROM #TempProductSummary t
JOIN [SalesLT].[Product] p ON t.[ProductID] = p.[ProductID]
ORDER BY t.[TotalQuantity] DESC;

-- Drop temporary table
DROP TABLE #TempProductSummary;

-- Extract data from XML column in a table
SELECT [ProductID], [Name], [Description]
FROM [SalesLT].[Product]
CROSS APPLY (
    SELECT *
    FROM OPENXML(
        @xmlDocumentHandle, '/Products/Product', 2
    )
    WITH (
        [ProductID] INT 'ProductID',
        [Name] NVARCHAR(100) 'Name',
        [Description] NVARCHAR(MAX) 'Description'
    )
) AS ProductData;

-- Create a JSON document with Product data
DECLARE @json NVARCHAR(MAX);
SET @json = (SELECT [ProductID], [Name]
             FROM [SalesLT].[Product]
             FOR JSON PATH, ROOT('Products'));

--How do you use a cursor to iterate through each row in the Customer table
DECLARE @CustomerID INT, 
@FirstName NVARCHAR(50), 
@LastName NVARCHAR(50);
DECLARE customer_cursor CURSOR FOR 
SELECT 
  [CustomerID], 
  [FirstName], 
  [LastName] 
FROM 
  [SalesLT].[Customer];
OPEN customer_cursor;
FETCH NEXT 
FROM 
  customer_cursor INTO @CustomerID, 
  @FirstName, 
  @LastName;
WHILE @@FETCH_STATUS = 0 BEGIN PRINT @FirstName + ' ' + @LastName;
FETCH NEXT 
FROM 
  customer_cursor INTO @CustomerID, 
  @FirstName, 
  @LastName;
END;
CLOSE customer_cursor;
DEALLOCATE customer_cursor;

--Use a trigger to log changes to the Product table
CREATE TRIGGER trg_ProductChange ON [SalesLT].[Product] 
AFTER 
  INSERT, 
UPDATE 
  , 
  DELETE AS BEGIN IF EXISTS (
    SELECT 
      * 
    FROM 
      inserted
  ) BEGIN INSERT INTO [SalesLT].[ProductLog] (
    [ProductID], [ChangeDate], [ChangeType]
  ) 
SELECT 
  [ProductID], 
  GETDATE(), 
  'INSERT' 
FROM 
  inserted;
END IF EXISTS (
  SELECT 
    * 
  FROM 
    deleted
) BEGIN INSERT INTO [SalesLT].[ProductLog] (
  [ProductID], [ChangeDate], [ChangeType]
) 
SELECT 
  [ProductID], 
  GETDATE(), 
  'DELETE' 
FROM 
  deleted;
END END;

--Implement a transaction to ensure data integrity during an update
BEGIN TRANSACTION;
BEGIN TRY -- Update product price
UPDATE 
  [SalesLT].[Product] 
SET 
  [ListPrice] = [ListPrice] + 10 
WHERE 
  [ProductID] = 10;
--Another Update
UPDATE 
  [SalesLT].[Product] 
SET 
  [ListPrice] = [ListPrice] - 5 
WHERE 
  [ProductID] = 20;
COMMIT TRANSACTION;
END TRY BEGIN CATCH ROLLBACK TRANSACTION;
SELECT 
  ERROR_MESSAGE() AS ErrorMessage;
END CATCH;

--Use the ISNULL function to provide a default value for NULL columns in the Address table
SELECT 
  [AddressID], 
  [AddressLine1], 
  ISNULL(
    [AddressLine2], 'No Address Line 2'
  ) AS AddressLine2 
FROM 
  [SalesLT].[Address];

--Create a function to calculate the age of a Product based on the SellStartDate
CREATE FUNCTION dbo.CalculateProductAge (@SellStartDate DATETIME) RETURNS INT AS BEGIN RETURN DATEDIFF(
  YEAR, 
  @SellStartDate, 
  GETDATE()
);
END;

--How do you use the INCLUDE clause to add non-key columns to a non-clustered index
CREATE NONCLUSTERED INDEX idx_Product_ListPrice ON [SalesLT].[Product] ([ListPrice]) INCLUDE ([Name], [ProductCategoryID]);

--Use the OPTION (RECOMPILE) hint to recompile a query plan
SELECT 
  [ProductID], 
  [Name], 
  [ListPrice] 
FROM 
  [SalesLT].[Product] 
WHERE 
  [ListPrice] > 100 OPTION (RECOMPILE);

--Implement a partitioned table to improve query performance on large datasets
CREATE PARTITION FUNCTION ProductRangePF (int) AS RANGE LEFT FOR 
VALUES 
  (1000, 2000, 3000);
CREATE PARTITION SCHEME ProductRangePS AS PARTITION ProductRangePF TO (
  [PRIMARY], [PRIMARY], [PRIMARY], [PRIMARY]
);
CREATE TABLE [SalesLT].[ProductPartitioned] (
  [ProductID] INT NOT NULL, 
  [Name] NVARCHAR(100) NOT NULL, 
  [ListPrice] MONEY NOT NULL, 
  PRIMARY KEY (ProductID)
) ON ProductRangePS (ProductID);

--Use a derived table to calculate total sales for each Product
SELECT 
  p.[ProductID], 
  p.[Name], 
  SalesData.TotalSales 
FROM 
  [SalesLT].[Product] p 
  JOIN (
    SELECT 
      [ProductID], 
      SUM([OrderQty]) AS TotalSales 
    FROM 
      [SalesLT].[SalesOrderDetail] 
    GROUP BY 
      [ProductID]
  ) AS SalesData ON p.[ProductID] = SalesData.[ProductID];

--Use a table variable to store intermediate results within a batch
DECLARE @ProductSales TABLE (ProductID INT, TotalSales INT);

-- Insert data into table variable
INSERT INTO @ProductSales (ProductID, TotalSales) 
SELECT 
  [ProductID], 
  SUM([OrderQty]) 
FROM 
  [SalesLT].[SalesOrderDetail] 
GROUP BY 
  [ProductID];

-- Query data from table variable
SELECT 
  p.[ProductID], 
  p.[Name], 
  ps.[TotalSales] 
FROM 
  [SalesLT].[Product] p 
  JOIN @ProductSales ps ON p.[ProductID] = ps.[ProductID];

--Use the ROW_NUMBER() function to assign row numbers to Products ordered by ListPrice
SELECT 
  [ProductID], 
  [Name], 
  [ListPrice], 
  ROW_NUMBER() OVER (
    ORDER BY 
      [ListPrice] DESC
  ) AS RowNum 
FROM 
  [SalesLT].[Product];

--Use the CROSS APPLY operator to join each Product with its respective ProductCategory and display only those Products that have a category
SELECT 
  p.[ProductID], 
  p.[Name], 
  pc.[Name] AS CategoryName 
FROM 
  [SalesLT].[Product] p CROSS APPLY (
    SELECT 
      [Name] 
    FROM 
      [SalesLT].[ProductCategory] pc 
    WHERE 
      pc.[ProductCategoryID] = p.[ProductCategoryID]
  ) AS pc;

--Create a stored procedure that retrieves Products along with their total sales within a date range, provided as parameters
CREATE PROCEDURE GetProductSales @StartDate DATETIME, 
@EndDate DATETIME AS BEGIN 
SELECT 
  p.[ProductID], 
  p.[Name], 
  SUM(s.[OrderQty]) AS TotalSales 
FROM 
  [SalesLT].[Product] p 
  JOIN [SalesLT].[SalesOrderDetail] s ON p.[ProductID] = s.[ProductID] 
  JOIN [SalesLT].[SalesOrderHeader] h ON s.[SalesOrderID] = h.[SalesOrderID] 
WHERE 
  h.[OrderDate] BETWEEN @StartDate 
  AND @EndDate 
GROUP BY 
  p.[ProductID], 
  p.[Name];
END;

--How do you retrieve the top 5 highest ListPrice Products within each ProductCategory
SELECT 
  [ProductCategoryID], 
  [ProductID], 
  [Name], 
  [ListPrice] 
FROM 
  (
    SELECT 
      [ProductCategoryID], 
      [ProductID], 
      [Name], 
      [ListPrice], 
      ROW_NUMBER() OVER (
        PARTITION BY [ProductCategoryID] 
        ORDER BY 
          [ListPrice] DESC
      ) AS Rank 
    FROM 
      [SalesLT].[Product]
  ) AS ranked 
WHERE 
  Rank <= 5;

--Find all Products that do not have a corresponding entry in the SalesOrderDetail table
SELECT 
  p.[ProductID], 
  p.[Name] 
FROM 
  [SalesLT].[Product] p 
  LEFT JOIN [SalesLT].[SalesOrderDetail] s ON p.[ProductID] = s.[ProductID] 
WHERE 
  s.[ProductID] IS NULL;

--Calculate the total sales and total quantity sold for each Product in a single query
SELECT 
  p.[ProductID], 
  p.[Name], 
  SUM(s.[OrderQty]) AS TotalQuantity, 
  SUM(s.[OrderQty] * s.[UnitPrice]) AS TotalSales 
FROM 
  [SalesLT].[Product] p 
  JOIN [SalesLT].[SalesOrderDetail] s ON p.[ProductID] = s.[ProductID] 
GROUP BY 
  p.[ProductID], 
  p.[Name];

--Use the CASE statement to categorize Products into 'High Price', 'Medium Price', and 'Low Price' based on ListPrice
SELECT 
  [ProductID], 
  [Name], 
  [ListPrice], 
  CASE WHEN [ListPrice] > 1000 THEN 'High Price' WHEN [ListPrice] BETWEEN 500 
  AND 1000 THEN 'Medium Price' ELSE 'Low Price' END AS PriceCategory 
FROM 
  [SalesLT].[Product];

--Create a function that returns the full name of a Customer by combining FirstName and LastName
CREATE FUNCTION dbo.GetFullName (@CustomerID INT) RETURNS NVARCHAR(100) AS BEGIN DECLARE @FullName NVARCHAR(100);
SELECT 
  @FullName = [FirstName] + ' ' + [LastName] 
FROM 
  [SalesLT].[Customer] 
WHERE 
  [CustomerID] = @CustomerID;
RETURN @FullName;
END;

--Use the EXCEPT operator to find Customers who have addresses but no orders
SELECT 
  [CustomerID], 
  [FirstName], 
  [LastName] 
FROM 
  [SalesLT].[Customer] 
WHERE 
  [CustomerID] IN (
    SELECT 
      [CustomerID] 
    FROM 
      [SalesLT].[CustomerAddress] 
    EXCEPT 
    SELECT 
      [CustomerID] 
    FROM 
      [SalesLT].[SalesOrderHeader]
  );

--Find the top-selling Product in each ProductCategory
SELECT 
  pc.[ProductCategoryID], 
  pc.[Name] AS CategoryName, 
  p.[ProductID], 
  p.[Name] AS ProductName, 
  SUM(s.[OrderQty]) AS TotalSales 
FROM 
  [SalesLT].[ProductCategory] pc 
  JOIN [SalesLT].[Product] p ON pc.[ProductCategoryID] = p.[ProductCategoryID] 
  JOIN [SalesLT].[SalesOrderDetail] s ON p.[ProductID] = s.[ProductID] 
GROUP BY 
  pc.[ProductCategoryID], 
  pc.[Name], 
  p.[ProductID], 
  p.[Name] 
ORDER BY 
  pc.[ProductCategoryID], 
  TotalSales DESC;

--Identify Customers who have not placed any orders
SELECT 
  c.[CustomerID], 
  c.[FirstName], 
  c.[LastName] 
FROM 
  [SalesLT].[Customer] c 
  LEFT JOIN [SalesLT].[SalesOrderHeader] o ON c.[CustomerID] = o.[CustomerID] 
WHERE 
  o.[CustomerID] IS NULL;

--Find the Product with the highest ListPrice and the number of units sold for that Product

SELECT TOP 1 p.[ProductID], p.[Name], p.[ListPrice], SUM(s.[OrderQty]) AS TotalUnitsSold
FROM [SalesLT].[Product] p
JOIN [SalesLT].[SalesOrderDetail] s ON p.[ProductID] = s.[ProductID]
GROUP BY p.[ProductID], p.[Name], p.[ListPrice]
ORDER BY p.[ListPrice] DESC;

--Calculate the average ListPrice of Products in each ProductCategory

SELECT pc.[ProductCategoryID], pc.[Name] AS CategoryName, AVG(p.[ListPrice]) AS AveragePrice
FROM [SalesLT].[ProductCategory] pc
JOIN [SalesLT].[Product] p ON pc.[ProductCategoryID] = p.[ProductCategoryID]
GROUP BY pc.[ProductCategoryID], pc.[Name];

--Create an index on the SalesOrderDetail table to improve query performance on the OrderQty column

CREATE NONCLUSTERED INDEX idx_SalesOrderDetail_OrderQty
ON [SalesLT].[SalesOrderDetail] ([OrderQty]);

--Retrieve the total number of orders and the total quantity ordered for each Customer

SELECT c.[CustomerID], c.[FirstName], c.[LastName],
       COUNT(o.[SalesOrderID]) AS TotalOrders,
       SUM(s.[OrderQty]) AS TotalQuantityOrdered
FROM [SalesLT].[Customer] c
JOIN [SalesLT].[SalesOrderHeader] o ON c.[CustomerID] = o.[CustomerID]
JOIN [SalesLT].[SalesOrderDetail] s ON o.[SalesOrderID] = s.[SalesOrderID]
GROUP BY c.[CustomerID], c.[FirstName], c.[LastName];

--Find Products that have been ordered more than a specified threshold quantity

DECLARE @Threshold INT = 100;

SELECT p.[ProductID], p.[Name], SUM(s.[OrderQty]) AS TotalQuantityOrdered
FROM [SalesLT].[Product] p
JOIN [SalesLT].[SalesOrderDetail] s ON p.[ProductID] = s.[ProductID]
GROUP BY p.[ProductID], p.[Name]
HAVING SUM(s.[OrderQty]) > @Threshold;

--Determine the highest sales amount per month for the current year

SELECT YEAR(h.[OrderDate]) AS SalesYear, MONTH(h.[OrderDate]) AS SalesMonth,
       SUM(s.[OrderQty] * s.[UnitPrice]) AS TotalSales
FROM [SalesLT].[SalesOrderHeader] h
JOIN [SalesLT].[SalesOrderDetail] s ON h.[SalesOrderID] = s.[SalesOrderID]
WHERE YEAR(h.[OrderDate]) = YEAR(GETDATE())
GROUP BY YEAR(h.[OrderDate]), MONTH(h.[OrderDate])
ORDER BY SalesMonth;

--Generate a report showing the top 10 Products with the highest total sales amount

SELECT TOP 10 p.[ProductID], p.[Name], SUM(s.[OrderQty] * s.[UnitPrice]) AS TotalSales
FROM [SalesLT].[Product] p
JOIN [SalesLT].[SalesOrderDetail] s ON p.[ProductID] = s.[ProductID]
GROUP BY p.[ProductID], p.[Name]
ORDER BY TotalSales DESC;
