/**********************************************************************/
/* InstallRoles.SQL                                                   */
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

PRINT '--------------------------------------'
PRINT 'Starting execution of InstallRoles.SQL'
PRINT '--------------------------------------'
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

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_Roles')
                  AND (type = 'U')))
BEGIN
  PRINT 'Creating the aspnet_Roles table...'
  CREATE TABLE dbo.aspnet_Roles (
        ApplicationId    uniqueidentifier    NOT NULL FOREIGN KEY REFERENCES dbo.aspnet_Applications(ApplicationId),
        RoleId           uniqueidentifier    PRIMARY KEY  NONCLUSTERED DEFAULT NEWID(),
        RoleName         nvarchar(256)       NOT NULL,
        LoweredRoleName  nvarchar(256)       NOT NULL,
        Description      nvarchar(256)       )
 CREATE UNIQUE  CLUSTERED  INDEX aspnet_Roles_index1 ON  dbo.aspnet_Roles(ApplicationId, LoweredRoleName)
END
GO

/*************************************************************/
/*************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'aspnet_UsersInRoles')
                  AND (type = 'U')))
BEGIN
  PRINT 'Creating the aspnet_UsersInRoles table...'
  CREATE TABLE dbo.aspnet_UsersInRoles (
        UserId     uniqueidentifier NOT NULL PRIMARY KEY(UserId, RoleId) FOREIGN KEY REFERENCES dbo.aspnet_Users (UserId),
        RoleId     uniqueidentifier NOT NULL FOREIGN KEY REFERENCES dbo.aspnet_Roles (RoleId))

  CREATE INDEX aspnet_UsersInRoles_index ON  dbo.aspnet_UsersInRoles(RoleId)
END


/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_UsersInRoles_IsUserInRole')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_UsersInRoles_IsUserInRole
GO

CREATE PROCEDURE dbo.aspnet_UsersInRoles_IsUserInRole
    @ApplicationName  nvarchar(256),
    @UserName         nvarchar(256),
    @RoleName         nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(2)
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    DECLARE @RoleId uniqueidentifier
    SELECT  @RoleId = NULL

    SELECT  @UserId = UserId
    FROM    dbo.aspnet_Users
    WHERE   LoweredUserName = LOWER(@UserName) AND ApplicationId = @ApplicationId

    IF (@UserId IS NULL)
        RETURN(2)

    SELECT  @RoleId = RoleId
    FROM    dbo.aspnet_Roles
    WHERE   LoweredRoleName = LOWER(@RoleName) AND ApplicationId = @ApplicationId

    IF (@RoleId IS NULL)
        RETURN(3)

    IF (EXISTS( SELECT * FROM dbo.aspnet_UsersInRoles WHERE  UserId = @UserId AND RoleId = @RoleId))
        RETURN(1)
    ELSE
        RETURN(0)
END
GO

/*************************************************************/
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_UsersInRoles_GetRolesForUser')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_UsersInRoles_GetRolesForUser
GO

CREATE PROCEDURE dbo.aspnet_UsersInRoles_GetRolesForUser
    @ApplicationName  nvarchar(256),
    @UserName         nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(1)
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL

    SELECT  @UserId = UserId
    FROM    dbo.aspnet_Users
    WHERE   LoweredUserName = LOWER(@UserName) AND ApplicationId = @ApplicationId

    IF (@UserId IS NULL)
        RETURN(1)

    SELECT r.RoleName
    FROM   dbo.aspnet_Roles r, dbo.aspnet_UsersInRoles ur
    WHERE  r.RoleId = ur.RoleId AND r.ApplicationId = @ApplicationId AND ur.UserId = @UserId
    ORDER BY r.RoleName
    RETURN (0)
END
GO

