/**********************************************************************/
/* InstallProfile.SQL                                         */
/*                                                                    */
/* Installs the tables, triggers and stored procedures necessary for  */
/* supporting the aspnet feature of ASP.Net                           */
/*                                                                    */
/* InstallCommon.sql must be run before running this file.            */
/*
** Copyright Microsoft, Inc. 2002
** All Rights Reserved.
*/
/**********************************************************************/

PRINT '------------------------------------------------'
PRINT 'Starting execution of InstallProfile.SQL'
PRINT '------------------------------------------------'
GO

SET QUOTED_IDENTIFIER OFF -- We don't use quoted identifiers
SET ANSI_NULLS ON         -- We don't want (NULL = NULL) == TRUE
GO
SET ANSI_PADDING ON
GO
SET ANSI_NULL_DFLT_ON ON
GO

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/

DECLARE @dbname nvarchar(128)

SET @dbname = N'aspnetdb'

IF (NOT EXISTS (SELECT name
                FROM master.dbo.sysdatabases
                WHERE ('[' + name + ']' = @dbname OR name = @dbname)))
BEGIN
  RAISERROR('The database ''%s'' cannot be found. Please run InstallCommon.sql first.', 18, 1, @dbname)
END
GO

USE [aspnetdb]
GO

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_Applications')
                  AND (type = 'U')))
BEGIN
  RAISERROR('The table ''aspnet_Applications'' cannot be found. Please use aspnet_regsql.exe for installing ASP.NET application services.', 18, 1)
END

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_Users')
                  AND (type = 'U')))
BEGIN
  RAISERROR('The table ''aspnet_Users'' cannot be found. Please use aspnet_regsql.exe for installing ASP.NET application services.', 18, 1)
END

IF (NOT EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Applications_CreateApplication')
               AND (type = 'P')))
BEGIN
  RAISERROR('The stored procedure ''aspnet_Applications_CreateApplication'' cannot be found. Please use aspnet_regsql.exe for installing ASP.NET application services.', 18, 1)
END

IF (NOT EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Users_CreateUser')
               AND (type = 'P')))
BEGIN
  RAISERROR('The stored procedure ''aspnet_Users_CreateUser'' cannot be found. Please use aspnet_regsql.exe for installing ASP.NET application services.', 18, 1)
END

IF (NOT EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Users_DeleteUser')
               AND (type = 'P')))
BEGIN
  RAISERROR('The stored procedure ''aspnet_Users_DeleteUser'' cannot be found. Please use aspnet_regsql.exe for installing ASP.NET application services.', 18, 1)
END

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_Profile')
                  AND (type = 'U')))
BEGIN
  PRINT 'Creating the aspnet_Profile table...'
  CREATE TABLE dbo.aspnet_Profile (
        UserId                   uniqueidentifier   PRIMARY KEY FOREIGN KEY REFERENCES dbo.aspnet_Users(UserId),
        PropertyNames            ntext NOT NULL,
        PropertyValuesString     ntext NOT NULL,
        PropertyValuesBinary     image NOT NULL,
        LastUpdatedDate          datetime NOT NULL)
END

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Profile_GetProperties')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Profile_GetProperties
GO

CREATE PROCEDURE dbo.aspnet_Profile_GetProperties
    @ApplicationName      nvarchar(256),
    @UserName             nvarchar(256),
    @CurrentTimeUtc       datetime
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN

    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL

    SELECT @UserId = UserId
    FROM   dbo.aspnet_Users
    WHERE  ApplicationId = @ApplicationId AND LoweredUserName = LOWER(@UserName)

    IF (@UserId IS NULL)
        RETURN
    SELECT TOP 1 PropertyNames, PropertyValuesString, PropertyValuesBinary
    FROM         dbo.aspnet_Profile
    WHERE        UserId = @UserId

    IF (@@ROWCOUNT > 0)
    BEGIN
        UPDATE dbo.aspnet_Users
        SET    LastActivityDate=@CurrentTimeUtc
        WHERE  UserId = @UserId
    END
END
GO

/*************************************************************/
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Profile_SetProperties')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Profile_SetProperties
GO

