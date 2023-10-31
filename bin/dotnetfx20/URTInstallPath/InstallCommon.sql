/**********************************************************************/
/* InstallCommon.SQL                                                  */
/*                                                                    */
/* Installs the tables, triggers and stored procedures necessary for  */
/* supporting some features of ASP.Net                                */
/*
** Copyright Microsoft, Inc. 2003
** All Rights Reserved.
*/
/**********************************************************************/

PRINT '---------------------------------------'
PRINT 'Starting execution of InstallCommon.SQL'
PRINT '---------------------------------------'
GO

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON         -- We don't want (NULL = NULL) == TRUE
GO
SET ANSI_PADDING ON
GO
SET ANSI_NULL_DFLT_ON ON
GO

DECLARE @dbname nvarchar(128)
DECLARE @dboptions nvarchar(1024)

SET @dboptions = N'/**/'
SET @dbname = N'aspnetdb'

IF (NOT EXISTS (SELECT name
                FROM master.dbo.sysdatabases
                WHERE name = @dbname))
BEGIN
  PRINT 'Creating the ' + @dbname + ' database...'
  DECLARE @cmd nvarchar(500)
  SET @cmd = 'CREATE DATABASE [' + @dbname + '] ' + @dboptions
  EXEC(@cmd)
END
GO

USE [aspnetdb]
GO

/*************************************************************/
/*************************************************************/
/*************************************************************/
-- Create the temporary permission tables and stored procedures
-- TO preserve the permissions of an object.
--
-- We use this method instead of using CREATE (if the object
-- doesn't exist) and ALTER (if the object exists) because the
-- latter one either requires the use of dynamic SQL (which we want to
-- avoid) or writing the body of the object (e.g. an SP or view) twice,
-- once use CREATE and again using ALTER.


IF (OBJECT_ID('tempdb.#aspnet_Permissions') IS NOT NULL)
BEGIN
    DROP TABLE #aspnet_Permissions
END
GO

CREATE TABLE #aspnet_Permissions
(
    Owner     sysname,
    Object    sysname,
    Grantee   sysname,
    Grantor   sysname,
    ProtectType char(10),
    [Action]    varchar(20),
    [Column]    sysname
)

INSERT INTO #aspnet_Permissions
EXEC sp_helprotect

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Setup_RestorePermissions')
               AND (type = 'P')))
DROP PROCEDURE [dbo].aspnet_Setup_RestorePermissions
GO

CREATE PROCEDURE [dbo].aspnet_Setup_RestorePermissions
    @name   sysname
AS
BEGIN
    DECLARE @object sysname
    DECLARE @protectType char(10)
    DECLARE @action varchar(20)
    DECLARE @grantee sysname
    DECLARE @cmd nvarchar(500)
    DECLARE c1 cursor FORWARD_ONLY FOR
        SELECT Object, ProtectType, [Action], Grantee FROM #aspnet_Permissions where Object = @name

    OPEN c1

    FETCH c1 INTO @object, @protectType, @action, @grantee
    WHILE (@@fetch_status = 0)
    BEGIN
        SET @cmd = @protectType + ' ' + @action + ' on ' + @object + ' TO [' + @grantee + ']'
        EXEC (@cmd)
        FETCH c1 INTO @object, @protectType, @action, @grantee
    END

    CLOSE c1
    DEALLOCATE c1
END
GO

/*************************************************************/
/*************************************************************/
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Setup_RemoveAllRoleMembers')
               AND (type = 'P')))
DROP PROCEDURE [dbo].aspnet_Setup_RemoveAllRoleMembers
GO

CREATE PROCEDURE [dbo].aspnet_Setup_RemoveAllRoleMembers
    @name   sysname
AS
BEGIN
    CREATE TABLE #aspnet_RoleMembers
    (
        Group_name      sysname,
        Group_id        smallint,
        Users_in_group  sysname,
        User_id         smallint
    )

    INSERT INTO #aspnet_RoleMembers
    EXEC sp_helpuser @name

    DECLARE @user_id smallint
    DECLARE @cmd nvarchar(500)
    DECLARE c1 cursor FORWARD_ONLY FOR
        SELECT User_id FROM #aspnet_RoleMembers

    OPEN c1

    FETCH c1 INTO @user_id
    WHILE (@@fetch_status = 0)
    BEGIN
        SET @cmd = 'EXEC sp_droprolemember ' + '''' + @name + ''', ''' + USER_NAME(@user_id) + ''''
        EXEC (@cmd)
        FETCH c1 INTO @user_id
    END

    CLOSE c1
    DEALLOCATE c1
