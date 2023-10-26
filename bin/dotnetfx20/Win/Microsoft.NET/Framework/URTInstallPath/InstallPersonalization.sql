/**********************************************************************/
/* InstallPersonalization.SQL                                         */
/*                                                                    */
/* Installs the tables, triggers and stored procedures necessary for  */
/* supporting the personalization feature of ASP.NET                  */
/*                                                                    */
/* InstallCommon.sql must be run before running this file.            */
/*
** Copyright Microsoft, Inc. 2002
** All Rights Reserved.
*/
/**********************************************************************/

PRINT '------------------------------------------------'
PRINT 'Starting execution of InstallPersonalization.SQL'
PRINT '------------------------------------------------'
GO

SET QUOTED_IDENTIFIER OFF
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

DECLARE @dbname NVARCHAR(128)

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

/***************************************************************************************************************************/
/***************************************************************************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_Paths')
                  AND (type = 'U')))
BEGIN
  PRINT 'Creating the aspnet_Paths table...'
  CREATE TABLE dbo.aspnet_Paths (
        ApplicationId    UNIQUEIDENTIFIER    NOT NULL FOREIGN KEY REFERENCES dbo.aspnet_Applications(ApplicationId),
        PathId            UNIQUEIDENTIFIER   PRIMARY KEY NONCLUSTERED DEFAULT NEWID(),
        Path              NVARCHAR(256)      NOT NULL,
        LoweredPath       NVARCHAR(256)      NOT NULL)
  CREATE UNIQUE CLUSTERED INDEX aspnet_Paths_index ON dbo.aspnet_Paths(ApplicationId, LoweredPath)
END


/***************************************************************************************************************************/
/***************************************************************************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Personalization_GetApplicationId')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Personalization_GetApplicationId
GO
CREATE PROCEDURE dbo.aspnet_Personalization_GetApplicationId (
    @ApplicationName NVARCHAR(256),
    @ApplicationId UNIQUEIDENTIFIER OUT)
AS
BEGIN
    SELECT @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
END
GO

/***************************************************************************************************************************/
/***************************************************************************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Paths_CreatePath')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Paths_CreatePath
GO
CREATE PROCEDURE dbo.aspnet_Paths_CreatePath
    @ApplicationId UNIQUEIDENTIFIER,
    @Path           NVARCHAR(256),
    @PathId         UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    BEGIN TRANSACTION
    IF (NOT EXISTS(SELECT * FROM dbo.aspnet_Paths WHERE LoweredPath = LOWER(@Path) AND ApplicationId = @ApplicationId))
    BEGIN
        INSERT dbo.aspnet_Paths (ApplicationId, Path, LoweredPath) VALUES (@ApplicationId, @Path, LOWER(@Path))
    END
    COMMIT TRANSACTION
    SELECT @PathId = PathId FROM dbo.aspnet_Paths WHERE LOWER(@Path) = LoweredPath AND ApplicationId = @ApplicationId
END
GO

/***************************************************************************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_PersonalizationAllUsers')
                  AND (type = 'U')))
BEGIN
  PRINT 'Creating the aspnet_PersonalizationAllUsers table...'
  CREATE TABLE dbo.aspnet_PersonalizationAllUsers (
        PathId            UNIQUEIDENTIFIER PRIMARY KEY FOREIGN KEY REFERENCES dbo.aspnet_Paths (PathId),
        PageSettings     IMAGE NOT NULL,
        LastUpdatedDate  DATETIME NOT NULL)
END


IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_PersonalizationPerUser')
                  AND (type = 'U')))
BEGIN
  PRINT 'Creating the aspnet_PersonalizationPerUser table...'
  CREATE TABLE dbo.aspnet_PersonalizationPerUser (
        Id               UNIQUEIDENTIFIER NOT NULL PRIMARY KEY NONCLUSTERED DEFAULT NEWID(),
        PathId           UNIQUEIDENTIFIER FOREIGN KEY REFERENCES dbo.aspnet_Paths (PathId),
        UserId           UNIQUEIDENTIFIER FOREIGN KEY REFERENCES dbo.aspnet_Users (UserId),
        PageSettings     IMAGE NOT NULL,
        LastUpdatedDate  DATETIME NOT NULL)
  CREATE UNIQUE CLUSTERED INDEX aspnet_PersonalizationPerUser_index1 ON [dbo].[aspnet_PersonalizationPerUser](PathId,UserId)
  CREATE UNIQUE INDEX aspnet_PersonalizationPerUser_ncindex2 ON [dbo].[aspnet_PersonalizationPerUser](UserId,PathId)
END


IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationAllUsers_GetPageSettings')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationAllUsers_GetPageSettings
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationAllUsers_GetPageSettings (
    @ApplicationName  NVARCHAR(256),
    @Path              NVARCHAR(256))
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    SELECT p.PageSettings FROM dbo.aspnet_PersonalizationAllUsers p WHERE p.PathId = @PathId
END
GO


IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationAllUsers_ResetPageSettings')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationAllUsers_ResetPageSettings
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationAllUsers_ResetPageSettings (
    @ApplicationName  NVARCHAR(256),
    @Path              NVARCHAR(256))
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    DELETE FROM dbo.aspnet_PersonalizationAllUsers WHERE PathId = @PathId
    RETURN 0
END
GO


IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationAllUsers_SetPageSettings')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationAllUsers_SetPageSettings
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationAllUsers_SetPageSettings (
    @ApplicationName  NVARCHAR(256),
    @Path             NVARCHAR(256),
    @PageSettings     IMAGE,
    @CurrentTimeUtc   DATETIME)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        EXEC dbo.aspnet_Paths_CreatePath @ApplicationId, @Path, @PathId OUTPUT
    END

    IF (EXISTS(SELECT PathId FROM dbo.aspnet_PersonalizationAllUsers WHERE PathId = @PathId))
        UPDATE dbo.aspnet_PersonalizationAllUsers SET PageSettings = @PageSettings, LastUpdatedDate = @CurrentTimeUtc WHERE PathId = @PathId
    ELSE
        INSERT INTO dbo.aspnet_PersonalizationAllUsers(PathId, PageSettings, LastUpdatedDate) VALUES (@PathId, @PageSettings, @CurrentTimeUtc)
    RETURN 0
END
GO


IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationPerUser_GetPageSettings')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationPerUser_GetPageSettings
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationPerUser_GetPageSettings (
    @ApplicationName  NVARCHAR(256),
    @UserName         NVARCHAR(256),
    @Path             NVARCHAR(256),
    @CurrentTimeUtc   DATETIME)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER
    DECLARE @UserId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL
    SELECT @UserId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @UserId = u.UserId FROM dbo.aspnet_Users u WHERE u.ApplicationId = @ApplicationId AND u.LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
    BEGIN
        RETURN
    END

    UPDATE   dbo.aspnet_Users WITH (ROWLOCK)
    SET      LastActivityDate = @CurrentTimeUtc
    WHERE    UserId = @UserId
    IF (@@ROWCOUNT = 0) -- Username not found
        RETURN

    SELECT p.PageSettings FROM dbo.aspnet_PersonalizationPerUser p WHERE p.PathId = @PathId AND p.UserId = @UserId
END
GO


IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationPerUser_ResetPageSettings')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationPerUser_ResetPageSettings
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationPerUser_ResetPageSettings (
    @ApplicationName  NVARCHAR(256),
    @UserName         NVARCHAR(256),
    @Path             NVARCHAR(256),
    @CurrentTimeUtc   DATETIME)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER
    DECLARE @UserId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL
    SELECT @UserId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @UserId = u.UserId FROM dbo.aspnet_Users u WHERE u.ApplicationId = @ApplicationId AND u.LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
    BEGIN
        RETURN
    END

    UPDATE   dbo.aspnet_Users WITH (ROWLOCK)
    SET      LastActivityDate = @CurrentTimeUtc
    WHERE    UserId = @UserId
    IF (@@ROWCOUNT = 0) -- Username not found
        RETURN

    DELETE FROM dbo.aspnet_PersonalizationPerUser WHERE PathId = @PathId AND UserId = @UserId
    RETURN 0
END
GO


IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationPerUser_SetPageSettings')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationPerUser_SetPageSettings
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationPerUser_SetPageSettings (
    @ApplicationName  NVARCHAR(256),
    @UserName         NVARCHAR(256),
    @Path             NVARCHAR(256),
    @PageSettings     IMAGE,
    @CurrentTimeUtc   DATETIME)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER
    DECLARE @UserId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL
    SELECT @UserId = NULL

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        EXEC dbo.aspnet_Paths_CreatePath @ApplicationId, @Path, @PathId OUTPUT
    END

    SELECT @UserId = u.UserId FROM dbo.aspnet_Users u WHERE u.ApplicationId = @ApplicationId AND u.LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
    BEGIN
        EXEC dbo.aspnet_Users_CreateUser @ApplicationId, @UserName, 0, @CurrentTimeUtc, @UserId OUTPUT
    END

    UPDATE   dbo.aspnet_Users WITH (ROWLOCK)
    SET      LastActivityDate = @CurrentTimeUtc
    WHERE    UserId = @UserId
    IF (@@ROWCOUNT = 0) -- Username not found
        RETURN

    IF (EXISTS(SELECT PathId FROM dbo.aspnet_PersonalizationPerUser WHERE UserId = @UserId AND PathId = @PathId))
        UPDATE dbo.aspnet_PersonalizationPerUser SET PageSettings = @PageSettings, LastUpdatedDate = @CurrentTimeUtc WHERE UserId = @UserId AND PathId = @PathId
    ELSE
        INSERT INTO dbo.aspnet_PersonalizationPerUser(UserId, PathId, PageSettings, LastUpdatedDate) VALUES (@UserId, @PathId, @PageSettings, @CurrentTimeUtc)
    RETURN 0
END
GO

/*************************************************************/
/* Personalization Administration                            */
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationAdministration_DeleteAllState')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationAdministration_DeleteAllState
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationAdministration_DeleteAllState (
    @AllUsersScope bit,
    @ApplicationName NVARCHAR(256),
    @Count int OUT)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
    BEGIN
        IF (@AllUsersScope = 1)
            DELETE FROM aspnet_PersonalizationAllUsers
            WHERE PathId IN
               (SELECT Paths.PathId
                FROM dbo.aspnet_Paths Paths
                WHERE Paths.ApplicationId = @ApplicationId)
        ELSE
            DELETE FROM aspnet_PersonalizationPerUser
            WHERE PathId IN
               (SELECT Paths.PathId
                FROM dbo.aspnet_Paths Paths
                WHERE Paths.ApplicationId = @ApplicationId)

        SELECT @Count = @@ROWCOUNT
    END