CREATE PROCEDURE dbo.aspnet_Profile_SetProperties
    @ApplicationName        nvarchar(256),
    @PropertyNames          ntext,
    @PropertyValuesString   ntext,
    @PropertyValuesBinary   image,
    @UserName               nvarchar(256),
    @IsUserAnonymous        bit,
    @CurrentTimeUtc         datetime
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
       BEGIN TRANSACTION
       SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    DECLARE @UserId uniqueidentifier
    DECLARE @LastActivityDate datetime
    SELECT  @UserId = NULL
    SELECT  @LastActivityDate = @CurrentTimeUtc

    SELECT @UserId = UserId
    FROM   dbo.aspnet_Users
    WHERE  ApplicationId = @ApplicationId AND LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
        EXEC dbo.aspnet_Users_CreateUser @ApplicationId, @UserName, @IsUserAnonymous, @LastActivityDate, @UserId OUTPUT

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    UPDATE dbo.aspnet_Users
    SET    LastActivityDate=@CurrentTimeUtc
    WHERE  UserId = @UserId

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF (EXISTS( SELECT *
               FROM   dbo.aspnet_Profile
               WHERE  UserId = @UserId))
        UPDATE dbo.aspnet_Profile
        SET    PropertyNames=@PropertyNames, PropertyValuesString = @PropertyValuesString,
               PropertyValuesBinary = @PropertyValuesBinary, LastUpdatedDate=@CurrentTimeUtc
        WHERE  UserId = @UserId
    ELSE
        INSERT INTO dbo.aspnet_Profile(UserId, PropertyNames, PropertyValuesString, PropertyValuesBinary, LastUpdatedDate)
             VALUES (@UserId, @PropertyNames, @PropertyValuesString, @PropertyValuesBinary, @CurrentTimeUtc)

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @TranStarted = 1 )
    BEGIN
    	SET @TranStarted = 0
    	COMMIT TRANSACTION
    END

    RETURN 0

Cleanup:

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
IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Profile_DeleteProfiles')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Profile_DeleteProfiles
GO

CREATE PROCEDURE dbo.aspnet_Profile_DeleteProfiles
    @ApplicationName        nvarchar(256),
    @UserNames              nvarchar(4000)
AS
BEGIN
    DECLARE @UserName     nvarchar(256)
    DECLARE @CurrentPos   int
    DECLARE @NextPos      int
    DECLARE @NumDeleted   int
    DECLARE @DeletedUser  int
    DECLARE @TranStarted  bit
    DECLARE @ErrorCode    int

    SET @ErrorCode = 0
    SET @CurrentPos = 1
    SET @NumDeleted = 0
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
        BEGIN TRANSACTION
        SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    WHILE (@CurrentPos <= LEN(@UserNames))
    BEGIN
        SELECT @NextPos = CHARINDEX(N',', @UserNames,  @CurrentPos)
        IF (@NextPos = 0 OR @NextPos IS NULL)
            SELECT @NextPos = LEN(@UserNames) + 1

        SELECT @UserName = SUBSTRING(@UserNames, @CurrentPos, @NextPos - @CurrentPos)
        SELECT @CurrentPos = @NextPos+1

        IF (LEN(@UserName) > 0)
        BEGIN
            SELECT @DeletedUser = 0
            EXEC dbo.aspnet_Users_DeleteUser @ApplicationName, @UserName, 4, @DeletedUser OUTPUT
            IF( @@ERROR <> 0 )
            BEGIN
                SET @ErrorCode = -1
                GOTO Cleanup
            END
            IF (@DeletedUser <> 0)
                SELECT @NumDeleted = @NumDeleted + 1
        END
    END
    SELECT @NumDeleted
    IF (@TranStarted = 1)
    BEGIN
    	SET @TranStarted = 0
    	COMMIT TRANSACTION
    END
    SET @TranStarted = 0

    RETURN 0

