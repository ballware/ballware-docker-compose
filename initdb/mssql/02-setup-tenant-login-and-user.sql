SET NOCOUNT ON;

-- In tenant DB ausführen
USE [tenant];

-- Erstelle Login 'tenant' falls er nicht existiert (serverweit)
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = N'tenant')
BEGIN
    CREATE LOGIN [tenant] WITH PASSWORD = N'$(TENANT_PASSWORD)';
    PRINT 'Login tenant created.';
END
ELSE
BEGIN
    ALTER LOGIN [tenant] WITH PASSWORD = N'$(TENANT_PASSWORD)';
    PRINT 'Login tenant password updated.';
END

-- Erstelle Datenbankbenutzer 'tenant' falls er nicht existiert
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = N'tenant')
BEGIN
    CREATE USER [tenant] FOR LOGIN [tenant];
    PRINT 'User tenant created.';
END

-- Füge Benutzer 'tenant' zur db_owner Rolle hinzu falls noch nicht Mitglied
IF NOT EXISTS (
  SELECT 1 
  FROM sys.database_role_members rm 
  JOIN sys.database_principals dp ON rm.member_principal_id = dp.principal_id
  JOIN sys.database_principals dp2 ON rm.role_principal_id = dp2.principal_id
  WHERE dp.name = N'tenant' AND dp2.name = N'db_owner')
BEGIN
    ALTER ROLE db_owner ADD MEMBER [tenant];
    PRINT 'User tenant added to db_owner role.';
END
ELSE
BEGIN
    PRINT 'User tenant is already a member of db_owner role.';
END

PRINT 'Tenant login/user setup completed.';
