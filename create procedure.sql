select * from [AdventureWorks2022].Sales.SalesOrderHeader;
select * from [AdventureWorks2022].Sales.SalesOrderDetail;

select *
from [AdventureWorks2022].Purchasing.PurchaseOrderDetail

select *
from [AdventureWorks2022].Purchasing.PurchaseOrderHeader

select * from [AdventureWorks2022].dbo.DimSalesPerson
=======================================================================
CREATE PROCEDURE dbo.SP_FactSale
AS
;with noofids as(
select SalesOrderID,count(*) as counts from [AdventureWorks2022].Sales.SalesOrderDetail
group by SalesOrderID
)
select [SalesKey],
[CustomerKey],
[ShipKey],
[CreditCardKey],
[TerritoryKey],
od.[ProductID],
od.[SalesOrderID],
od.SalesOrderDetailID,
	[OrderQty],
[UnitPrice],
	[UnitPriceDiscount],
	[LineTotal] 
,(TaxAmt/counts) as TaxAmt,
(Freight/counts) as Freight,
(LineTotal+(TaxAmt/noi.counts)+(Freight/noi.counts)) as TotalDue
    INTO #temp
from [AdventureWorks2022].Sales.SalesOrderDetail as od
join [AdventureWorks2022].Sales.SalesOrderHeader as hd
on hd.SalesOrderID=od.SalesOrderID
join noofids as noi
on noi.SalesOrderID=hd.SalesOrderID
join [AdventureWorks2022].dbo.DimSales as ds
on ds.SalesOrderID=hd.SalesOrderID
join [AdventureWorks2022].dbo.DimCustomer as cc
on cc.CustomerID=hd.CustomerID 
join [AdventureWorks2022].dbo.DimShip as s
on hd.[ShipMethodID]=s.[ShipMethodID]
join [AdventureWorks2022].dbo.DimCreditCard as c
on c.CreditCardID=hd.CreditCardID
join [AdventureWorks2022].dbo.DimTerritory as t
on t.[TerritoryID]=hd.[TerritoryID]
    MERGE INTO [AdventureWorks2022].dbo.factsale AS TARGET
        USING #temp temp1
on TARGET.[ProductID]=temp1.ProductID
and target.[SalesOrderID]=temp1.[SalesOrderID]
and target.SalesOrderDetailID=temp1.SalesOrderDetailID
    WHEN MATCHED THEN
        UPDATE SET
 target.[SalesOrderID]=temp1.[SalesOrderID],
 target.SalesOrderDetailID=temp1.SalesOrderDetailID,
        target.ProductID=temp1.ProductID,
         TARGET.UnitPrice = temp1.UnitPrice,
            TARGET.UnitPriceDiscount = temp1.UnitPriceDiscount,
            TARGET.OrderQty = temp1.OrderQty,
            TARGET.TaxAmt = temp1.TaxAmt,
            TARGET.Freight = temp1.Freight,
            target.TotalDue=temp1.TotalDue,
            target.[SalesKey]=temp1.[SalesKey],
             target.[CustomerKey]=temp1.[CustomerKey],
             target.[ShipKey]=temp1.[ShipKey],
             target.[CreditCardKey]=temp1.[CreditCardKey],
			 target.[TerritoryKey]=temp1.[TerritoryKey]
			 WHEN NOT MATCHED BY TARGET THEN
        INSERT (
[SalesKey],
[CustomerKey],
[ShipKey],
[CreditCardKey],
[TerritoryKey],
[ProductID],
[SalesOrderID],
[SalesOrderDetailID],
	[OrderQty],
[UnitPrice],
	[UnitPriceDiscount],
    [TaxAmt],
    [Freight],
    [TotalDue]
    )
        VALUES (
         
[SalesKey],
[CustomerKey],
[ShipKey],
[CreditCardKey],
[TerritoryKey],
[ProductID],
[SalesOrderID],
[SalesOrderDetailID],
	[OrderQty],
[UnitPrice],
	[UnitPriceDiscount],
    [TaxAmt],
    [Freight],
    [TotalDue]
        );
exec dbo.SP_FactSale ;