Cleanup:
    IF (@TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END
    RETURN @ErrorCode
END
GO

/*************************************************************/
/*************************************************************/
IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Profile_DeleteInactiveProfiles')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Profile_DeleteInactiveProfiles
GO

CREATE PROCEDURE dbo.aspnet_Profile_DeleteInactiveProfiles
    @ApplicationName        nvarchar(256),
    @ProfileAuthOptions     int,
    @InactiveSinceDate      datetime
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
    BEGIN
        SELECT  0
        RETURN
    END

    DELETE
    FROM    dbo.aspnet_Profile
    WHERE   UserId IN
            (   SELECT  UserId
                FROM    dbo.aspnet_Users u
                WHERE   ApplicationId = @ApplicationId
                        AND (LastActivityDate <= @InactiveSinceDate)
                        AND (
                                (@ProfileAuthOptions = 2)
                             OR (@ProfileAuthOptions = 0 AND IsAnonymous = 1)
                             OR (@ProfileAuthOptions = 1 AND IsAnonymous = 0)
                            )
            )

    SELECT  @@ROWCOUNT
END
GO

/*************************************************************/
/*************************************************************/
 IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Profile_GetNumberOfInactiveProfiles')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Profile_GetNumberOfInactiveProfiles
GO

CREATE PROCEDURE dbo.aspnet_Profile_GetNumberOfInactiveProfiles
    @ApplicationName        nvarchar(256),
    @ProfileAuthOptions     int,
    @InactiveSinceDate      datetime
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
    BEGIN
        SELECT 0
        RETURN
    END

    SELECT  COUNT(*)
    FROM    dbo.aspnet_Users u, dbo.aspnet_Profile p
    WHERE   ApplicationId = @ApplicationId
        AND u.UserId = p.UserId
        AND (LastActivityDate <= @InactiveSinceDate)
        AND (
                (@ProfileAuthOptions = 2)
                OR (@ProfileAuthOptions = 0 AND IsAnonymous = 1)
                OR (@ProfileAuthOptions = 1 AND IsAnonymous = 0)
            )
END
GO


/*************************************************************/
/*************************************************************/
IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Profile_GetProfiles')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Profile_GetProfiles
GO

CREATE PROCEDURE dbo.aspnet_Profile_GetProfiles
    @ApplicationName        nvarchar(256),
    @ProfileAuthOptions     int,
    @PageIndex              int,
    @PageSize               int,
    @UserNameToMatch        nvarchar(256) = NULL,
    @InactiveSinceDate      datetime      = NULL
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN

    -- Set the page bounds
    DECLARE @PageLowerBound int
    DECLARE @PageUpperBound int
    DECLARE @TotalRecords   int
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForUsers
    (
        IndexId int IDENTITY (0, 1) NOT NULL,
        UserId uniqueidentifier
    )

    -- Insert into our temp table
    INSERT INTO #PageIndexForUsers (UserId)
        SELECT  u.UserId
        FROM    dbo.aspnet_Users u, dbo.aspnet_Profile p
        WHERE   ApplicationId = @ApplicationId
            AND u.UserId = p.UserId
            AND (@InactiveSinceDate IS NULL OR LastActivityDate <= @InactiveSinceDate)
            AND (     (@ProfileAuthOptions = 2)
                   OR (@ProfileAuthOptions = 0 AND IsAnonymous = 1)
                   OR (@ProfileAuthOptions = 1 AND IsAnonymous = 0)
                 )
            AND (@UserNameToMatch IS NULL OR LoweredUserName LIKE LOWER(@UserNameToMatch))
        ORDER BY UserName

    SELECT  u.UserName, u.IsAnonymous, u.LastActivityDate, p.LastUpdatedDate,
            DATALENGTH(p.PropertyNames) + DATALENGTH(p.PropertyValuesString) + DATALENGTH(p.PropertyValuesBinary)
    FROM    dbo.aspnet_Users u, dbo.aspnet_Profile p, #PageIndexForUsers i
    WHERE   u.UserId = p.UserId AND p.UserId = i.UserId AND i.IndexId >= @PageLowerBound AND i.IndexId <= @PageUpperBound

    SELECT COUNT(*)
    FROM   #PageIndexForUsers

    DROP TABLE #PageIndexForUsers
END
GO

/*************************************************************/
/*************************************************************/
IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'vw_aspnet_Profiles')
                  AND (type = 'V')))
