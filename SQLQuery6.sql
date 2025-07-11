SELECT SalesOrderID, COUNT(0) 
FROM [AdventureWorks2022].Sales.SalesOrderHeader
GROUP BY SalesOrderID
HAVING COUNT(0) > 1;
==========================================================================================================
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

MERGE INTO [AdventureWorks2022].dbo.[Dim_Sales] AS TARGET
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
exec dbo.sales_orders;
=====================================================================================================
ALTER PROCEDURE dbo.SALE
AS
    ;WITH no_of_ids AS (
        SELECT 
            hd.SalesOrderID,
            COUNT(*) AS num
        FROM [AdventureWorks2022].Sales.SalesOrderHeader AS hd
        JOIN [AdventureWorks2022].Sales.SalesOrderDetail AS od
            ON od.SalesOrderID = hd.SalesOrderID
        GROUP BY hd.SalesOrderID
    )

    SELECT 
        hd.SalesOrderID,
        [sales_key],
        od.UnitPrice,
        od.UnitPriceDiscount,
        od.OrderQty,
        ISNULL((od.UnitPrice * (1.0 - od.UnitPriceDiscount)) * od.OrderQty, 0.0) AS LineTotal,
        (hd.TaxAmt / t.num) AS TaxAmt,
        (hd.Freight / t.num) AS Freight,
        ISNULL(
            ((od.UnitPrice * (1.0 - od.UnitPriceDiscount)) * od.OrderQty)
            + (hd.TaxAmt / t.num)
            + (hd.Freight / t.num), 0.0
        ) AS TotalDue
    INTO #temp
    FROM [AdventureWorks2022].Sales.SalesOrderHeader AS hd
    JOIN [AdventureWorks2022].Sales.SalesOrderDetail AS od
        ON od.SalesOrderID = hd.SalesOrderID
    JOIN no_of_ids AS t
        ON hd.SalesOrderID = t.SalesOrderID
   -- WHERE hd.SalesOrderID = @SalesOrderID;
   JOIN [AdventureWorks2022].dbo.Dim_Sales as ds
        ON hd.SalesOrderID = ds.SalesOrderID
      
    MERGE INTO [AdventureWorks2022].dbo.factsale AS TARGET
    USING #temp AS temp1
        ON TARGET.SalesOrderID = temp1.SalesOrderID

    WHEN MATCHED THEN
        UPDATE SET
            TARGET.UnitPrice = temp1.UnitPrice,
            TARGET.UnitPriceDiscount = temp1.UnitPriceDiscount,
            TARGET.OrderQty = temp1.OrderQty,
            TARGET.TaxAmt = temp1.TaxAmt,
            TARGET.Freight = temp1.Freight,
            target.TotalDue=temp1.TotalDue,
            target.[sales_key]=temp1.[sales_key]
    WHEN NOT MATCHED BY TARGET THEN
        INSERT (
            SalesOrderID, UnitPrice, UnitPriceDiscount, OrderQty, TaxAmt, Freight,TotalDue,[sales_key]
        )
        VALUES (
            temp1.SalesOrderID, temp1.UnitPrice, temp1.UnitPriceDiscount,
            temp1.OrderQty, temp1.TaxAmt, temp1.Freight,temp1.TotalDue,temp1.[sales_key]
        );

exec dbo.SALE ;

select * from [AdventureWorks2022].dbo.Dim_Sales;
select * from [AdventureWorks2022].dbo.factsale;

select * from #temp
where SalesOrderID='51176';
select * from [AdventureWorks2022].Sales.SalesOrderHeader
where SalesOrderID='51176';