select fs.SalesOrderID,fs.ProductID,OrderQty,UnitPrice,TotalDue,fs.sales_key,OrderDate,DueDate,AccountNumber from [AdventureWorks2022].dbo.factsale as fs
join [AdventureWorks2022].dbo.Dim_Sales as ds
on ds.sales_key=fs.sales_key
where fs.SalesOrderID=43659
group by fs.SalesOrderID,fs.ProductID,OrderQty,UnitPrice,TotalDue,fs.sales_key,OrderDate,DueDate,AccountNumber
================================================================================
CREATE PROCEDURE dbo.SP_Customer
AS
select * into #temp 
from
(
select [CustomerID] 
,[FirstName] 
	,[MiddleName] 
	,[LastName] 
	,[AccountNumber]
from [AdventureWorks2022].Sales.Customer as hd
join [AdventureWorks2022].Person.Person as p
on p.BusinessEntityID=hd.[CustomerID]
) as temp
DECLARE @TargetRows INT;
SET @TargetRows = @@ROWCOUNT;

MERGE INTO [AdventureWorks2022].dbo.[DimCustomer] AS TARGET
USING #temp temp1
	ON  target.[CustomerID]=temp1.[CustomerID]
WHEN MATCHED THEN UPDATE
SET
target.[CustomerID] =temp1.[CustomerID],
target.[AccountNumber]=temp1.[AccountNumber],
target.[FirstName]=temp1.[FirstName],
target.[MiddleName]=temp1.[MiddleName],
target.[LastName]=temp1.[LastName]

WHEN NOT MATCHED BY TARGET THEN
INSERT
( [CustomerID] 
,[FirstName] 
	,[MiddleName] 
	,[LastName] 
	,[AccountNumber]
	
)

VALUES
(
 [CustomerID] 
 ,[FirstName] 
	,[MiddleName] 
	,[LastName] 
	,[AccountNumber]
);

exec dbo.SP_Customer;
==========================================================================
CREATE PROCEDURE dbo.SP_Ship
AS
select * into #temp 
from
(
select [ShipMethodID]
      ,[Name]
      ,[ShipBase]
      ,[ShipRate]
      ,[ModifiedDate]
  FROM [AdventureWorks2022].[Purchasing].[ShipMethod]
) as temp
DECLARE @TargetRows INT;
SET @TargetRows = @@ROWCOUNT;

MERGE INTO [AdventureWorks2022].dbo.[DimShip] AS TARGET
USING #temp temp1
	ON  target.[ShipMethodID]=temp1.[ShipMethodID]
WHEN MATCHED THEN UPDATE
SET
target.[ShipMethodID] =temp1.[ShipMethodID],
target.[Name]=temp1.[Name],
target.[ShipBase]=temp1.[ShipBase],
target.[ModifiedDate]=temp1.[ModifiedDate],
target.[ShipRate]=temp1.[ShipRate]

WHEN NOT MATCHED BY TARGET THEN
INSERT
( [ShipMethodID]
      ,[Name]
      ,[ShipBase]
      ,[ShipRate]
      ,[ModifiedDate]
	
)

VALUES
(
[ShipMethodID]
      ,[Name]
      ,[ShipBase]
      ,[ShipRate]
      ,[ModifiedDate]
);

exec dbo.SP_Ship;
============================================================================
CREATE PROCEDURE dbo.SP_CreditCard
AS
select * into #temp 
from
(
select [CreditCardID] ,
	[CardType],
	[CardNumber],
	[ExpMonth],
	[ExpYear]
from [AdventureWorks2022].Sales.CreditCard
) as temp
DECLARE @TargetRows INT;
SET @TargetRows = @@ROWCOUNT;

MERGE INTO [AdventureWorks2022].dbo.[DimCreditCard] AS TARGET
USING #temp temp1
	ON  target.[CreditCardID]=temp1.[CreditCardID]
WHEN MATCHED THEN UPDATE
SET
target.[CreditCardID] =temp1.[CreditCardID],
target.[CardType]=temp1.[CardType],
target.[CardNumber]=temp1.[CardNumber],
target.[ExpMonth]=temp1.[ExpMonth],
target.[ExpYear]=temp1.[ExpYear]

WHEN NOT MATCHED BY TARGET THEN
INSERT
( [CreditCardID] ,
	[CardType],
	[CardNumber],
	[ExpMonth],
	[ExpYear]
	
)

