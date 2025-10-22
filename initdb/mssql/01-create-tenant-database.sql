SET NOCOUNT ON;

-- In master ausführen
USE [master];

-- Erstelle Datenbank 'tenant' falls sie nicht existiert
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'tenant')
BEGIN
        CREATE DATABASE [tenant];
        PRINT 'Database tenant created.';
END
ELSE
BEGIN
        PRINT 'Database tenant already exists.';
END

-- Warte, bis die Datenbank ONLINE ist
DECLARE @retry INT = 60;
WHILE DB_ID(N'tenant') IS NULL OR EXISTS (
    SELECT 1 FROM sys.databases WHERE name = N'tenant' AND state <> 0 -- 0 = ONLINE
)
BEGIN
    WAITFOR DELAY '00:00:01';
    SET @retry -= 1;
    IF @retry = 0 
    BEGIN
        THROW 51000, 'Timeout waiting for tenant DB to be ONLINE', 1;
    END
END

PRINT 'Tenant database created and online.';