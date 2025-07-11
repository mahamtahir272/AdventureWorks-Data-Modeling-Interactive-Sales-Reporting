SELECT TOP (1000) [BusinessEntityID]
      ,[Name]
      ,[SalesPersonID]
      ,[Demographics]
      ,[rowguid]
      ,[ModifiedDate]
  FROM [AdventureWorks2022].[Sales].[Store]

  select BusinessEntityID,SalesPersonID,count(0)
  from [AdventureWorks2022].[Sales].[Store]
  group by BusinessEntityID,SalesPersonID
  having count(0)>1;