END
GO

/*************************************************************/
IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationAdministration_ResetSharedState')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationAdministration_ResetSharedState
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationAdministration_ResetSharedState (
    @Count int OUT,
    @ApplicationName NVARCHAR(256),
    @Path NVARCHAR(256))
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
    BEGIN
        DELETE FROM dbo.aspnet_PersonalizationAllUsers
        WHERE PathId IN
            (SELECT AllUsers.PathId
             FROM dbo.aspnet_PersonalizationAllUsers AllUsers, dbo.aspnet_Paths Paths
             WHERE Paths.ApplicationId = @ApplicationId
                   AND AllUsers.PathId = Paths.PathId
                   AND Paths.LoweredPath = LOWER(@Path))

        SELECT @Count = @@ROWCOUNT
    END
END
GO

/*************************************************************/
IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationAdministration_ResetUserState')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationAdministration_ResetUserState
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationAdministration_ResetUserState (
    @Count                  int                 OUT,
    @ApplicationName        NVARCHAR(256),
    @InactiveSinceDate      DATETIME            = NULL,
    @UserName               NVARCHAR(256)       = NULL,
    @Path                   NVARCHAR(256)       = NULL)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
    BEGIN
        DELETE FROM dbo.aspnet_PersonalizationPerUser
        WHERE Id IN (SELECT PerUser.Id
                     FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths
                     WHERE Paths.ApplicationId = @ApplicationId
                           AND PerUser.UserId = Users.UserId
                           AND PerUser.PathId = Paths.PathId
                           AND (@InactiveSinceDate IS NULL OR Users.LastActivityDate <= @InactiveSinceDate)
                           AND (@UserName IS NULL OR Users.LoweredUserName = LOWER(@UserName))
                           AND (@Path IS NULL OR Paths.LoweredPath = LOWER(@Path)))

        SELECT @Count = @@ROWCOUNT
    END