/*************************************************************/
/*************************************************************/
IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Roles_CreateRole')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Roles_CreateRole
GO
CREATE PROCEDURE dbo.aspnet_Roles_CreateRole
    @ApplicationName  nvarchar(256),
    @RoleName         nvarchar(256)
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

    IF (EXISTS(SELECT RoleId FROM dbo.aspnet_Roles WHERE LoweredRoleName = LOWER(@RoleName) AND ApplicationId = @ApplicationId))
    BEGIN
        SET @ErrorCode = 1
        GOTO Cleanup
    END

    INSERT INTO dbo.aspnet_Roles
                (ApplicationId, RoleName, LoweredRoleName)
         VALUES (@ApplicationId, @RoleName, LOWER(@RoleName))

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

    RETURN(0)

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
             WHERE (name = N'aspnet_Roles_DeleteRole')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Roles_DeleteRole
GO

CREATE PROCEDURE dbo.aspnet_Roles_DeleteRole
    @ApplicationName            nvarchar(256),
    @RoleName                   nvarchar(256),
    @DeleteOnlyIfRoleIsEmpty    bit
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(1)

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

    DECLARE @RoleId   uniqueidentifier
    SELECT  @RoleId = NULL
    SELECT  @RoleId = RoleId FROM dbo.aspnet_Roles WHERE LoweredRoleName = LOWER(@RoleName) AND ApplicationId = @ApplicationId

    IF (@RoleId IS NULL)
    BEGIN
        SELECT @ErrorCode = 1
        GOTO Cleanup
    END
    IF (@DeleteOnlyIfRoleIsEmpty <> 0)
    BEGIN
        IF (EXISTS (SELECT RoleId FROM dbo.aspnet_UsersInRoles  WHERE @RoleId = RoleId))
        BEGIN
            SELECT @ErrorCode = 2
            GOTO Cleanup
        END
    END


    DELETE FROM dbo.aspnet_UsersInRoles  WHERE @RoleId = RoleId

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    DELETE FROM dbo.aspnet_Roles WHERE @RoleId = RoleId  AND ApplicationId = @ApplicationId

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

    RETURN(0)

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
             WHERE (name = N'aspnet_Roles_RoleExists')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Roles_RoleExists
GO

CREATE PROCEDURE dbo.aspnet_Roles_RoleExists
    @ApplicationName  nvarchar(256),
    @RoleName         nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(0)
    IF (EXISTS (SELECT RoleName FROM dbo.aspnet_Roles WHERE LOWER(@RoleName) = LoweredRoleName AND ApplicationId = @ApplicationId ))
        RETURN(1)
    ELSE
        RETURN(0)
END
GO

/*************************************************************/
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_UsersInRoles_AddUsersToRoles')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_UsersInRoles_AddUsersToRoles
GO
IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_UsersInRoles_RemoveUsersFromRoles')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_UsersInRoles_RemoveUsersFromRoles
GO

DECLARE @ver            int
DECLARE @version        nchar(100)
DECLARE @dot            int
DECLARE @hyphen         int
DECLARE @SqlToExec      nchar(4000)

SELECT @ver = 7
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

IF (@ver > 7)
SELECT @SqlToExec = N'
CREATE PROCEDURE dbo.aspnet_UsersInRoles_AddUsersToRoles
	@ApplicationName  nvarchar(256),
	@UserNames		  nvarchar(4000),
	@RoleNames		  nvarchar(4000),
	@CurrentTimeUtc   datetime
