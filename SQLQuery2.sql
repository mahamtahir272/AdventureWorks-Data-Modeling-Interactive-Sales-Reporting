select * from [AdventureWorks2022].Sales.SalesOrderHeader;
select * from [AdventureWorks2022].Sales.SalesOrderDetail;

select *
from [AdventureWorks2022].Purchasing.PurchaseOrderDetail

select *
from [AdventureWorks2022].Purchasing.PurchaseOrderHeader

SELECT SalesOrderID,ProductID, COUNT(0) 
FROM [AdventureWorks2022].Sales.SalesOrderDetail
GROUP BY SalesOrderID,ProductID
HAVING COUNT(0) > 1;

=========================================================================================
CREATE PROCEDURE dbo.SALE
AS

;with noofids as(
select SalesOrderID,count(*) as counts from [AdventureWorks2022].Sales.SalesOrderDetail
group by SalesOrderID
)
select [sales_key],
od.[ProductID],
od.[SalesOrderID],
	[OrderQty],
[UnitPrice],
	[UnitPriceDiscount],
	[LineTotal] 
,(TaxAmt/counts) as TaxAmt,
(Freight/counts) as Freight,
(LineTotal+(TaxAmt/noi.counts)+(Freight/noi.counts)) as TotalDue
    INTO #temp

from [AdventureWorks2022].Sales.SalesOrderHeader as hd
join [AdventureWorks2022].Sales.SalesOrderDetail as od
on hd.SalesOrderID=od.SalesOrderID
join noofids as noi
on noi.SalesOrderID=hd.SalesOrderID
join [AdventureWorks2022].dbo.Dim_Sales as ds
on ds.SalesOrderID=hd.SalesOrderID

    MERGE INTO [AdventureWorks2022].dbo.factsale AS TARGET
        USING #temp temp1
on TARGET.[ProductID]=temp1.ProductID
and TARGET.[SalesOrderID]=temp1.[SalesOrderID]

    WHEN MATCHED THEN
        UPDATE SET
        target.ProductID=temp1.ProductID,
         TARGET.UnitPrice = temp1.UnitPrice,
            TARGET.UnitPriceDiscount = temp1.UnitPriceDiscount,
            TARGET.OrderQty = temp1.OrderQty,
            TARGET.TaxAmt = temp1.TaxAmt,
            TARGET.Freight = temp1.Freight,
            target.TotalDue=temp1.TotalDue,
            target.[sales_key]=temp1.[sales_key]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
[sales_key],
[ProductID],
[SalesOrderID],
	[OrderQty],
[UnitPrice],
	[UnitPriceDiscount],
    [TaxAmt],
    [Freight],
    [TotalDue]
    )
        VALUES (
          
[sales_key],
[ProductID],
[SalesOrderID],
	[OrderQty],
[UnitPrice],
	[UnitPriceDiscount],
    [TaxAmt],
    [Freight],
    [TotalDue]
        );
exec dbo.SALE ;

select fs.SalesOrderID,fs.ProductID,OrderQty,UnitPrice,TotalDue,fs.sales_key,OrderDate,DueDate,AccountNumber from [AdventureWorks2022].dbo.factsale as fs
join [AdventureWorks2022].dbo.Dim_Sales as ds
on ds.sales_key=fs.sales_key
where fs.SalesOrderID=43659
group by fs.SalesOrderID,fs.ProductID,OrderQty,UnitPrice,TotalDue,fs.sales_key,OrderDate,DueDate,AccountNumber
================================================================================================
==========================================================================================
create procedure dbo.sales_orders
AS
select * into #temp 
from
(
select [SalesOrderID] ,
[OrderDate],
	[DueDate],
	[AccountNumber],
	[PurchaseOrderNumber],
		[ModifiedDate]
from [AdventureWorks2022].Sales.SalesOrderHeader as hd
) as temp
DECLARE @TargetRows INT;
SET @TargetRows = @@ROWCOUNT;

MERGE INTO [AdventureWorks2022].dbo.[DimSales] AS TARGET
USING #temp temp
	ON  target.[SalesOrderID] = temp.[SalesOrderID]

WHEN MATCHED THEN UPDATE
SET
target.[SalesOrderID] =temp.[SalesOrderID],
target.[OrderDate]=temp.[OrderDate],
target.[DueDate]=temp.[DueDate],
target.[AccountNumber]=temp.[AccountNumber],
target.[PurchaseOrderNumber]=temp.[PurchaseOrderNumber],
target.[ModifiedDate]=temp.[ModifiedDate]

WHEN NOT MATCHED BY TARGET THEN
INSERT
( [SalesOrderID] ,
[OrderDate],
	[DueDate],
	[AccountNumber],
	[PurchaseOrderNumber],
		[ModifiedDate]
	
)

VALUES
(
 [SalesOrderID] ,
[OrderDate],
	[DueDate],
	[AccountNumber],
	[PurchaseOrderNumber],
		[ModifiedDate]
);
exec dbo.DimOrders;

select * from [AdventureWorks2022].dbo.[DimSales]
select * from [AdventureWorks2022].Sales.SalesOrderHeader;
select * from [AdventureWorks2022].Sales.SalesOrderDetail;
====================================================================================