END
GO

/*************************************************************/
/*************************************************************/
/*************************************************************/
-- Create the aspnet_Applications table.

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_Applications')
                  AND (type = 'U')))
BEGIN
  PRINT 'Creating the aspnet_Applications table...'
  CREATE TABLE [dbo].aspnet_Applications (
    ApplicationName         nvarchar(256)               NOT NULL UNIQUE,
    LoweredApplicationName  nvarchar(256)               NOT NULL UNIQUE,
    ApplicationId           uniqueidentifier            PRIMARY KEY NONCLUSTERED DEFAULT NEWID(),
    Description             nvarchar(256)       )
  CREATE CLUSTERED INDEX aspnet_Applications_Index ON [dbo].aspnet_Applications(LoweredApplicationName)
END
GO

/*************************************************************/
/*************************************************************/
/*************************************************************/
-- Create the aspnet_Users table
IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_Users')
                  AND (type = 'U')))
BEGIN
  PRINT 'Creating the aspnet_Users table...'
  CREATE TABLE [dbo].aspnet_Users (
    ApplicationId    uniqueidentifier    NOT NULL FOREIGN KEY REFERENCES [dbo].aspnet_Applications(ApplicationId),
    UserId           uniqueidentifier    NOT NULL PRIMARY KEY NONCLUSTERED DEFAULT NEWID(),
    UserName         nvarchar(256)       NOT NULL,
    LoweredUserName  nvarchar(256)	     NOT NULL,
    MobileAlias      nvarchar(16)        DEFAULT NULL,
    IsAnonymous      bit                 NOT NULL DEFAULT 0,
    LastActivityDate DATETIME            NOT NULL)

   CREATE UNIQUE CLUSTERED INDEX aspnet_Users_Index ON [dbo].aspnet_Users(ApplicationId, LoweredUserName)
   CREATE NONCLUSTERED INDEX aspnet_Users_Index2 ON [dbo].aspnet_Users(ApplicationId, LastActivityDate)
END
GO

/*************************************************************/
/*************************************************************/
/*************************************************************/
-- Create the aspnet_SchemaVersions table
IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_SchemaVersions')
                  AND (type = 'U')))
BEGIN
  PRINT 'Creating the aspnet_SchemaVersions table...'
  CREATE TABLE [dbo].aspnet_SchemaVersions (
    Feature                  nvarchar(128)  NOT NULL PRIMARY KEY CLUSTERED( Feature, CompatibleSchemaVersion ),
    CompatibleSchemaVersion  nvarchar(128)	NOT NULL,
    IsCurrentVersion         bit            NOT NULL )
END
GO

/*************************************************************/
/*************************************************************/
------------- Create Stored Procedures
/*************************************************************/
/*************************************************************/
-- RegisterSchemaVersion SP

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_RegisterSchemaVersion')
               AND (type = 'P')))
DROP PROCEDURE [dbo].aspnet_RegisterSchemaVersion
GO

CREATE PROCEDURE [dbo].aspnet_RegisterSchemaVersion
    @Feature                   nvarchar(128),
    @CompatibleSchemaVersion   nvarchar(128),
    @IsCurrentVersion          bit,
    @RemoveIncompatibleSchema  bit
AS
BEGIN
    IF( @RemoveIncompatibleSchema = 1 )
    BEGIN
        DELETE FROM dbo.aspnet_SchemaVersions WHERE Feature = LOWER( @Feature )
    END
    ELSE
    BEGIN
        IF( @IsCurrentVersion = 1 )
        BEGIN
            UPDATE dbo.aspnet_SchemaVersions
            SET IsCurrentVersion = 0
            WHERE Feature = LOWER( @Feature )
        END
    END

    INSERT  dbo.aspnet_SchemaVersions( Feature, CompatibleSchemaVersion, IsCurrentVersion )
    VALUES( LOWER( @Feature ), @CompatibleSchemaVersion, @IsCurrentVersion )
END
GO

DECLARE @command nvarchar(4000)

SET @command = 'GRANT EXECUTE ON [dbo].aspnet_Setup_RestorePermissions TO ' + QUOTENAME(user)
EXEC (@command)
SET @command = 'GRANT EXECUTE ON [dbo].aspnet_RegisterSchemaVersion TO ' + QUOTENAME(user)
EXEC (@command)
GO

