USE [AdventureWorks2022]
GO
CREATE VIEW dbo.[V_CreditCard]
AS
SELECT [CreditCardKey]
      ,[CreditCardID]
      ,[CardType]
      ,[CardNumber]
      ,[ExpMonth]
      ,[ExpYear]
  FROM [AdventureWorks2022].[dbo].[DimCreditCard];

=================================================================================
USE [AdventureWorks2022]
GO
CREATE VIEW dbo.[V_Customer] AS
SELECT [CustomerKey]
      ,[CustomerID]
      ,[AccountNumber]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
  FROM [AdventureWorks2022].[dbo].[DimCustomer]
;
==================================================================================
USE [AdventureWorks2022]
GO
CREATE VIEW dbo.[V_Employee] AS
SELECT [EmployeeKey]
      ,[EmployeeID]
      ,[FirstName]
      ,[MiddleName]
      ,[LastName]
      ,[NationalIDNumber]
      ,[LoginID]
      ,[JobTitle]
      ,[BirthDate]
      ,[MaritalStatus]
      ,[Gender]
      ,[HireDate]
      ,[SalariedFlag]
      ,[VacationHours]
      ,[SickLeaveHours]
      ,[CurrentFlag]
  FROM [AdventureWorks2022].[dbo].[DimEmployee];
  =================================================================================
  USE [AdventureWorks2022]
GO
CREATE VIEW dbo.[V_PurchaseOrder] AS
SELECT [PurchaseKey]
      ,[PurchaseOrderID]
      ,[OrderDate]
      ,[ShipDate]
  FROM [AdventureWorks2022].[dbo].[DimPurchase];
  =================================================================================
USE [AdventureWorks2022]
GO
CREATE VIEW 
dbo.[V_SalesOrder] AS
     SELECT [SalesKey]
      ,[SalesOrderID]
      ,[OrderDate]
      ,[DueDate]
      ,[SalesOrderNumber]
  FROM [AdventureWorks2022].[dbo].[DimSales];
  =====================================================================================
USE [AdventureWorks2022]
GO
CREATE VIEW 
dbo.[V_Ship] AS
     SELECT [ShipKey]
      ,[ShipMethodID]
      ,[Name]
      ,[ShipBase]
      ,[ShipRate]
  FROM [AdventureWorks2022].[dbo].[DimShip];
  ======================================================================================
USE [AdventureWorks2022]
GO
CREATE VIEW 
dbo.[V_Territory] AS
    SELECT [TerritoryKey]
      ,[TerritoryID]
      ,[Name]
      ,[CountryRegionCode]
      ,[Group]
      ,[SalesYTD]
      ,[SalesLastYear]
      ,[CostYTD]
      ,[CostLastYear]
  FROM [AdventureWorks2022].[dbo].[DimTerritory];
  ==================================================================================
  USE [AdventureWorks2022]
GO
CREATE VIEW 
dbo.[V_Vendor] AS
    SELECT[VendorKey]
      ,[VendorID]
      ,[AccountNumber]
      ,[Name]
      ,[CreditRating]
      ,[PreferredVendorStatus]
      ,[ActiveFlag]
      ,[PurchasingWebServiceURL]
  FROM [AdventureWorks2022].[dbo].[DimVendor]
;
=====================================================================================
 USE [AdventureWorks2022]
GO
CREATE VIEW 
dbo.[V_FactPurchase] AS
   SELECT [EmployeeKey]
      ,[VendorKey]
      ,[ShipKey]
      ,[PurchaseKey]
      ,[PurchaseOrderID]
      ,[ProductID]
      ,[PurchaseOrderDetailID]
      ,[OrderQty]
      ,[UnitPrice]
      ,[LineTotal]
      ,[ReceivedQty]
      ,[RejectedQty]
      ,[StockedQty]
      ,[TaxAmt]
      ,[Freight]
      ,[TotalDue]
  FROM [AdventureWorks2022].[dbo].[FactPurchase]
;
====================================================================================
 USE [AdventureWorks2022]
GO
CREATE VIEW 
dbo.[V_FactSale] AS
   SELECT [SalesKey]
      ,[CustomerKey]
      ,[ShipKey]
      ,[CreditCardKey]
      ,[TerritoryKey]
      ,[ProductID]
      ,[SalesOrderDetailID]
      ,[SalesOrderID]
       ,[OrderQty]
      ,[UnitPrice]
      ,[UnitPriceDiscount]
      ,[LineTotal]
       ,[TaxAmt]
      ,[Freight]
      ,[TotalDue]
  FROM [AdventureWorks2022].[dbo].[FactSale]
;