VALUES
(
[CreditCardID] ,
	[CardType],
	[CardNumber],
	[ExpMonth],
	[ExpYear]
);

exec dbo.SP_CreditCard;
=================================================================================
CREATE PROCEDURE dbo.SP_Employee
AS
select * into #temp 
from
(
select [EmployeeID]
,[FirstName] 
	,[MiddleName] 
	,[LastName] 
      ,[NationalIDNumber]
      ,[LoginID]
      ,[OrganizationNode]
      ,[JobTitle]
      ,[BirthDate]
      ,[MaritalStatus]
      ,[Gender]
      ,[HireDate]
      ,[SalariedFlag]
      ,[VacationHours]
      ,[SickLeaveHours]
      ,[CurrentFlag]
from [AdventureWorks2022].HumanResources.Employee as e
join [AdventureWorks2022].[Purchasing].[PurchaseOrderHeader] as poh
on poh.EmployeeID=e.BusinessEntityID
join [AdventureWorks2022].Person.Person as p
on poh.EmployeeID=p.BusinessEntityID
group by  [EmployeeID]
,[FirstName] 
	,[MiddleName] 
	,[LastName] 
      ,[NationalIDNumber]
      ,[LoginID]
      ,[OrganizationNode]
      ,[JobTitle]
      ,[BirthDate]
      ,[MaritalStatus]
      ,[Gender]
      ,[HireDate]
      ,[SalariedFlag]
      ,[VacationHours]
      ,[SickLeaveHours]
      ,[CurrentFlag]
) as temp
DECLARE @TargetRows INT;
SET @TargetRows = @@ROWCOUNT;

MERGE INTO [AdventureWorks2022].dbo.[DimEmployee] AS TARGET
USING #temp temp1
	ON  target.[EmployeeID]=temp1.[EmployeeID]
WHEN MATCHED THEN UPDATE
SET
target.[EmployeeID] =temp1.[EmployeeID],
target.[FirstName]=temp1.[FirstName],
target.[MiddleName]=temp1.[MiddleName],
target.[LastName]=temp1.[LastName],
target.[NationalIDNumber]=temp1.[NationalIDNumber],
target.[LoginID]=temp1.[LoginID],
target.[OrganizationNode]=temp1.[OrganizationNode],
target.[JobTitle]=temp1.[JobTitle],
target.[BirthDate]=temp1.[BirthDate],
target.[MaritalStatus]=temp1.[MaritalStatus],
target.[Gender]=temp1.[Gender],
target.[HireDate]=temp1.[HireDate],
target.[SalariedFlag]=temp1.[SalariedFlag],
target.[VacationHours]=temp1.[VacationHours],
target.[SickLeaveHours]=temp1.[SickLeaveHours],
target.[CurrentFlag]=temp1.[CurrentFlag]

WHEN NOT MATCHED BY TARGET THEN
INSERT
( [EmployeeID]
,[FirstName] 
	,[MiddleName] 
	,[LastName] 
      ,[NationalIDNumber]
      ,[LoginID]
      ,[OrganizationNode]
      ,[JobTitle]
      ,[BirthDate]
      ,[MaritalStatus]
      ,[Gender]
      ,[HireDate]
      ,[SalariedFlag]
      ,[VacationHours]
      ,[SickLeaveHours]
      ,[CurrentFlag]
)

VALUES
(
 [EmployeeID]
,[FirstName] 
	,[MiddleName] 
	,[LastName] 
      ,[NationalIDNumber]
      ,[LoginID]
      ,[OrganizationNode]
      ,[JobTitle]
      ,[BirthDate]
      ,[MaritalStatus]
      ,[Gender]
      ,[HireDate]
      ,[SalariedFlag]
      ,[VacationHours]
      ,[SickLeaveHours]
      ,[CurrentFlag]
);