END
GO

/*************************************************************/
IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationAdministration_FindState')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationAdministration_FindState
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationAdministration_FindState (
    @AllUsersScope bit,
    @ApplicationName NVARCHAR(256),
    @PageIndex              INT,
    @PageSize               INT,
    @Path NVARCHAR(256) = NULL,
    @UserName NVARCHAR(256) = NULL,
    @InactiveSinceDate DATETIME = NULL)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        RETURN

    -- Set the page bounds
    DECLARE @PageLowerBound INT
    DECLARE @PageUpperBound INT
    DECLARE @TotalRecords   INT
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table to store the selected results
    CREATE TABLE #PageIndex (
        IndexId int IDENTITY (0, 1) NOT NULL,
        ItemId UNIQUEIDENTIFIER
    )

    IF (@AllUsersScope = 1)
    BEGIN
        -- Insert into our temp table
        INSERT INTO #PageIndex (ItemId)
        SELECT Paths.PathId
        FROM dbo.aspnet_Paths Paths,
             ((SELECT Paths.PathId
               FROM dbo.aspnet_PersonalizationAllUsers AllUsers, dbo.aspnet_Paths Paths
               WHERE Paths.ApplicationId = @ApplicationId
                      AND AllUsers.PathId = Paths.PathId
                      AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
              ) AS SharedDataPerPath
              FULL OUTER JOIN
              (SELECT DISTINCT Paths.PathId
               FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Paths Paths
               WHERE Paths.ApplicationId = @ApplicationId
                      AND PerUser.PathId = Paths.PathId
                      AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
              ) AS UserDataPerPath
              ON SharedDataPerPath.PathId = UserDataPerPath.PathId
             )
        WHERE Paths.PathId = SharedDataPerPath.PathId OR Paths.PathId = UserDataPerPath.PathId
        ORDER BY Paths.Path ASC

        SELECT @TotalRecords = @@ROWCOUNT

        SELECT Paths.Path,
               SharedDataPerPath.LastUpdatedDate,
               SharedDataPerPath.SharedDataLength,
               UserDataPerPath.UserDataLength,
               UserDataPerPath.UserCount
        FROM dbo.aspnet_Paths Paths,
             ((SELECT PageIndex.ItemId AS PathId,
                      AllUsers.LastUpdatedDate AS LastUpdatedDate,
                      DATALENGTH(AllUsers.PageSettings) AS SharedDataLength
               FROM dbo.aspnet_PersonalizationAllUsers AllUsers, #PageIndex PageIndex
               WHERE AllUsers.PathId = PageIndex.ItemId
                     AND PageIndex.IndexId >= @PageLowerBound AND PageIndex.IndexId <= @PageUpperBound
              ) AS SharedDataPerPath
              FULL OUTER JOIN
              (SELECT PageIndex.ItemId AS PathId,
                      SUM(DATALENGTH(PerUser.PageSettings)) AS UserDataLength,
                      COUNT(*) AS UserCount
               FROM aspnet_PersonalizationPerUser PerUser, #PageIndex PageIndex
               WHERE PerUser.PathId = PageIndex.ItemId
                     AND PageIndex.IndexId >= @PageLowerBound AND PageIndex.IndexId <= @PageUpperBound
               GROUP BY PageIndex.ItemId
              ) AS UserDataPerPath
              ON SharedDataPerPath.PathId = UserDataPerPath.PathId
             )
        WHERE Paths.PathId = SharedDataPerPath.PathId OR Paths.PathId = UserDataPerPath.PathId
        ORDER BY Paths.Path ASC
    END
    ELSE
    BEGIN
        -- Insert into our temp table
        INSERT INTO #PageIndex (ItemId)
        SELECT PerUser.Id
        FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths
        WHERE Paths.ApplicationId = @ApplicationId
              AND PerUser.UserId = Users.UserId
              AND PerUser.PathId = Paths.PathId
              AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
              AND (@UserName IS NULL OR Users.LoweredUserName LIKE LOWER(@UserName))
              AND (@InactiveSinceDate IS NULL OR Users.LastActivityDate <= @InactiveSinceDate)
        ORDER BY Paths.Path ASC, Users.UserName ASC

        SELECT @TotalRecords = @@ROWCOUNT

        SELECT Paths.Path, PerUser.LastUpdatedDate, DATALENGTH(PerUser.PageSettings), Users.UserName, Users.LastActivityDate
        FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths, #PageIndex PageIndex
        WHERE PerUser.Id = PageIndex.ItemId
              AND PerUser.UserId = Users.UserId
              AND PerUser.PathId = Paths.PathId
              AND PageIndex.IndexId >= @PageLowerBound AND PageIndex.IndexId <= @PageUpperBound
        ORDER BY Paths.Path ASC, Users.UserName ASC
    END

    RETURN @TotalRecords