-- Restore the permissions
EXEC [dbo].aspnet_Setup_RestorePermissions N'aspnet_RegisterSchemaVersion'
GO

-- Create common schema version
EXEC [dbo].aspnet_RegisterSchemaVersion N'Common', N'1', 1, 1
GO

/*************************************************************/
/*************************************************************/
-- CheckSchemaVersion SP

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_CheckSchemaVersion')
               AND (type = 'P')))
DROP PROCEDURE [dbo].aspnet_CheckSchemaVersion
GO

CREATE PROCEDURE [dbo].aspnet_CheckSchemaVersion
    @Feature                   nvarchar(128),
    @CompatibleSchemaVersion   nvarchar(128)
AS
BEGIN
    IF (EXISTS( SELECT  *
                FROM    dbo.aspnet_SchemaVersions
                WHERE   Feature = LOWER( @Feature ) AND
                        CompatibleSchemaVersion = @CompatibleSchemaVersion ))
        RETURN 0

    RETURN 1
END
GO

-- Restore the permissions
EXEC [dbo].aspnet_Setup_RestorePermissions N'aspnet_CheckSchemaVersion'
GO

/*************************************************************/
/*************************************************************/
-- CreateApplication SP

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Applications_CreateApplication')
               AND (type = 'P')))
DROP PROCEDURE [dbo].aspnet_Applications_CreateApplication
GO

CREATE PROCEDURE [dbo].aspnet_Applications_CreateApplication
    @ApplicationName      nvarchar(256),
    @ApplicationId        uniqueidentifier OUTPUT
AS
BEGIN
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName

    IF(@ApplicationId IS NULL)
    BEGIN
        DECLARE @TranStarted   bit
        SET @TranStarted = 0

        IF( @@TRANCOUNT = 0 )
        BEGIN
	        BEGIN TRANSACTION
	        SET @TranStarted = 1
        END
        ELSE
    	    SET @TranStarted = 0

        SELECT  @ApplicationId = ApplicationId
        FROM dbo.aspnet_Applications WITH (UPDLOCK, HOLDLOCK)
        WHERE LOWER(@ApplicationName) = LoweredApplicationName

        IF(@ApplicationId IS NULL)
        BEGIN
            SELECT  @ApplicationId = NEWID()
            INSERT  dbo.aspnet_Applications (ApplicationId, ApplicationName, LoweredApplicationName)
            VALUES  (@ApplicationId, @ApplicationName, LOWER(@ApplicationName))
        END


        IF( @TranStarted = 1 )
        BEGIN
            IF(@@ERROR = 0)
            BEGIN
	        SET @TranStarted = 0
	        COMMIT TRANSACTION
            END
            ELSE
            BEGIN
                SET @TranStarted = 0
                ROLLBACK TRANSACTION
            END
        END
    END
END
GO

-- Restore the permissions
EXEC [dbo].aspnet_Setup_RestorePermissions N'aspnet_Applications_CreateApplication'
GO

/*************************************************************/
/*************************************************************/
-- UnRegisterSchemaVersion SP

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_UnRegisterSchemaVersion')
               AND (type = 'P')))
DROP PROCEDURE [dbo].aspnet_UnRegisterSchemaVersion
GO

CREATE PROCEDURE [dbo].aspnet_UnRegisterSchemaVersion
    @Feature                   nvarchar(128),
    @CompatibleSchemaVersion   nvarchar(128)
AS
BEGIN
    DELETE FROM dbo.aspnet_SchemaVersions
        WHERE   Feature = LOWER(@Feature) AND @CompatibleSchemaVersion = CompatibleSchemaVersion
END
GO

-- Restore the permissions
EXEC [dbo].aspnet_Setup_RestorePermissions N'aspnet_UnRegisterSchemaVersion'
GO

/*************************************************************/
/*************************************************************/
-- CreateUser SP

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Users_CreateUser')
               AND (type = 'P')))
DROP PROCEDURE [dbo].aspnet_Users_CreateUser
GO

CREATE PROCEDURE [dbo].aspnet_Users_CreateUser
    @ApplicationId    uniqueidentifier,
    @UserName         nvarchar(256),
    @IsUserAnonymous  bit,
    @LastActivityDate DATETIME,
    @UserId           uniqueidentifier OUTPUT