exec dbo.SP_Employee;
=======================================================================
CREATE PROCEDURE dbo.SP_Vendor
AS
select * into #temp 
from
(
select [VendorID],
	[AccountNumber],
	[Name],
	[CreditRating],
	[PreferredVendorStatus],
	[ActiveFlag],
	[PurchasingWebServiceURL]
from [AdventureWorks2022].[Purchasing].Vendor as v
join [AdventureWorks2022].[Purchasing].[PurchaseOrderHeader] as poh
on poh.VendorID=v.BusinessEntityID
group by  [VendorID],
	[AccountNumber],
	[Name],
	[CreditRating],
	[PreferredVendorStatus],
	[ActiveFlag],
	[PurchasingWebServiceURL]
) as temp
DECLARE @TargetRows INT;
SET @TargetRows = @@ROWCOUNT;

MERGE INTO [AdventureWorks2022].dbo.[DimVendor] AS TARGET
USING #temp temp1
	ON  target.[VendorID]=temp1.[VendorID]
WHEN MATCHED THEN UPDATE
SET
target.[VendorID]=temp1.[VendorID],
target.[AccountNumber]=temp1.[AccountNumber],
target.[Name]=temp1.[Name],
target.[CreditRating]=temp1.[CreditRating],
target.[PreferredVendorStatus]=temp1.[PreferredVendorStatus],
target.[ActiveFlag]=temp1.[ActiveFlag],
target.[PurchasingWebServiceURL]=temp1.[PurchasingWebServiceURL]

WHEN NOT MATCHED BY TARGET THEN
INSERT
( [VendorID],
	[AccountNumber],
	[Name],
	[CreditRating],
	[PreferredVendorStatus],
	[ActiveFlag],
	[PurchasingWebServiceURL]
)

VALUES
(
 temp1.[VendorID],
	temp1.[AccountNumber],
	temp1.[Name],
	temp1.[CreditRating],
	temp1.[PreferredVendorStatus],
	temp1.[ActiveFlag],
	temp1.[PurchasingWebServiceURL]
);

exec dbo.SP_Vendor;
========================================================================
CREATE PROCEDURE dbo.SP_Purchase
AS
select * into #temp 
from
(
select [PurchaseOrderID],[OrderDate],
		[ShipDate] 
from [AdventureWorks2022].[Purchasing].[PurchaseOrderHeader]

) as temp
DECLARE @TargetRows INT;
SET @TargetRows = @@ROWCOUNT;

MERGE INTO [AdventureWorks2022].dbo.[DimPurchase] AS TARGET
USING #temp temp1
	ON  target.[PurchaseOrderID]=temp1.[PurchaseOrderID]
WHEN MATCHED THEN UPDATE
SET
target.[PurchaseOrderID]=temp1.[PurchaseOrderID],
target.[OrderDate]=temp1.[OrderDate],
target.[ShipDate]=temp1.[ShipDate]

WHEN NOT MATCHED BY TARGET THEN
INSERT
( [PurchaseOrderID],
		[OrderDate] ,
	[ShipDate] 
)

VALUES
(
[PurchaseOrderID],
		[OrderDate] ,
	[ShipDate] 
);

exec dbo.SP_Purchase;
===============================================================================
CREATE PROCEDURE dbo.SP_SalesTerritory
AS
select * into #temp 
from
(
select [TerritoryID],
	[Name],
	[CountryRegionCode],
	[Group],
	[SalesYTD],
	[SalesLastYear],
	[CostYTD],
	[CostLastYear]
from [AdventureWorks2022].Sales.SalesTerritory
) as temp
DECLARE @TargetRows INT;
SET @TargetRows = @@ROWCOUNT;

MERGE INTO [AdventureWorks2022].dbo.[DimTerritory] AS TARGET
USING #temp temp1
	ON  target.[TerritoryID]=temp1.[TerritoryID]
WHEN MATCHED THEN UPDATE
SET
target.[TerritoryID] =temp1.[TerritoryID],
target.[Name]=temp1.[Name],
target.[CountryRegionCode]=temp1.[CountryRegionCode],
target.[Group]=temp1.[Group],
target.[SalesYTD]=temp1.[SalesYTD],
target.[CostYTD]=temp1.[CostYTD],
target.[CostLastYear]=temp1.[CostLastYear]

WHEN NOT MATCHED BY TARGET THEN
INSERT
( [TerritoryID],
	[Name],
	[CountryRegionCode],
	[Group],
	[SalesYTD],
	[SalesLastYear],
	[CostYTD],
	[CostLastYear]
)

