select * from [AdventureWorks2022].Sales.SalesOrderHeader
where SalesOrderID='43659';
select sum(TotalDue) from [AdventureWorks2022].dbo.factsale
where SalesOrderID='43659';


CREATE TABLE [AdventureWorks2022].dbo.Dim_Sales(
[SalesKey] [int] IDENTITY(1,1) NOT NULL,
[SalesOrderID] [int] NOT NULL,
[OrderDate] [datetime] NOT NULL,
	[DueDate] [datetime] NOT NULL,
	[SalesOrderNumber]  AS (isnull(N'SO'+CONVERT([nvarchar](23),[SalesOrderID]),N'*** ERROR ***')),
	[PurchaseOrderNumber] [dbo].[OrderNumber] NULL,
	[AccountNumber] [dbo].[AccountNumber] NULL,
		[ModifiedDate] [datetime] NOT NULL,
);

CREATE TABLE dbo.[DimEmployee](
[EmployeeKey] [int] IDENTITY(1,1) NOT NULL,
	[EmployeeID] [int] NOT NULL,
	[FirstName] [dbo].[Name] NOT NULL,
	[MiddleName] [dbo].[Name] NULL,
	[LastName] [dbo].[Name] NOT NULL,
	[NationalIDNumber] [nvarchar](15) NOT NULL,
	[LoginID] [nvarchar](256) NOT NULL,
	[OrganizationNode] [hierarchyid] NULL,
	[OrganizationLevel]  AS ([OrganizationNode].[GetLevel]()),
	[JobTitle] [nvarchar](50) NOT NULL,
	[BirthDate] [date] NOT NULL,
	[MaritalStatus] [nchar](1) NOT NULL,
	[Gender] [nchar](1) NOT NULL,
	[HireDate] [date] NOT NULL,
	[SalariedFlag] [dbo].[Flag] NOT NULL,
	[VacationHours] [smallint] NOT NULL,
	[SickLeaveHours] [smallint] NOT NULL,
	[CurrentFlag] [dbo].[Flag] NOT NULL
	);

CREATE TABLE [AdventureWorks2022].dbo.factsale
(
[SalesKey] [int]  not NULL,
[CustomerKey] [int]  NULL,
[ShipKey] [int]  NULL,
[CreditCardKey] [int] not NULL,
	[TerritoryKey] [int] NOT NULL,
[ProductID] [int] NOT NULL,
[SalesOrderDetailID] [int] NOT NULL,
	[TaxAmt] [money] NOT NULL,
	[Freight] [money] NOT NULL,
[SalesOrderID] [int] NOT NULL,
	[OrderQty] [smallint] NOT NULL,
[UnitPrice] [money] NOT NULL,
	[UnitPriceDiscount] [money] NOT NULL,
	[LineTotal]  AS (isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))),
	TotalDue [int]  null
);
CREATE TABLE  [AdventureWorks2022].dbo.[DimCustomer](
[CustomerKey] [int] IDENTITY(1,1) NOT NULL,
	[CustomerID] [int] NOT NULL,
	[AccountNumber] [dbo].[AccountNumber] NULL,
	[FirstName] [dbo].[Name] NOT NULL,
	[MiddleName] [dbo].[Name] NULL,
	[LastName] [dbo].[Name] NOT NULL
);

CREATE TABLE [AdventureWorks2022].dbo.[DimShip](
 [ShipKey] [int] IDENTITY(1,1) NOT NULL,
 [ShipMethodID] [int] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[ShipBase] [money] NOT NULL,
	[ShipRate] [money] NOT NULL,
		[ModifiedDate] [datetime] NOT NULL,

);
CREATE TABLE [AdventureWorks2022].dbo.[DimCreditCard] (
[CreditCardKey] [int] IDENTITY(1,1) NOT NULL,
[CreditCardID] [int]  NOT NULL,
	[CardType] [nvarchar](50) NOT NULL,
	[CardNumber] [nvarchar](25) NOT NULL,
	[ExpMonth] [tinyint] NOT NULL,
	[ExpYear] [smallint] NOT NULL);

