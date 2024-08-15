--*************************************************************************--
-- Title: Assignment07
-- Author: gparker
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2017-01-01,gparker,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_gparker')
	 Begin 
	  Alter Database [Assignment07DB_gparker] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_gparker;
	 End
	Create Database Assignment07DB_gparker;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_gparker;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

/*
SELECT
	vProducts.ProductName,
	UnitPrice = FORMAT(vProducts.UnitPrice, 'C', 'en-us')
FROM
	vProducts
ORDER BY 1;
go
*/
SELECT
	P.ProductName,
	UnitPrice = FORMAT(P.UnitPrice, 'C', 'en-us')
FROM
	vProducts AS P -- Added alias to clean up
ORDER BY 1;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

/* -- Check the tables
SELECT * FROM vProducts
SELECT * FROM vCategories
GO
*/

SELECT
    C.CategoryName,
	P.ProductName,
	UnitPrice = FORMAT(P.UnitPrice, 'C', 'en-us') -- format the currency
FROM
	vProducts AS P 
	INNER JOIN
	vCategories AS C ON C.CategoryID = P.CategoryID -- Added alias to clean up
ORDER BY 1,2,3; -- Order by Cat/Prod/Price
GO

go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

/* -- Check the tables
SELECT * FROM vProducts
SELECT * FROM vInventories
GO


SELECT
	vProducts.ProductName,
	[Inventory Date] = DATENAME(MM, vInventories.InventoryDate) + ',' + DATENAME(YY, vInventories.InventoryDate), -- format the date column
	[Inventory Count] = vInventories.Count -- inventory count using count function
FROM
	vProducts 
	INNER JOIN
	vInventories ON vProducts.ProductID = vInventories.ProductID; -- join the tables

*/

SELECT
	P.ProductName,
	[Inventory Date] = DATENAME(MM, I.InventoryDate) + ',' + DATENAME(YY, I.InventoryDate), 
	[Inventory Count] = I.Count
FROM
	vProducts AS P -- added alias to clean up code
	INNER JOIN
	vInventories AS I ON P.ProductID = I.ProductID -- added alias to clean up code
ORDER BY 1, CAST([InventoryDate] AS DATE), 3; -- Order by not working, needed to update the ORDER BY using CAST
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

/*
SELECT * FROM vProducts


DROP VIEW vProductInventories; -- had to change the order, removed the view and then added it back in after the change
*/

CREATE VIEW vProductInventories
	AS
SELECT TOP 10000 -- below code is from question 3
	P.ProductName,
	[Inventory Date] = DATENAME(MM, I.InventoryDate) + ',' + DATENAME(YY, I.InventoryDate), 
	[Inventory Count] = I.COUNT
FROM
	vProducts AS P
	INNER JOIN
	vInventories AS I ON P.ProductID = I.ProductID
ORDER BY 1, CAST([InventoryDate] AS DATE), 3;
GO

-- Check that it works: Select * From vProductInventories;


-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

/*
SELECT * FROM vProducts
SELECT * FROM vInventories
SELECT * FROM vCategories

DROP VIEW vCategoryInventories; -- had to fix the view
*/

CREATE VIEW vCategoryInventories
	AS
SELECT TOP 10000 
	C.CategoryName,
	[Inventory Date] = DATENAME(MM, I.InventoryDate) + ',' + DATENAME(YY, I.InventoryDate), 
	[Inventory Count] = SUM(I.COUNT) -- Have to add up all the counts
FROM
	vProducts AS P -- added alias
	INNER JOIN
	vInventories AS I ON P.ProductID = I.ProductID -- added alias/joined table
	INNER JOIN
	vCategories AS C ON C.CategoryID = P.CategoryID -- added alias/joined table
GROUP BY C.CategoryName, [InventoryDate]
ORDER BY [CategoryName], CAST([InventoryDate] AS DATE);
GO


go
-- Check that it works: Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

/*
SELECT * FROM vProductInventories
SELECT * FROM vProductInventoriesWithPreviouMonthCounts
DROP VIEW vProductInventoriesWithPreviousMonthCounts; -- had to fix the view
*/



CREATE VIEW vProductInventoriesWithPreviousMonthCounts
	AS
SELECT TOP 100000
	ProductName,
	[Inventory Date], -- can use these since using the vProductInventories view
	[Inventory Count],
	[Previous Month Count] = CASE -- used CASE instead of IIF, IIF kept giving syntax errors, creating a CASE to eval the data then update nulls 
		WHEN [Inventory Date] LIKE 'January%' THEN 0
		ELSE ISNULL(LAG([Inventory Count]) OVER (ORDER BY ProductName, YEAR([Inventory Date])), 0)
		END -- have to end a case
FROM vProductInventories
ORDER BY 1, CAST([Inventory Date] AS DATE);
GO

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
	AS
SELECT TOP 100000
	ProductName,
	[Inventory Date],
	[Inventory Count],
	[Previous Month Count],
	[CountVsLastMonth KPI] = ISNULL(CASE -- create the KPI column using ISNULL to detect the null cells and replace them with info based on the WHEN statements below
		WHEN [Inventory Count] = [Previous Month Count] THEN 0 -- criteria for the same
		WHEN [Inventory Count] > [Previous Month Count] THEN 1 -- criteria for the increased count
		WHEN [Inventory Count] < [Previous Month Count] THEN -1 -- criteria for the decreased count
		END, 0) -- end the case
FROM vProductInventoriesWithPreviousMonthCounts	
ORDER BY 1, CAST([Inventory Date] AS DATE), 3;
GO

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs (@KPIValue int) -- create the function and creating KPI value as the criteria
	RETURNS TABLE -- returns table
		AS
	RETURN SELECT 
		ProductName, --same as prior questions
		[Inventory Date],
		[Inventory Count],
		[Previous Month Count],
		[CountVsLastMonth KPI]
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
	WHERE [CountVsLastMonth KPI] = @KPIValue -- linking up the criteria
GO

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/