VALUES
(
[TerritoryID],
	[Name],
	[CountryRegionCode],
	[Group],
	[SalesYTD],
	[SalesLastYear],
	[CostYTD],
	[CostLastYear]
);

exec dbo.SP_SalesTerritory;
===========================================================================
CREATE PROCEDURE dbo.SP_FactPurchase
AS
;with noofpurchases as(
select PurchaseOrderID,count(*) as num from [AdventureWorks2022].Purchasing.PurchaseOrderDetail
group by PurchaseOrderID
)
select [EmployeeKey],
[VendorKey],
[ShipKey],
[PurchaseKey],
od.[PurchaseOrderID],
od.[ProductID],
od.[PurchaseOrderDetailID],
	[OrderQty],
[UnitPrice],
	[LineTotal] ,
	[ReceivedQty] ,
	[RejectedQty] ,
	[StockedQty] ,
(TaxAmt/num) as TaxAmt,
(Freight/num) as Freight,
(LineTotal+(TaxAmt/nop.num)+(Freight/nop.num)) as TotalDue
    INTO #temp
from [AdventureWorks2022].Purchasing.PurchaseOrderDetail as od
join [AdventureWorks2022].Purchasing.PurchaseOrderHeader as hd
on hd.PurchaseOrderID=od.PurchaseOrderID
join noofpurchases as nop
on nop.PurchaseOrderID=hd.PurchaseOrderID
join [AdventureWorks2022].dbo.DimEmployee as e
on e.EmployeeID=hd.EmployeeID
join [AdventureWorks2022].dbo.DimVendor as v
on v.VendorID=hd.VendorID 
join [AdventureWorks2022].dbo.DimShip as s
on hd.[ShipMethodID]=s.[ShipMethodID]
join [AdventureWorks2022].dbo.DimPurchase as dp
on dp.PurchaseOrderID=hd.PurchaseOrderID

    MERGE INTO [AdventureWorks2022].dbo.FactPurchase AS TARGET
        USING #temp temp1
on TARGET.[ProductID]=temp1.ProductID
and target.[PurchaseOrderDetailID]=temp1.[PurchaseOrderDetailID]
and target.[PurchaseOrderID]=temp1.[PurchaseOrderID]
    WHEN MATCHED THEN
        UPDATE SET
        target.ProductID=temp1.ProductID,
		target.[PurchaseOrderDetailID]=temp1.[PurchaseOrderDetailID],
         TARGET.UnitPrice = temp1.UnitPrice,
            TARGET.[ReceivedQty] = temp1.[ReceivedQty],
			target.[RejectedQty]=temp1.[RejectedQty],
            TARGET.OrderQty = temp1.OrderQty,
            TARGET.TaxAmt = temp1.TaxAmt,
            TARGET.Freight = temp1.Freight,
            target.[PurchaseOrderID]=temp1.[PurchaseOrderID],
             target.[PurchaseKey]=temp1.[PurchaseKey],
             target.[ShipKey]=temp1.[ShipKey],
             target.[VendorKey]=temp1.[VendorKey],
			 target.[EmployeeKey]=temp1.[EmployeeKey],
			 target.TotalDue=temp1.TotalDue
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
[EmployeeKey],
[VendorKey],
[ShipKey],
[PurchaseKey],
[PurchaseOrderID],
[ProductID],
[PurchaseOrderDetailID],
	[OrderQty],
[UnitPrice],
	[ReceivedQty] ,
	[RejectedQty] ,
 TaxAmt,
 Freight   ,
 TotalDue)
        VALUES (
  [EmployeeKey],
[VendorKey],
[ShipKey],
[PurchaseKey],
[PurchaseOrderID],
[ProductID],
[PurchaseOrderDetailID],
	[OrderQty],
[UnitPrice],
	[ReceivedQty] ,
	[RejectedQty] ,
 Freight,
  TaxAmt	,
  TotalDue);

exec dbo.SP_FactPurchase ;