AS
BEGIN
	DECLARE @AppId uniqueidentifier
	SELECT  @AppId = NULL
	SELECT  @AppId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
	IF (@AppId IS NULL)
		RETURN(2)
	DECLARE @TranStarted   bit
	SET @TranStarted = 0

	IF( @@TRANCOUNT = 0 )
	BEGIN
		BEGIN TRANSACTION
		SET @TranStarted = 1
	END

	DECLARE @tbNames	table(Name nvarchar(256) NOT NULL PRIMARY KEY)
	DECLARE @tbRoles	table(RoleId uniqueidentifier NOT NULL PRIMARY KEY)
	DECLARE @tbUsers	table(UserId uniqueidentifier NOT NULL PRIMARY KEY)
	DECLARE @Num		int
	DECLARE @Pos		int
	DECLARE @NextPos	int
	DECLARE @Name		nvarchar(256)

	SET @Num = 0
	SET @Pos = 1
	WHILE(@Pos <= LEN(@RoleNames))
	BEGIN
		SELECT @NextPos = CHARINDEX(N'','', @RoleNames,  @Pos)
		IF (@NextPos = 0 OR @NextPos IS NULL)
			SELECT @NextPos = LEN(@RoleNames) + 1
		SELECT @Name = RTRIM(LTRIM(SUBSTRING(@RoleNames, @Pos, @NextPos - @Pos)))
		SELECT @Pos = @NextPos+1

		INSERT INTO @tbNames VALUES (@Name)
		SET @Num = @Num + 1
	END

	INSERT INTO @tbRoles
	  SELECT RoleId
	  FROM   dbo.aspnet_Roles ar, @tbNames t
	  WHERE  LOWER(t.Name) = ar.LoweredRoleName AND ar.ApplicationId = @AppId

	IF (@@ROWCOUNT <> @Num)
	BEGIN
		SELECT TOP 1 Name
		FROM   @tbNames
		WHERE  LOWER(Name) NOT IN (SELECT ar.LoweredRoleName FROM dbo.aspnet_Roles ar,  @tbRoles r WHERE r.RoleId = ar.RoleId)
		IF( @TranStarted = 1 )
			ROLLBACK TRANSACTION
		RETURN(2)
	END

	DELETE FROM @tbNames WHERE 1=1
	SET @Num = 0
	SET @Pos = 1

	WHILE(@Pos <= LEN(@UserNames))
	BEGIN
		SELECT @NextPos = CHARINDEX(N'','', @UserNames,  @Pos)
		IF (@NextPos = 0 OR @NextPos IS NULL)
			SELECT @NextPos = LEN(@UserNames) + 1
		SELECT @Name = RTRIM(LTRIM(SUBSTRING(@UserNames, @Pos, @NextPos - @Pos)))
		SELECT @Pos = @NextPos+1

		INSERT INTO @tbNames VALUES (@Name)
		SET @Num = @Num + 1
	END

	INSERT INTO @tbUsers
	  SELECT UserId
	  FROM   dbo.aspnet_Users ar, @tbNames t
	  WHERE  LOWER(t.Name) = ar.LoweredUserName AND ar.ApplicationId = @AppId

	IF (@@ROWCOUNT <> @Num)
	BEGIN
		DELETE FROM @tbNames
		WHERE LOWER(Name) IN (SELECT LoweredUserName FROM dbo.aspnet_Users au,  @tbUsers u WHERE au.UserId = u.UserId)

		INSERT dbo.aspnet_Users (ApplicationId, UserId, UserName, LoweredUserName, IsAnonymous, LastActivityDate)
		  SELECT @AppId, NEWID(), Name, LOWER(Name), 0, @CurrentTimeUtc
		  FROM   @tbNames

		INSERT INTO @tbUsers
		  SELECT  UserId
		  FROM	dbo.aspnet_Users au, @tbNames t
		  WHERE   LOWER(t.Name) = au.LoweredUserName AND au.ApplicationId = @AppId
	END

	IF (EXISTS (SELECT * FROM dbo.aspnet_UsersInRoles ur, @tbUsers tu, @tbRoles tr WHERE tu.UserId = ur.UserId AND tr.RoleId = ur.RoleId))
	BEGIN
		SELECT TOP 1 UserName, RoleName
		FROM		 dbo.aspnet_UsersInRoles ur, @tbUsers tu, @tbRoles tr, aspnet_Users u, aspnet_Roles r
		WHERE		u.UserId = tu.UserId AND r.RoleId = tr.RoleId AND tu.UserId = ur.UserId AND tr.RoleId = ur.RoleId

		IF( @TranStarted = 1 )
			ROLLBACK TRANSACTION
		RETURN(3)
	END

	INSERT INTO dbo.aspnet_UsersInRoles (UserId, RoleId)
	SELECT UserId, RoleId
	FROM @tbUsers, @tbRoles

	IF( @TranStarted = 1 )
		COMMIT TRANSACTION
	RETURN(0)
END'
ELSE
SELECT @SqlToExec = N'
CREATE PROCEDURE dbo.aspnet_UsersInRoles_AddUsersToRoles
	@ApplicationName	nvarchar(256),
	@UserNames			nvarchar(4000),
	@RoleNames			nvarchar(4000),
	@CurrentTimeUtc		datetime