END
GO

/*************************************************************/
IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_PersonalizationAdministration_GetCountOfState')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_PersonalizationAdministration_GetCountOfState
GO
CREATE PROCEDURE dbo.aspnet_PersonalizationAdministration_GetCountOfState (
    @Count int OUT,
    @AllUsersScope bit,
    @ApplicationName NVARCHAR(256),
    @Path NVARCHAR(256) = NULL,
    @UserName NVARCHAR(256) = NULL,
    @InactiveSinceDate DATETIME = NULL)
AS
BEGIN

    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
        IF (@AllUsersScope = 1)
            SELECT @Count = COUNT(*)
            FROM dbo.aspnet_PersonalizationAllUsers AllUsers, dbo.aspnet_Paths Paths
            WHERE Paths.ApplicationId = @ApplicationId
                  AND AllUsers.PathId = Paths.PathId
                  AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
        ELSE
            SELECT @Count = COUNT(*)
            FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths
            WHERE Paths.ApplicationId = @ApplicationId
                  AND PerUser.UserId = Users.UserId
                  AND PerUser.PathId = Paths.PathId
                  AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
                  AND (@UserName IS NULL OR Users.LoweredUserName LIKE LOWER(@UserName))
                  AND (@InactiveSinceDate IS NULL OR Users.LastActivityDate <= @InactiveSinceDate)