CREATE TABLE [AdventureWorks2022].dbo.[DimTerritory](
	[TerritoryKey] [int] IDENTITY(1,1) NOT NULL,
	[TerritoryID] [int] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[CountryRegionCode] [nvarchar](3) NOT NULL,
	[Group] [nvarchar](50) NOT NULL,
	[SalesYTD] [money] NOT NULL,
	[SalesLastYear] [money] NOT NULL,
	[CostYTD] [money] NOT NULL,
	[CostLastYear] [money] NOT NULL);


CREATE TABLE [AdventureWorks2022].dbo.[DimVendor](
	[VendorKey] [int] IDENTITY(1,1) NOT NULL,
	[VendorID] [int] NOT NULL,
	[AccountNumber] [dbo].[AccountNumber] NOT NULL,
	[Name] [dbo].[Name] NOT NULL,
	[CreditRating] [tinyint] NOT NULL,
	[PreferredVendorStatus] [dbo].[Flag] NOT NULL,
	[ActiveFlag] [dbo].[Flag] NOT NULL,
	[PurchasingWebServiceURL] [nvarchar](1024) NULL 
	);
CREATE TABLE [AdventureWorks2022].dbo.[DimPurchase](
[PurchaseKey] [int] IDENTITY(1,1) NOT NULL,
	[PurchaseOrderID] [int] NOT NULL,
		[OrderDate] [datetime] NOT NULL,
	[ShipDate] [datetime] NULL);

CREATE TABLE [AdventureWorks2022].dbo.[FactPurchase](
 [EmployeeKey] [int] NOT NULL,
      [VendorKey] [int] NOT NULL,
      [ShipKey] [int] NOT NULL,
	   [PurchaseKey] [int] NOT NULL,
	[PurchaseOrderID] [int] NOT NULL,
		[ProductID] [int] NOT NULL,
		[PurchaseOrderDetailID] [int] NOT NULL,
[OrderQty] [smallint] NOT NULL,
	[UnitPrice] [money] NOT NULL,
	[LineTotal]  AS (isnull([OrderQty]*[UnitPrice],(0.00))),
	[ReceivedQty] [decimal](8, 2) NOT NULL,
	[RejectedQty] [decimal](8, 2) NOT NULL,
	[StockedQty]  AS (isnull([ReceivedQty]-[RejectedQty],(0.00))),
	[TaxAmt] [money] NOT NULL,
	[Freight] [money] NOT NULL,
	[TotalDue] [int] NOT NULL);


select [CustomerID],[AccountNumber],[PurchaseOrderNumber],OrderDate,ModifiedDate,count(0)
from [AdventureWorks2022].Sales.SalesOrderHeader
where [PurchaseOrderNumber] is not null
group by [CustomerID],[AccountNumber],[PurchaseOrderNumber]
having count(0)>1


select 
hd.[SalesOrderID] ,count(*) as num
into no_of_ids
from  [AdventureWorks2022].Sales.SalesOrderHeader as hd
join  [AdventureWorks2022].Sales.SalesOrderDetail as od
on od.[SalesOrderID]=hd.[SalesOrderID]
group by 
hd.[SalesOrderID]


select hd.[SalesOrderID],UnitPrice,UnitPriceDiscount,(isnull(([UnitPrice]*((1.0)-[UnitPriceDiscount]))*[OrderQty],(0.0))) as [LineTotal],([TaxAmt]/t.num) as Tax_Amt,(Freight/num) as Freight,(isnull(([LineTotal]+([TaxAmt]/t.num))+(Freight/num),(0))) as 	[TotalDue] 
from [AdventureWorks2022].Sales.SalesOrderHeader as hd
join  [AdventureWorks2022].Sales.SalesOrderDetail as od
on od.[SalesOrderID]=hd.[SalesOrderID]
join no_of_ids as t
 on t.SalesOrderID=hd.SalesOrderID
 where hd.SalesOrderID='51176';
 
 select * from [AdventureWorks2022].Sales.SalesOrderHeader
where SalesOrderID='51176';

select [SalesOrderID] from
no_of_ids
where num=2

SELECT * from [AdventureWorks2022].dbo.factsale;
SELECT * from [AdventureWorks2022].dbo.DimShip;
SELECT * from [AdventureWorks2022].dbo.DimCustomer;
SELECT * from [AdventureWorks2022].dbo.DimSales;
SELECT * from [AdventureWorks2022].dbo.DimCreditCard;


select * from [AdventureWorks2022].dbo.DimCustomer
where PurchaseOrderNumber is not null
order by CustomerID