AS
BEGIN
    IF( @UserId IS NULL )
        SELECT @UserId = NEWID()
    ELSE
    BEGIN
        IF( EXISTS( SELECT UserId FROM dbo.aspnet_Users
                    WHERE @UserId = UserId ) )
            RETURN -1
    END

    INSERT dbo.aspnet_Users (ApplicationId, UserId, UserName, LoweredUserName, IsAnonymous, LastActivityDate)
    VALUES (@ApplicationId, @UserId, @UserName, LOWER(@UserName), @IsUserAnonymous, @LastActivityDate)

    RETURN 0
END
GO

-- Restore the permissions
EXEC [dbo].aspnet_Setup_RestorePermissions N'aspnet_Users_CreateUser'
GO

/*************************************************************/
/*************************************************************/
--- DeleteUser SP

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Users_DeleteUser')
               AND (type = 'P')))
DROP PROCEDURE [dbo].aspnet_Users_DeleteUser
GO
CREATE PROCEDURE [dbo].aspnet_Users_DeleteUser
    @ApplicationName  nvarchar(256),
    @UserName         nvarchar(256),
    @TablesToDeleteFrom int,
    @NumTablesDeletedFrom int OUTPUT
AS
BEGIN
    DECLARE @UserId               uniqueidentifier
    SELECT  @UserId               = NULL
    SELECT  @NumTablesDeletedFrom = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
	SET @TranStarted = 0

    DECLARE @ErrorCode   int
    DECLARE @RowCount    int

    SET @ErrorCode = 0
    SET @RowCount  = 0

    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a
    WHERE   u.LoweredUserName       = LOWER(@UserName)
        AND u.ApplicationId         = a.ApplicationId
        AND LOWER(@ApplicationName) = a.LoweredApplicationName

    IF (@UserId IS NULL)
    BEGIN
        GOTO Cleanup
    END

    -- Delete from Membership table if (@TablesToDeleteFrom & 1) is set
    IF ((@TablesToDeleteFrom & 1) <> 0 AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_MembershipUsers') AND (type = 'V'))))
    BEGIN
        DELETE FROM dbo.aspnet_Membership WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
               @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_UsersInRoles table if (@TablesToDeleteFrom & 2) is set
    IF ((@TablesToDeleteFrom & 2) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_UsersInRoles') AND (type = 'V'))) )
    BEGIN
        DELETE FROM dbo.aspnet_UsersInRoles WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_Profile table if (@TablesToDeleteFrom & 4) is set
    IF ((@TablesToDeleteFrom & 4) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_Profiles') AND (type = 'V'))) )
    BEGIN
        DELETE FROM dbo.aspnet_Profile WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_PersonalizationPerUser table if (@TablesToDeleteFrom & 8) is set
    IF ((@TablesToDeleteFrom & 8) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_WebPartState_User') AND (type = 'V'))) )
    BEGIN
        DELETE FROM dbo.aspnet_PersonalizationPerUser WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_Users table if (@TablesToDeleteFrom & 1,2,4 & 8) are all set
    IF ((@TablesToDeleteFrom & 1) <> 0 AND
        (@TablesToDeleteFrom & 2) <> 0 AND
        (@TablesToDeleteFrom & 4) <> 0 AND
        (@TablesToDeleteFrom & 8) <> 0 AND
        (EXISTS (SELECT UserId FROM dbo.aspnet_Users WHERE @UserId = UserId)))
    BEGIN
        DELETE FROM dbo.aspnet_Users WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    IF( @TranStarted = 1 )
    BEGIN
	    SET @TranStarted = 0
	    COMMIT TRANSACTION
    END

    RETURN 0

Cleanup:
    SET @NumTablesDeletedFrom = 0

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
	    ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END
GO

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/

-- Restore the permissions
EXEC [dbo].aspnet_Setup_RestorePermissions N'aspnet_Users_DeleteUser'
GO

/*************************************************************/
/*************************************************************/
--- aspnet_AnyDataInTables SP

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_AnyDataInTables')
               AND (type = 'P')))
DROP PROCEDURE [dbo].aspnet_AnyDataInTables
GO
CREATE PROCEDURE [dbo].aspnet_AnyDataInTables
    @TablesToCheck int
AS
BEGIN
    -- Check Membership table if (@TablesToCheck & 1) is set
    IF ((@TablesToCheck & 1) <> 0 AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_MembershipUsers') AND (type = 'V'))))
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_Membership))
        BEGIN
            SELECT N'aspnet_Membership'
            RETURN
        END
    END

    -- Check aspnet_Roles table if (@TablesToCheck & 2) is set
    IF ((@TablesToCheck & 2) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_Roles') AND (type = 'V'))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 RoleId FROM dbo.aspnet_Roles))
        BEGIN
            SELECT N'aspnet_Roles'
            RETURN
        END
    END

    -- Check aspnet_Profile table if (@TablesToCheck & 4) is set
    IF ((@TablesToCheck & 4) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_Profiles') AND (type = 'V'))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_Profile))
        BEGIN
            SELECT N'aspnet_Profile'
            RETURN
        END
    END

    -- Check aspnet_PersonalizationPerUser table if (@TablesToCheck & 8) is set
    IF ((@TablesToCheck & 8) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'vw_aspnet_WebPartState_User') AND (type = 'V'))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_PersonalizationPerUser))
        BEGIN
            SELECT N'aspnet_PersonalizationPerUser'
            RETURN
        END
    END

    -- Check aspnet_PersonalizationPerUser table if (@TablesToCheck & 16) is set
    IF ((@TablesToCheck & 16) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N'aspnet_WebEvent_LogEvent') AND (type = 'P'))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 * FROM dbo.aspnet_WebEvent_Events))
        BEGIN
            SELECT N'aspnet_WebEvent_Events'
            RETURN
        END
    END

    -- Check aspnet_Users table if (@TablesToCheck & 1,2,4 & 8) are all set
    IF ((@TablesToCheck & 1) <> 0 AND
        (@TablesToCheck & 2) <> 0 AND
        (@TablesToCheck & 4) <> 0 AND
        (@TablesToCheck & 8) <> 0 AND
        (@TablesToCheck & 32) <> 0 AND
        (@TablesToCheck & 128) <> 0 AND
        (@TablesToCheck & 256) <> 0 AND
        (@TablesToCheck & 512) <> 0 AND
        (@TablesToCheck & 1024) <> 0)
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_Users))
        BEGIN
            SELECT N'aspnet_Users'
            RETURN
        END
        IF (EXISTS(SELECT TOP 1 ApplicationId FROM dbo.aspnet_Applications))
        BEGIN
            SELECT N'aspnet_Applications'
            RETURN
        END
    END
