-- 00_Workload_CPU_Stress.sql
-- Generate CPU-intensive workload for Demo Scripts
-- Run this in a separate session, then run 01_Check_Schedulers.sql in another window
-- Stop this script when done: Press Cancel or close the query window

USE AdventureWorks2019; -- Change to your database
GO

SET NOCOUNT ON;

DECLARE @Counter INT = 0;
DECLARE @StartTime DATETIME = GETDATE();
DECLARE @Duration INT = 300; -- Run for 5 minutes (adjust as needed)

PRINT 'Starting CPU stress workload...';
PRINT 'Run 01_Check_Schedulers.sql in another window to see runnable_tasks_count > 0';
PRINT 'Press Cancel to stop this workload';

WHILE DATEDIFF(SECOND, @StartTime, GETDATE()) < @Duration
BEGIN
    SET @Counter = @Counter + 1;
    
    -- CPU-intensive operations
    SELECT 
        SUM(CAST(ProductID AS BIGINT) * OrderQty * UnitPrice) AS TotalValue
    ,	COUNT(*) AS RowCount
    ,	CHECKSUM_AGG(CAST(ProductID AS INT)) AS ChecksumValue
    FROM Sales.SalesOrderDetail
    WHERE ProductID BETWEEN 700 AND 800
    GROUP BY ProductID % 10;
    
    -- More CPU work with string operations
    SELECT 
        SUBSTRING(FirstName, 1, LEN(FirstName) / 2) + 
        REVERSE(SUBSTRING(FirstName, LEN(FirstName) / 2 + 1, LEN(FirstName))) AS ProcessedName
    ,	CHECKSUM(LastName) AS NameHash
    FROM Person.Person
    WHERE BusinessEntityID % 100 = @Counter % 100;
    
    -- Mathematical calculations
    SELECT 
        SQRT(SUM(CAST(SalesOrderID AS FLOAT) * SalesOrderID)) AS SqrtSum
    ,	POWER(COUNT(*), 2.5) AS PowerCount
    FROM Sales.SalesOrderHeader
    WHERE OrderDate >= DATEADD(YEAR, -1, GETDATE());
    
    -- Yield every 100 iterations to allow other queries
    IF @Counter % 100 = 0
    BEGIN
        WAITFOR DELAY '00:00:00.010'; -- 10ms delay
    END
END;

PRINT 'Workload completed.';
GO