===========================================================================
CREATE PROCEDURE dbo.SP_SalesPerson
AS
select * into #temp 
from
(
select [SalesPersonID],
[FirstName],
	[MiddleName],
	[LastName],
		[PhoneNumber]
from [AdventureWorks2022].Sales.SalesOrderHeader as hd
join [AdventureWorks2022].Person.Person as p
on p.BusinessEntityID=hd.[SalesPersonID]
join [AdventureWorks2022].Person.PersonPhone as pp
on pp.BusinessEntityID=hd.[SalesPersonID]
group by [SalesPersonID],
[FirstName],
	[MiddleName],
	[LastName],
		[PhoneNumber]
) as temp
DECLARE @TargetRows INT;
SET @TargetRows = @@ROWCOUNT;

MERGE INTO [AdventureWorks2022].dbo.[DimSalesPerson] AS TARGET
USING #temp temp1
	ON  target.[SalesPersonID]=temp1.[SalesPersonID]
WHEN MATCHED THEN UPDATE
SET
target.[SalesPersonID] =temp1.[SalesPersonID],
target.[PhoneNumber]=temp1.[PhoneNumber],
target.[FirstName]=temp1.[FirstName],
target.[MiddleName]=temp1.[MiddleName],
target.[LastName]=temp1.[LastName]

WHEN NOT MATCHED BY TARGET THEN
INSERT
( [SalesPersonID],
[FirstName],
	[MiddleName],
	[LastName],
		[PhoneNumber]
	
)

VALUES
(
 [SalesPersonID],
[FirstName],
	[MiddleName],
	[LastName],
		[PhoneNumber]
);

exec dbo.SP_SalesPerson;
==============================================================================
select CustomerID,count(0)
from [AdventureWorks2022].Sales.SalesOrderHeader
where [PurchaseOrderNumber] is not null
group by CustomerID
having count(0)>1


select CustomerID,[AccountNumber],count(0)
from [AdventureWorks2022].Sales.SalesOrderHeader
group by CustomerID,[AccountNumber]
having count(0)>1

select CustomerID,[OrderDate],count(0)
from [AdventureWorks2022].Sales.SalesOrderHeader
group by CustomerID,[OrderDate]
having count(0)>1

select 
 [CustomerID] ,
	[AccountNumber],
	[PurchaseOrderNumber],
		[ModifiedDate],
        [OrderDate],count(0)
 from [AdventureWorks2022].dbo.DimCustomer
where [PurchaseOrderNumber] is not null
 group by 
 [CustomerID] ,
	[AccountNumber],
	[PurchaseOrderNumber],
		[ModifiedDate],
        [OrderDate]
having count(0)>1
select * from dbo.factsale;
select * from dbo.DimCustomer;
select * from dbo.DimCreditCard;

select [CreditCardID] ,
	[CardNumber],
	count(0)
from [AdventureWorks2022].Sales.CreditCard
group by [CreditCardID] ,
	[CardNumber]
having count(0)>1;

select [TerritoryID],
	[Name],
	[CountryRegionCode],
	[Group],
	[SalesYTD],
	[SalesLastYear],
	[CostYTD],
	[CostLastYear],count(0)
	from [AdventureWorks2022].Sales.SalesTerritory
	group by [TerritoryID],
	[Name],
	[CountryRegionCode],
	[Group],
	[SalesYTD],
	[SalesLastYear],
	[CostYTD],
	[CostLastYear]
	having count(0)>1;


	select 
[PurchaseOrderID],
		[OrderDate] ,
	count(0)
	from [AdventureWorks2022].dbo.DimPurchase
	group by 
[PurchaseOrderID],
		[OrderDate] 
	
	having count(0)>1;

	

select [VendorID],
	[AccountNumber],
	[Name],
	[CreditRating],
	[PreferredVendorStatus],
	[ActiveFlag],
	[PurchasingWebServiceURL],count(0)
from [AdventureWorks2022].dbo.DimVendor
group by  [VendorID],
	[AccountNumber],
	[Name],
	[CreditRating],
	[PreferredVendorStatus],
	[ActiveFlag],
	[PurchasingWebServiceURL]
	having count(0)>1;


	select sum(TotalDue)
    FROM [AdventureWorks2022].[dbo].[FactPurchase]
where PurchaseOrderID=12 ;

 select TotalDue
    FROM [AdventureWorks2022].Purchasing.PurchaseOrderHeader
where PurchaseOrderID=12 ;