AS
BEGIN
	DECLARE @AppId uniqueidentifier
	SELECT  @AppId = NULL
	SELECT  @AppId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
	IF (@AppId IS NULL)
		RETURN(2)

	DECLARE @TranStarted   bit
	SET @TranStarted = 0
	IF( @@TRANCOUNT = 0 )
	BEGIN
		BEGIN TRANSACTION
		SET @TranStarted = 1
	END

	DECLARE @RoleId		uniqueidentifier
	DECLARE @UserId		uniqueidentifier
	DECLARE @UserName	nvarchar(256)
	DECLARE @RoleName	nvarchar(256)

	DECLARE @CurrentPosU	int
	DECLARE @NextPosU		int
	DECLARE @CurrentPosR	int
	DECLARE @NextPosR		int

	SELECT  @CurrentPosU = 1

	WHILE(@CurrentPosU <= LEN(@UserNames))
	BEGIN
		SELECT @NextPosU = CHARINDEX(N'','', @UserNames,  @CurrentPosU)
		IF (@NextPosU = 0 OR @NextPosU IS NULL)
			SELECT @NextPosU = LEN(@UserNames) + 1

		SELECT @UserName = SUBSTRING(@UserNames, @CurrentPosU, @NextPosU - @CurrentPosU)
		SELECT @CurrentPosU = @NextPosU+1

		SELECT @CurrentPosR = 1
		WHILE(@CurrentPosR <= LEN(@RoleNames))
		BEGIN
			SELECT @NextPosR = CHARINDEX(N'','', @RoleNames,  @CurrentPosR)
			IF (@NextPosR = 0 OR @NextPosR IS NULL)
				SELECT @NextPosR = LEN(@RoleNames) + 1
			SELECT @RoleName = SUBSTRING(@RoleNames, @CurrentPosR, @NextPosR - @CurrentPosR)
			SELECT @CurrentPosR = @NextPosR+1
			SELECT @RoleId = NULL
			SELECT @RoleId = RoleId FROM dbo.aspnet_Roles WHERE LoweredRoleName = LOWER(@RoleName) AND ApplicationId = @AppId
			IF (@RoleId IS NULL)
			BEGIN
				SELECT @RoleName
				IF( @TranStarted = 1 )
					ROLLBACK TRANSACTION
				RETURN(2)
			END

			SELECT @UserId = NULL
			SELECT @UserId = UserId FROM dbo.aspnet_Users WHERE LoweredUserName = LOWER(@UserName) AND ApplicationId = @AppId
			IF (@UserId IS NULL)
			BEGIN
				EXEC dbo.aspnet_Users_CreateUser @AppId, @UserName, 0, @CurrentTimeUtc, @UserId OUTPUT
			END

			IF (EXISTS(SELECT * FROM dbo.aspnet_UsersInRoles WHERE @UserId = UserId AND @RoleId = RoleId))
			BEGIN
				SELECT @UserName, @RoleName
				IF( @TranStarted = 1 )
					ROLLBACK TRANSACTION
				RETURN(3)
			END
			INSERT INTO dbo.aspnet_UsersInRoles (UserId, RoleId) VALUES(@UserId, @RoleId)
		END
	END
	IF( @TranStarted = 1 )
		COMMIT TRANSACTION
	RETURN(0)
END'

EXEC sp_executesql @SqlToExec

IF (@ver > 7)
SELECT @SqlToExec = N'
CREATE PROCEDURE dbo.aspnet_UsersInRoles_RemoveUsersFromRoles
	@ApplicationName  nvarchar(256),
	@UserNames		  nvarchar(4000),
	@RoleNames		  nvarchar(4000)