END
GO

/*************************************************************/
/*************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'vw_aspnet_WebPartState_Paths')
                  AND (type = 'V')))
BEGIN
  PRINT 'Creating the vw_aspnet_WebPartState_Paths view...'
  EXEC(N'
  CREATE VIEW [dbo].[vw_aspnet_WebPartState_Paths]
  AS SELECT [dbo].[aspnet_Paths].[ApplicationId], [dbo].[aspnet_Paths].[PathId], [dbo].[aspnet_Paths].[Path], [dbo].[aspnet_Paths].[LoweredPath]
  FROM [dbo].[aspnet_Paths]
  ')
END

/*************************************************************/
/*************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'vw_aspnet_WebPartState_Shared')
                  AND (type = 'V')))
BEGIN
  PRINT 'Creating the vw_aspnet_WebPartState_Shared view...'
  EXEC(N'
  CREATE VIEW [dbo].[vw_aspnet_WebPartState_Shared]
  AS SELECT [dbo].[aspnet_PersonalizationAllUsers].[PathId], [DataSize]=DATALENGTH([dbo].[aspnet_PersonalizationAllUsers].[PageSettings]), [dbo].[aspnet_PersonalizationAllUsers].[LastUpdatedDate]
  FROM [dbo].[aspnet_PersonalizationAllUsers]
  ')
END

/*************************************************************/
/*************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'vw_aspnet_WebPartState_User')
                  AND (type = 'V')))
BEGIN
  PRINT 'Creating the vw_aspnet_WebPartState_User view...'
  EXEC(N'
  CREATE VIEW [dbo].[vw_aspnet_WebPartState_User]
  AS SELECT [dbo].[aspnet_PersonalizationPerUser].[PathId], [dbo].[aspnet_PersonalizationPerUser].[UserId], [DataSize]=DATALENGTH([dbo].[aspnet_PersonalizationPerUser].[PageSettings]), [dbo].[aspnet_PersonalizationPerUser].[LastUpdatedDate]
  FROM [dbo].[aspnet_PersonalizationPerUser]
  ')
END
GO

/*************************************************************/
/*************************************************************/

--
--Create Personalization schema version
--

DECLARE @command nvarchar(4000)
SET @command = 'GRANT EXECUTE ON [dbo].aspnet_RegisterSchemaVersion TO ' + QUOTENAME(user)
EXECUTE (@command)
GO

EXEC [dbo].aspnet_RegisterSchemaVersion N'Personalization', N'1', 1, 1
GO

/*************************************************************/
/*************************************************************/

--
--Create Personalization roles
--

IF ( NOT EXISTS ( SELECT name
                  FROM sysusers
                  WHERE issqlrole = 1
                  AND name = N'aspnet_Personalization_FullAccess'  ) )
EXEC sp_addrole N'aspnet_Personalization_FullAccess'

IF ( NOT EXISTS ( SELECT name
                  FROM dbo.sysusers
                  WHERE issqlrole = 1
                  AND name = N'aspnet_Personalization_BasicAccess'  ) )
EXEC sp_addrole N'aspnet_Personalization_BasicAccess'