BEGIN
  PRINT 'Creating the vw_aspnet_Profiles view...'
  EXEC(N'
  CREATE VIEW [dbo].[vw_aspnet_Profiles]
  AS SELECT [dbo].[aspnet_Profile].[UserId], [dbo].[aspnet_Profile].[LastUpdatedDate],
      [DataSize]=  DATALENGTH([dbo].[aspnet_Profile].[PropertyNames])
                 + DATALENGTH([dbo].[aspnet_Profile].[PropertyValuesString])
                 + DATALENGTH([dbo].[aspnet_Profile].[PropertyValuesBinary])
  FROM [dbo].[aspnet_Profile]
  ')
END
GO

/*************************************************************/
/*************************************************************/

--
--Create Profile schema version
--

DECLARE @command nvarchar(4000)
SET @command = 'GRANT EXECUTE ON [dbo].aspnet_RegisterSchemaVersion TO ' + QUOTENAME(user)
EXECUTE (@command)
GO

EXEC [dbo].aspnet_RegisterSchemaVersion N'Profile', N'1', 1, 1
GO

/*************************************************************/
/*************************************************************/

--
--Create Profile roles
--

IF ( NOT EXISTS ( SELECT name
                  FROM sysusers
                  WHERE issqlrole = 1
                  AND name = N'aspnet_Profile_FullAccess' ) )
EXEC sp_addrole N'aspnet_Profile_FullAccess'

IF ( NOT EXISTS ( SELECT name
                  FROM sysusers
                  WHERE issqlrole = 1
                  AND name = N'aspnet_Profile_BasicAccess' ) )
EXEC sp_addrole N'aspnet_Profile_BasicAccess'

IF ( NOT EXISTS ( SELECT name
                  FROM sysusers
                  WHERE issqlrole = 1
                  AND name = N'aspnet_Profile_ReportingAccess' ) )
EXEC sp_addrole N'aspnet_Profile_ReportingAccess'
GO

EXEC sp_addrolemember N'aspnet_Profile_BasicAccess', N'aspnet_Profile_FullAccess'
EXEC sp_addrolemember N'aspnet_Profile_ReportingAccess', N'aspnet_Profile_FullAccess'
GO

--
--Stored Procedure rights for BasicAccess
--
GRANT EXECUTE ON dbo.aspnet_Profile_GetProperties TO aspnet_Profile_BasicAccess
GRANT EXECUTE ON dbo.aspnet_Profile_SetProperties TO aspnet_Profile_BasicAccess
GRANT EXECUTE ON dbo.aspnet_CheckSchemaVersion TO aspnet_Profile_BasicAccess
GRANT EXECUTE ON dbo.aspnet_RegisterSchemaVersion TO aspnet_Profile_BasicAccess
GRANT EXECUTE ON dbo.aspnet_UnRegisterSchemaVersion TO aspnet_Profile_BasicAccess

--
--Stored Procedure rights for ReportingAccess
--
GRANT EXECUTE ON dbo.aspnet_Profile_GetNumberOfInactiveProfiles TO aspnet_Profile_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_Profile_GetProfiles TO aspnet_Profile_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_CheckSchemaVersion TO aspnet_Profile_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_RegisterSchemaVersion TO aspnet_Profile_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_UnRegisterSchemaVersion TO aspnet_Profile_ReportingAccess

--
--Additional stored procedure rights for FullAccess
--
GRANT EXECUTE ON dbo.aspnet_Profile_DeleteProfiles TO aspnet_Profile_FullAccess
GRANT EXECUTE ON dbo.aspnet_Profile_DeleteInactiveProfiles TO aspnet_Profile_FullAccess

--
--View rights
--
GRANT SELECT ON dbo.vw_aspnet_Applications TO aspnet_Profile_ReportingAccess
GRANT SELECT ON dbo.vw_aspnet_Users TO aspnet_Profile_ReportingAccess

GRANT SELECT ON dbo.vw_aspnet_Profiles TO aspnet_Profile_ReportingAccess
GO

-------------------------------------------------------------------------
--- Version specific install
-------------------------------------------------------------------------

DECLARE @ver int
DECLARE @version nchar(100)
DECLARE @dot int
DECLARE @hyphen int
DECLARE @SqlToExec nchar(400)

SELECT @ver = 8
SELECT @version = @@Version
SELECT @hyphen  = CHARINDEX(N' - ', @version)
IF (NOT(@hyphen IS NULL) AND @hyphen > 0)
BEGIN
    SELECT @hyphen = @hyphen + 3
    SELECT @dot    = CHARINDEX(N'.', @version, @hyphen)
    IF (NOT(@dot IS NULL) AND @dot > @hyphen)
    BEGIN
        SELECT @version = SUBSTRING(@version, @hyphen, @dot - @hyphen)
        SELECT @ver     = CONVERT(int, @version)
    END
END

IF (@ver >= 8)
BEGIN
    EXEC sp_tableoption N'aspnet_Profile', 'text in row', 6000
END
GO
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/


DECLARE @command nvarchar(4000)
SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_RegisterSchemaVersion FROM ' + QUOTENAME(user)
EXECUTE (@command)
GO

PRINT '-------------------------------------------------'
PRINT 'Completed execution of InstallProfile.SQL'
PRINT '-------------------------------------------------'