AS
BEGIN
	DECLARE @AppId uniqueidentifier
	SELECT  @AppId = NULL
	SELECT  @AppId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
	IF (@AppId IS NULL)
		RETURN(2)


	DECLARE @TranStarted   bit
	SET @TranStarted = 0

	IF( @@TRANCOUNT = 0 )
	BEGIN
		BEGIN TRANSACTION
		SET @TranStarted = 1
	END

	DECLARE @tbNames  table(Name nvarchar(256) NOT NULL PRIMARY KEY)
	DECLARE @tbRoles  table(RoleId uniqueidentifier NOT NULL PRIMARY KEY)
	DECLARE @tbUsers  table(UserId uniqueidentifier NOT NULL PRIMARY KEY)
	DECLARE @Num	  int
	DECLARE @Pos	  int
	DECLARE @NextPos  int
	DECLARE @Name	  nvarchar(256)
	DECLARE @CountAll int
	DECLARE @CountU	  int
	DECLARE @CountR	  int


	SET @Num = 0
	SET @Pos = 1
	WHILE(@Pos <= LEN(@RoleNames))
	BEGIN
		SELECT @NextPos = CHARINDEX(N'','', @RoleNames,  @Pos)
		IF (@NextPos = 0 OR @NextPos IS NULL)
			SELECT @NextPos = LEN(@RoleNames) + 1
		SELECT @Name = RTRIM(LTRIM(SUBSTRING(@RoleNames, @Pos, @NextPos - @Pos)))
		SELECT @Pos = @NextPos+1

		INSERT INTO @tbNames VALUES (@Name)
		SET @Num = @Num + 1
	END

	INSERT INTO @tbRoles
	  SELECT RoleId
	  FROM   dbo.aspnet_Roles ar, @tbNames t
	  WHERE  LOWER(t.Name) = ar.LoweredRoleName AND ar.ApplicationId = @AppId
	SELECT @CountR = @@ROWCOUNT

	IF (@CountR <> @Num)
	BEGIN
		SELECT TOP 1 N'''', Name
		FROM   @tbNames
		WHERE  LOWER(Name) NOT IN (SELECT ar.LoweredRoleName FROM dbo.aspnet_Roles ar,  @tbRoles r WHERE r.RoleId = ar.RoleId)
		IF( @TranStarted = 1 )
			ROLLBACK TRANSACTION
		RETURN(2)
	END


	DELETE FROM @tbNames WHERE 1=1
	SET @Num = 0
	SET @Pos = 1


	WHILE(@Pos <= LEN(@UserNames))
	BEGIN
		SELECT @NextPos = CHARINDEX(N'','', @UserNames,  @Pos)
		IF (@NextPos = 0 OR @NextPos IS NULL)
			SELECT @NextPos = LEN(@UserNames) + 1
		SELECT @Name = RTRIM(LTRIM(SUBSTRING(@UserNames, @Pos, @NextPos - @Pos)))
		SELECT @Pos = @NextPos+1

		INSERT INTO @tbNames VALUES (@Name)
		SET @Num = @Num + 1
	END

	INSERT INTO @tbUsers
	  SELECT UserId
	  FROM   dbo.aspnet_Users ar, @tbNames t
	  WHERE  LOWER(t.Name) = ar.LoweredUserName AND ar.ApplicationId = @AppId

	SELECT @CountU = @@ROWCOUNT
	IF (@CountU <> @Num)
	BEGIN
		SELECT TOP 1 Name, N''''
		FROM   @tbNames
		WHERE  LOWER(Name) NOT IN (SELECT au.LoweredUserName FROM dbo.aspnet_Users au,  @tbUsers u WHERE u.UserId = au.UserId)

		IF( @TranStarted = 1 )
			ROLLBACK TRANSACTION
		RETURN(1)
	END

	SELECT  @CountAll = COUNT(*)
	FROM	dbo.aspnet_UsersInRoles ur, @tbUsers u, @tbRoles r
	WHERE   ur.UserId = u.UserId AND ur.RoleId = r.RoleId

	IF (@CountAll <> @CountU * @CountR)
	BEGIN
		SELECT TOP 1 UserName, RoleName
		FROM		 @tbUsers tu, @tbRoles tr, dbo.aspnet_Users u, dbo.aspnet_Roles r
		WHERE		 u.UserId = tu.UserId AND r.RoleId = tr.RoleId AND
					 tu.UserId NOT IN (SELECT ur.UserId FROM dbo.aspnet_UsersInRoles ur WHERE ur.RoleId = tr.RoleId) AND
					 tr.RoleId NOT IN (SELECT ur.RoleId FROM dbo.aspnet_UsersInRoles ur WHERE ur.UserId = tu.UserId)
		IF( @TranStarted = 1 )
			ROLLBACK TRANSACTION
		RETURN(3)
	END

	DELETE FROM dbo.aspnet_UsersInRoles
	WHERE UserId IN (SELECT UserId FROM @tbUsers)
	  AND RoleId IN (SELECT RoleId FROM @tbRoles)
	IF( @TranStarted = 1 )
		COMMIT TRANSACTION
	RETURN(0)