IF ( NOT EXISTS ( SELECT name
                  FROM sysusers
                  WHERE issqlrole = 1
                  AND name = N'aspnet_Personalization_ReportingAccess'  ) )
EXEC sp_addrole N'aspnet_Personalization_ReportingAccess'
GO

EXEC sp_addrolemember N'aspnet_Personalization_BasicAccess', N'aspnet_Personalization_FullAccess'
EXEC sp_addrolemember N'aspnet_Personalization_ReportingAccess', N'aspnet_Personalization_FullAccess'
GO

--
--Stored Procedure rights for BasicAccess
--
GRANT EXECUTE ON dbo.aspnet_Paths_CreatePath TO aspnet_Personalization_BasicAccess

GRANT EXECUTE ON dbo.aspnet_PersonalizationAllUsers_GetPageSettings TO aspnet_Personalization_BasicAccess
GRANT EXECUTE ON dbo.aspnet_PersonalizationPerUser_GetPageSettings TO aspnet_Personalization_BasicAccess
GRANT EXECUTE ON dbo.aspnet_PersonalizationAllUsers_ResetPageSettings TO aspnet_Personalization_BasicAccess
GRANT EXECUTE ON dbo.aspnet_PersonalizationPerUser_ResetPageSettings TO aspnet_Personalization_BasicAccess
GRANT EXECUTE ON dbo.aspnet_PersonalizationAllUsers_SetPageSettings TO aspnet_Personalization_BasicAccess
GRANT EXECUTE ON dbo.aspnet_PersonalizationPerUser_SetPageSettings TO aspnet_Personalization_BasicAccess

GRANT EXECUTE ON dbo.aspnet_Personalization_GetApplicationId TO aspnet_Personalization_BasicAccess

GRANT EXECUTE ON dbo.aspnet_CheckSchemaVersion TO aspnet_Personalization_BasicAccess
GRANT EXECUTE ON dbo.aspnet_RegisterSchemaVersion TO aspnet_Personalization_BasicAccess
GRANT EXECUTE ON dbo.aspnet_UnRegisterSchemaVersion TO aspnet_Personalization_BasicAccess

--
--Stored Procedure rights for ReportingAccess
--
GRANT EXECUTE ON dbo.aspnet_PersonalizationAdministration_FindState TO aspnet_Personalization_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_PersonalizationAdministration_GetCountOfState TO aspnet_Personalization_ReportingAccess

GRANT EXECUTE ON dbo.aspnet_CheckSchemaVersion TO aspnet_Personalization_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_RegisterSchemaVersion TO aspnet_Personalization_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_UnRegisterSchemaVersion TO aspnet_Personalization_ReportingAccess

--
--Additional stored procedure rights for FullAccess
--
GRANT EXECUTE ON dbo.aspnet_PersonalizationAdministration_ResetUserState TO aspnet_Personalization_FullAccess
GRANT EXECUTE ON dbo.aspnet_PersonalizationAdministration_ResetSharedState TO aspnet_Personalization_FullAccess
GRANT EXECUTE ON dbo.aspnet_PersonalizationAdministration_DeleteAllState TO aspnet_Personalization_FullAccess

--
--View rights
--
GRANT SELECT ON dbo.vw_aspnet_Applications TO aspnet_Personalization_ReportingAccess
GRANT SELECT ON dbo.vw_aspnet_Users TO aspnet_Personalization_ReportingAccess

GRANT SELECT ON dbo.vw_aspnet_WebPartState_Paths TO aspnet_Personalization_ReportingAccess
GRANT SELECT ON dbo.vw_aspnet_WebPartState_Shared TO aspnet_Personalization_ReportingAccess
GRANT SELECT ON dbo.vw_aspnet_WebPartState_User TO aspnet_Personalization_ReportingAccess
GO
-------------------------------------------------------------------------
--- Version specific install
-------------------------------------------------------------------------

DECLARE @ver INT
DECLARE @version NCHAR(100)
DECLARE @dot INT
DECLARE @hyphen INT
DECLARE @SqlToExec NCHAR(400)

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
        SELECT @ver     = CONVERT(INT, @version)
    END
END

IF (@ver >= 8)
BEGIN
    EXEC sp_tableoption N'aspnet_PersonalizationAllUsers', 'text in row', 6000
    EXEC sp_tableoption N'aspnet_PersonalizationPerUser', 'text in row', 6000
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
PRINT 'Completed execution of InstallPersonalization.SQL'
PRINT '-------------------------------------------------'