END
GO

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
DECLARE @command nvarchar(400)
SET @command = 'GRANT EXECUTE ON [dbo].aspnet_AnyDataInTables TO ' + QUOTENAME(user)
EXEC (@command)
GO

-- Restore the permissions
EXEC [dbo].aspnet_Setup_RestorePermissions N'aspnet_AnyDataInTables'
GO

/*************************************************************/
/*************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'vw_aspnet_Applications')
                  AND (type = 'V')))
BEGIN
  PRINT 'Creating the vw_aspnet_Applications view...'
  EXEC('
  CREATE VIEW [dbo].[vw_aspnet_Applications]
  AS SELECT [dbo].[aspnet_Applications].[ApplicationName], [dbo].[aspnet_Applications].[LoweredApplicationName], [dbo].[aspnet_Applications].[ApplicationId], [dbo].[aspnet_Applications].[Description]
  FROM [dbo].[aspnet_Applications]
  ')
END

-- Restore the permissions
EXEC [dbo].aspnet_Setup_RestorePermissions N'vw_aspnet_Applications'
GO

/*************************************************************/
/*************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'vw_aspnet_Users')
                  AND (type = 'V')))
BEGIN
  PRINT 'Creating the vw_aspnet_Users view...'
  EXEC('
  CREATE VIEW [dbo].[vw_aspnet_Users]
  AS SELECT [dbo].[aspnet_Users].[ApplicationId], [dbo].[aspnet_Users].[UserId], [dbo].[aspnet_Users].[UserName], [dbo].[aspnet_Users].[LoweredUserName], [dbo].[aspnet_Users].[MobileAlias], [dbo].[aspnet_Users].[IsAnonymous], [dbo].[aspnet_Users].[LastActivityDate]
  FROM [dbo].[aspnet_Users]
  ')
END

-- Restore the permissions
EXEC [dbo].aspnet_Setup_RestorePermissions N'vw_aspnet_Users'
GO

/*************************************************************/
/*************************************************************/
DECLARE @command nvarchar(4000)

SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_Setup_RestorePermissions from ' + QUOTENAME(user)
EXEC (@command)
SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_RegisterSchemaVersion from ' + QUOTENAME(user)
EXEC (@command)
GO

DROP TABLE #aspnet_Permissions
GO

PRINT '----------------------------------------'
PRINT 'Completed execution of InstallCommon.SQL'
PRINT '----------------------------------------'