END
'
ELSE
SELECT @SqlToExec = N'
CREATE PROCEDURE dbo.aspnet_UsersInRoles_RemoveUsersFromRoles
	@ApplicationName  nvarchar(256),
	@UserNames		  nvarchar(4000),
	@RoleNames		  nvarchar(4000)
AS
BEGIN
	DECLARE @AppId uniqueidentifier
	SELECT  @AppId = NULL
	SELECT  @AppId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
	IF (@AppId IS NULL)
		RETURN(2)


	DECLARE @TranStarted   bit
	SET @TranStarted = 0

	IF( @@TRANCOUNT = 0 )
	BEGIN
		BEGIN TRANSACTION
		SET @TranStarted = 1
	END

	DECLARE @RoleId		uniqueidentifier
	DECLARE @UserId		uniqueidentifier
	DECLARE @UserName	nvarchar(256)
	DECLARE @RoleName	nvarchar(256)

	DECLARE @CurrentPosU	int
	DECLARE @NextPosU		int
	DECLARE @CurrentPosR	int
	DECLARE @NextPosR		int

	SELECT  @CurrentPosU = 1

	WHILE(@CurrentPosU <= LEN(@UserNames))
	BEGIN
		SELECT @NextPosU = CHARINDEX(N'','', @UserNames,  @CurrentPosU)
		IF (@NextPosU = 0  OR @NextPosU IS NULL)
			SELECT @NextPosU = LEN(@UserNames)+1
		SELECT @UserName = SUBSTRING(@UserNames, @CurrentPosU, @NextPosU - @CurrentPosU)
		SELECT @CurrentPosU = @NextPosU+1

		SELECT @CurrentPosR = 1
		WHILE(@CurrentPosR <= LEN(@RoleNames))
		BEGIN
			SELECT @NextPosR = CHARINDEX(N'','', @RoleNames,  @CurrentPosR)
			IF (@NextPosR = 0 OR @NextPosR IS NULL)
				SELECT @NextPosR = LEN(@RoleNames)+1
			SELECT @RoleName = SUBSTRING(@RoleNames, @CurrentPosR, @NextPosR - @CurrentPosR)
			SELECT @CurrentPosR = @NextPosR+1

			SELECT @RoleId = NULL
			SELECT @RoleId = RoleId FROM dbo.aspnet_Roles WHERE LoweredRoleName = LOWER(@RoleName) AND ApplicationId = @AppId
			IF (@RoleId IS NULL)
			BEGIN
				SELECT N'''', @RoleName
				IF( @TranStarted = 1 )
					ROLLBACK TRANSACTION
				RETURN(2)
			END

			SELECT @UserId = NULL
			SELECT @UserId = UserId FROM dbo.aspnet_Users WHERE LoweredUserName = LOWER(@UserName) AND ApplicationId = @AppId
			IF (@UserId IS NULL)
			BEGIN
				SELECT @UserName, N''''
				IF( @TranStarted = 1 )
					ROLLBACK TRANSACTION
				RETURN(1)
			END

			IF (NOT(EXISTS(SELECT * FROM dbo.aspnet_UsersInRoles WHERE @UserId = UserId AND @RoleId = RoleId)))
			BEGIN
				SELECT @UserName, @RoleName
				IF( @TranStarted = 1 )
					ROLLBACK TRANSACTION
				RETURN(3)
			END
			DELETE FROM dbo.aspnet_UsersInRoles WHERE (UserId = @UserId AND RoleId = @RoleId)
		END
	END
	IF( @TranStarted = 1 )
		COMMIT TRANSACTION
	RETURN(0)
END
'
EXEC sp_executesql @SqlToExec
GO
/*************************************************************/
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_UsersInRoles_GetUsersInRoles')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_UsersInRoles_GetUsersInRoles
GO

CREATE PROCEDURE dbo.aspnet_UsersInRoles_GetUsersInRoles
    @ApplicationName  nvarchar(256),
    @RoleName         nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(1)
     DECLARE @RoleId uniqueidentifier
     SELECT  @RoleId = NULL

     SELECT  @RoleId = RoleId
     FROM    dbo.aspnet_Roles
     WHERE   LOWER(@RoleName) = LoweredRoleName AND ApplicationId = @ApplicationId

     IF (@RoleId IS NULL)
         RETURN(1)

    SELECT u.UserName
    FROM   dbo.aspnet_Users u, dbo.aspnet_UsersInRoles ur
    WHERE  u.UserId = ur.UserId AND @RoleId = ur.RoleId AND u.ApplicationId = @ApplicationId
    ORDER BY u.UserName
    RETURN(0)
END
GO

/*************************************************************/
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_UsersInRoles_FindUsersInRole')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_UsersInRoles_FindUsersInRole
GO

CREATE PROCEDURE dbo.aspnet_UsersInRoles_FindUsersInRole
    @ApplicationName  nvarchar(256),
    @RoleName         nvarchar(256),
    @UserNameToMatch  nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(1)
     DECLARE @RoleId uniqueidentifier
     SELECT  @RoleId = NULL

     SELECT  @RoleId = RoleId
     FROM    dbo.aspnet_Roles
     WHERE   LOWER(@RoleName) = LoweredRoleName AND ApplicationId = @ApplicationId

     IF (@RoleId IS NULL)
         RETURN(1)

    SELECT u.UserName
    FROM   dbo.aspnet_Users u, dbo.aspnet_UsersInRoles ur
    WHERE  u.UserId = ur.UserId AND @RoleId = ur.RoleId AND u.ApplicationId = @ApplicationId AND LoweredUserName LIKE LOWER(@UserNameToMatch)
    ORDER BY u.UserName
    RETURN(0)
END
GO

/*************************************************************/
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_Roles_GetAllRoles')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_Roles_GetAllRoles
GO

CREATE PROCEDURE dbo.aspnet_Roles_GetAllRoles (
    @ApplicationName           nvarchar(256))
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN
    SELECT RoleName
    FROM   dbo.aspnet_Roles WHERE ApplicationId = @ApplicationId
    ORDER BY RoleName
END
GO

/*************************************************************/
/*************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'vw_aspnet_Roles')
                  AND (type = 'V')))
BEGIN
  PRINT 'Creating the vw_aspnet_Roles view...'
  EXEC(N'
  CREATE VIEW [dbo].[vw_aspnet_Roles]
  AS SELECT [dbo].[aspnet_Roles].[ApplicationId], [dbo].[aspnet_Roles].[RoleId], [dbo].[aspnet_Roles].[RoleName], [dbo].[aspnet_Roles].[LoweredRoleName], [dbo].[aspnet_Roles].[Description]
  FROM [dbo].[aspnet_Roles]
  ')
END
GO

/*************************************************************/
/*************************************************************/

IF (NOT EXISTS (SELECT name
                FROM sysobjects
                WHERE (name = N'vw_aspnet_UsersInRoles')
                  AND (type = 'V')))
BEGIN
  PRINT 'Creating the vw_aspnet_UsersInRoles view...'
  EXEC(N'
  CREATE VIEW [dbo].[vw_aspnet_UsersInRoles]
  AS SELECT [dbo].[aspnet_UsersInRoles].[UserId], [dbo].[aspnet_UsersInRoles].[RoleId]
  FROM [dbo].[aspnet_UsersInRoles]
  ')
END
GO

/*************************************************************/
/*************************************************************/

--
--Create Role Manager schema version
--

DECLARE @command nvarchar(4000)
SET @command = 'GRANT EXECUTE ON [dbo].aspnet_RegisterSchemaVersion TO ' + QUOTENAME(user)
EXECUTE (@command)
GO

EXEC [dbo].aspnet_RegisterSchemaVersion N'Role Manager', N'1', 1, 1
GO

/*************************************************************/
/*************************************************************/

--
--Create Role Manager roles
--

IF ( NOT EXISTS ( SELECT name
                  FROM sysusers
                  WHERE issqlrole = 1
                  AND name = N'aspnet_Roles_FullAccess'  ) )
EXEC sp_addrole N'aspnet_Roles_FullAccess'

IF ( NOT EXISTS ( SELECT name
                  FROM sysusers
                  WHERE issqlrole = 1
                  AND name = N'aspnet_Roles_BasicAccess'  ) )
EXEC sp_addrole N'aspnet_Roles_BasicAccess'

IF ( NOT EXISTS ( SELECT name
                  FROM sysusers
                  WHERE issqlrole = 1
                  AND name = N'aspnet_Roles_ReportingAccess'  ) )
EXEC sp_addrole N'aspnet_Roles_ReportingAccess'
GO

EXEC sp_addrolemember N'aspnet_Roles_BasicAccess', N'aspnet_Roles_FullAccess'
EXEC sp_addrolemember N'aspnet_Roles_ReportingAccess', N'aspnet_Roles_FullAccess'
GO

--
--Stored Procedure rights for BasicAccess
--
GRANT EXECUTE ON dbo.aspnet_UsersInRoles_IsUserInRole TO aspnet_Roles_BasicAccess
GRANT EXECUTE ON dbo.aspnet_UsersInRoles_GetRolesForUser TO aspnet_Roles_BasicAccess
GRANT EXECUTE ON dbo.aspnet_CheckSchemaVersion TO aspnet_Roles_BasicAccess
GRANT EXECUTE ON dbo.aspnet_RegisterSchemaVersion TO aspnet_Roles_BasicAccess
GRANT EXECUTE ON dbo.aspnet_UnRegisterSchemaVersion TO aspnet_Roles_BasicAccess

--
--Stored Procedure rights for ReportingAccess
--
GRANT EXECUTE ON dbo.aspnet_UsersInRoles_IsUserInRole TO aspnet_Roles_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_UsersInRoles_GetRolesForUser TO aspnet_Roles_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_Roles_RoleExists TO aspnet_Roles_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_UsersInRoles_GetUsersInRoles TO aspnet_Roles_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_UsersInRoles_FindUsersInRole TO aspnet_Roles_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_Roles_GetAllRoles TO aspnet_Roles_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_CheckSchemaVersion TO aspnet_Roles_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_RegisterSchemaVersion TO aspnet_Roles_ReportingAccess
GRANT EXECUTE ON dbo.aspnet_UnRegisterSchemaVersion TO aspnet_Roles_ReportingAccess

--
--Additional stored procedure rights for FullAccess
--

GRANT EXECUTE ON dbo.aspnet_Roles_CreateRole TO aspnet_Roles_FullAccess
GRANT EXECUTE ON dbo.aspnet_Roles_DeleteRole TO aspnet_Roles_FullAccess
GRANT EXECUTE ON dbo.aspnet_UsersInRoles_AddUsersToRoles TO aspnet_Roles_FullAccess
GRANT EXECUTE ON dbo.aspnet_UsersInRoles_RemoveUsersFromRoles TO aspnet_Roles_FullAccess

--
--View rights
--
GRANT SELECT ON dbo.vw_aspnet_Applications TO aspnet_Roles_ReportingAccess
GRANT SELECT ON dbo.vw_aspnet_Users TO aspnet_Roles_ReportingAccess

GRANT SELECT ON dbo.vw_aspnet_Roles TO aspnet_Roles_ReportingAccess
GRANT SELECT ON dbo.vw_aspnet_UsersInRoles TO aspnet_Roles_ReportingAccess

GO

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/

DECLARE @command nvarchar(4000)
SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_RegisterSchemaVersion FROM ' + QUOTENAME(user)
EXECUTE (@command)
GO

PRINT '---------------------------------------'
PRINT 'Completed execution of InstallRoles.SQL'
PRINT '---------------------------------------'
