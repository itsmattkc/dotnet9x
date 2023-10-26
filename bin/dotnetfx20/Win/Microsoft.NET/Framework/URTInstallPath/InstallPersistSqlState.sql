/*********************************************************************
  InstallPersistSqlState.SQL                                                
                                                                    
  Installs the tables, and stored procedures necessary for           
  supporting ASP.NET session state.                                  

  Copyright Microsoft, Inc.
  All Rights Reserved.

 *********************************************************************/

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

PRINT ''
PRINT '------------------------------------------------'
PRINT 'Starting execution of InstallPersistSqlState.SQL'
PRINT '------------------------------------------------'
PRINT ''
PRINT '--------------------------------------------------'
PRINT 'Note:                                             '
PRINT 'This file is included for backward compatibility  '
PRINT 'only.  You should use aspnet_regsql.exe to install'
PRINT 'and uninstall SQL session state.                  '
PRINT ''
PRINT 'Run ''aspnet_regsql.exe -?'' for details.         '
PRINT '--------------------------------------------------'
GO

/*****************************************************************************/

USE master
GO

/* Create and populate the session state database */

IF DB_ID(N'ASPState') IS NULL BEGIN
    DECLARE @cmd nvarchar(500)
    SET @cmd = N'CREATE DATABASE [ASPState]'
    EXEC(@cmd)
END    
GO

/* Drop all tables, startup procedures, stored procedures and types. */

/* Drop the DeleteExpiredSessions_Job */

DECLARE @jobname nvarchar(200)
SET @jobname = N'ASPState' + '_Job_DeleteExpiredSessions' 

-- Delete the [local] job 
-- We expected to get an error if the job doesn't exist.
PRINT 'If the job does not exist, an error from msdb.dbo.sp_delete_job is expected.'
EXECUTE msdb.dbo.sp_delete_job @job_name = @jobname
GO

DECLARE @sstype nvarchar(128)
SET @sstype = N'sstype_persisted'

IF UPPER(@sstype) = 'SSTYPE_TEMP' AND OBJECT_ID(N'dbo.ASPState_Startup', 'P') IS NOT NULL BEGIN
    DROP PROCEDURE dbo.ASPState_Startup
END    

USE [ASPState]
GO

IF OBJECT_ID(N'dbo.ASPStateTempSessions','U') IS NOT NULL BEGIN
    DROP TABLE dbo.ASPStateTempSessions
END

IF OBJECT_ID(N'dbo.ASPStateTempApplications','U') IS NOT NULL BEGIN
    DROP TABLE dbo.ASPStateTempApplications
END

USE [ASPState]
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'GetMajorVersion') AND (type = 'P')))
    DROP PROCEDURE [dbo].GetMajorVersion
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'CreateTempTables') AND (type = 'P')))
    DROP PROCEDURE [dbo].CreateTempTables
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempGetVersion') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempGetVersion
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'GetHashCode') AND (type = 'P')))
    DROP PROCEDURE [dbo].GetHashCode
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempGetAppID') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempGetAppID
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempGetStateItem') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempGetStateItem
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempGetStateItem2') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempGetStateItem2
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempGetStateItem3') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempGetStateItem3
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempGetStateItemExclusive') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempGetStateItemExclusive
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempGetStateItemExclusive2') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempGetStateItemExclusive2
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempGetStateItemExclusive3') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempGetStateItemExclusive3
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempReleaseStateItemExclusive') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempReleaseStateItemExclusive
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempInsertUninitializedItem') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempInsertUninitializedItem
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempInsertStateItemShort') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempInsertStateItemShort
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempInsertStateItemLong') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempInsertStateItemLong
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempUpdateStateItemShort') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempUpdateStateItemShort
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempUpdateStateItemShortNullLong') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempUpdateStateItemShortNullLong
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempUpdateStateItemLong') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempUpdateStateItemLong
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempUpdateStateItemLongNullShort') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempUpdateStateItemLongNullShort
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempRemoveStateItem') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempRemoveStateItem
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'TempResetTimeout') AND (type = 'P')))
    DROP PROCEDURE [dbo].TempResetTimeout
GO

IF (EXISTS (SELECT name FROM sysobjects WHERE (name = N'DeleteExpiredSessions') AND (type = 'P')))
    DROP PROCEDURE [dbo].DeleteExpiredSessions
GO

IF EXISTS(SELECT name FROM systypes WHERE name ='tSessionId')
    EXECUTE sp_droptype tSessionId
GO

IF EXISTS(SELECT name FROM systypes WHERE name ='tAppName')
    EXECUTE sp_droptype tAppName
GO

IF EXISTS(SELECT name FROM systypes WHERE name ='tSessionItemShort')
    EXECUTE sp_droptype tSessionItemShort
GO

IF EXISTS(SELECT name FROM systypes WHERE name ='tSessionItemLong')
    EXECUTE sp_droptype tSessionItemLong
GO

IF EXISTS(SELECT name FROM systypes WHERE name ='tTextPtr')
    EXECUTE sp_droptype tTextPtr
GO

/*****************************************************************************/

CREATE PROCEDURE dbo.GetMajorVersion
    @@ver int OUTPUT
AS
BEGIN
	DECLARE @version        nchar(100)
	DECLARE @dot            int
	DECLARE @hyphen         int
	DECLARE @SqlToExec      nchar(4000)

	SELECT @@ver = 7
	SELECT @version = @@Version
	SELECT @hyphen  = CHARINDEX(N' - ', @version)
	IF (NOT(@hyphen IS NULL) AND @hyphen > 0)
	BEGIN
		SELECT @hyphen = @hyphen + 3
		SELECT @dot    = CHARINDEX(N'.', @version, @hyphen)
		IF (NOT(@dot IS NULL) AND @dot > @hyphen)
		BEGIN
			SELECT @version = SUBSTRING(@version, @hyphen, @dot - @hyphen)
			SELECT @@ver     = CONVERT(int, @version)
		END
	END
END
GO   

/*****************************************************************************/

USE [ASPState]

/* Find out the version */
DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT

DECLARE @cmd nchar(4000)

IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.CreateTempTables
        AS
            CREATE TABLE [ASPState].dbo.ASPStateTempSessions (
                SessionId           nvarchar(88)    NOT NULL PRIMARY KEY,
                Created             datetime        NOT NULL DEFAULT GETUTCDATE(),
                Expires             datetime        NOT NULL,
                LockDate            datetime        NOT NULL,
                LockDateLocal       datetime        NOT NULL,
                LockCookie          int             NOT NULL,
                Timeout             int             NOT NULL,
                Locked              bit             NOT NULL,
                SessionItemShort    varbinary(7000) NULL,
                SessionItemLong     image           NULL,
                Flags               int             NOT NULL DEFAULT 0,
            ) 

            CREATE NONCLUSTERED INDEX Index_Expires ON [ASPState].dbo.ASPStateTempSessions(Expires)

            CREATE TABLE [ASPState].dbo.ASPStateTempApplications (
                AppId               int             NOT NULL PRIMARY KEY,
                AppName             char(280)       NOT NULL,
            ) 

            CREATE NONCLUSTERED INDEX Index_AppName ON [ASPState].dbo.ASPStateTempApplications(AppName)

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.CreateTempTables
        AS
            CREATE TABLE [ASPState].dbo.ASPStateTempSessions (
                SessionId           nvarchar(88)    NOT NULL PRIMARY KEY,
                Created             datetime        NOT NULL DEFAULT GETDATE(),
                Expires             datetime        NOT NULL,
                LockDate            datetime        NOT NULL,
                LockCookie          int             NOT NULL,
                Timeout             int             NOT NULL,
                Locked              bit             NOT NULL,
                SessionItemShort    VARBINARY(7000) NULL,
                SessionItemLong     IMAGE           NULL,
                Flags               int             NOT NULL DEFAULT 0,
            ) 

            CREATE NONCLUSTERED INDEX Index_Expires ON [ASPState].dbo.ASPStateTempSessions(Expires)

            CREATE TABLE [ASPState].dbo.ASPStateTempApplications (
                AppId               int             NOT NULL PRIMARY KEY,
                AppName             char(280)       NOT NULL,
            ) 

            CREATE NONCLUSTERED INDEX Index_AppName ON [ASPState].dbo.ASPStateTempApplications(AppName)

            RETURN 0'

EXEC (@cmd)
GO   

/*****************************************************************************/

EXECUTE sp_addtype tSessionId, 'nvarchar(88)',  'NOT NULL'
GO

EXECUTE sp_addtype tAppName, 'varchar(280)', 'NOT NULL'
GO

EXECUTE sp_addtype tSessionItemShort, 'varbinary(7000)'
GO

EXECUTE sp_addtype tSessionItemLong, 'image'
GO

EXECUTE sp_addtype tTextPtr, 'varbinary(16)'
GO

/*****************************************************************************/

CREATE PROCEDURE dbo.TempGetVersion
    @ver      char(10) OUTPUT
AS
    SELECT @ver = "2"
    RETURN 0
GO

/*****************************************************************************/

CREATE PROCEDURE dbo.GetHashCode
    @input tAppName,
    @hash int OUTPUT
AS
    /* 
       This sproc is based on this C# hash function:

        int GetHashCode(string s)
        {
            int     hash = 5381;
            int     len = s.Length;

            for (int i = 0; i < len; i++) {
                int     c = Convert.ToInt32(s[i]);
                hash = ((hash << 5) + hash) ^ c;
            }

            return hash;
        }

        However, SQL 7 doesn't provide a 32-bit integer
        type that allows rollover of bits, we have to
        divide our 32bit integer into the upper and lower
        16 bits to do our calculation.
    */
       
    DECLARE @hi_16bit   int
    DECLARE @lo_16bit   int
    DECLARE @hi_t       int
    DECLARE @lo_t       int
    DECLARE @len        int
    DECLARE @i          int
    DECLARE @c          int
    DECLARE @carry      int

    SET @hi_16bit = 0
    SET @lo_16bit = 5381
    
    SET @len = DATALENGTH(@input)
    SET @i = 1
    
    WHILE (@i <= @len)
    BEGIN
        SET @c = ASCII(SUBSTRING(@input, @i, 1))

        /* Formula:                        
           hash = ((hash << 5) + hash) ^ c */

        /* hash << 5 */
        SET @hi_t = @hi_16bit * 32 /* high 16bits << 5 */
        SET @hi_t = @hi_t & 0xFFFF /* zero out overflow */
        
        SET @lo_t = @lo_16bit * 32 /* low 16bits << 5 */
        
        SET @carry = @lo_16bit & 0x1F0000 /* move low 16bits carryover to hi 16bits */
        SET @carry = @carry / 0x10000 /* >> 16 */
        SET @hi_t = @hi_t + @carry
        SET @hi_t = @hi_t & 0xFFFF /* zero out overflow */

        /* + hash */
        SET @lo_16bit = @lo_16bit + @lo_t
        SET @hi_16bit = @hi_16bit + @hi_t + (@lo_16bit / 0x10000)
        /* delay clearing the overflow */

        /* ^c */
        SET @lo_16bit = @lo_16bit ^ @c

        /* Now clear the overflow bits */	
        SET @hi_16bit = @hi_16bit & 0xFFFF
        SET @lo_16bit = @lo_16bit & 0xFFFF

        SET @i = @i + 1
    END

    /* Do a sign extension of the hi-16bit if needed */
    IF (@hi_16bit & 0x8000 <> 0)
        SET @hi_16bit = 0xFFFF0000 | @hi_16bit

    /* Merge hi and lo 16bit back together */
    SET @hi_16bit = @hi_16bit * 0x10000 /* << 16 */
    SET @hash = @hi_16bit | @lo_16bit

    RETURN 0
GO

/*****************************************************************************/

DECLARE @cmd nchar(4000)

SET @cmd = N'
    CREATE PROCEDURE dbo.TempGetAppID
    @appName    tAppName,
    @appId      int OUTPUT
    AS
    SET @appName = LOWER(@appName)
    SET @appId = NULL

    SELECT @appId = AppId
    FROM [ASPState].dbo.ASPStateTempApplications
    WHERE AppName = @appName

    IF @appId IS NULL BEGIN
        BEGIN TRAN        

        SELECT @appId = AppId
        FROM [ASPState].dbo.ASPStateTempApplications WITH (TABLOCKX)
        WHERE AppName = @appName
        
        IF @appId IS NULL
        BEGIN
            EXEC GetHashCode @appName, @appId OUTPUT
            
            INSERT [ASPState].dbo.ASPStateTempApplications
            VALUES
            (@appId, @appName)
            
            IF @@ERROR = 2627 
            BEGIN
                DECLARE @dupApp tAppName
            
                SELECT @dupApp = RTRIM(AppName)
                FROM [ASPState].dbo.ASPStateTempApplications 
                WHERE AppId = @appId
                
                RAISERROR(''SQL session state fatal error: hash-code collision between applications ''''%s'''' and ''''%s''''. Please rename the 1st application to resolve the problem.'', 
                            18, 1, @appName, @dupApp)
            END
        END

        COMMIT
    END

    RETURN 0'
EXEC(@cmd)    
GO

/*****************************************************************************/

/* Find out the version */

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempGetStateItem
            @id         tSessionId,
            @itemShort  tSessionItemShort OUTPUT,
            @locked     bit OUTPUT,
            @lockDate   datetime OUTPUT,
            @lockCookie int OUTPUT
        AS
            DECLARE @textptr AS tTextPtr
            DECLARE @length AS int
            DECLARE @now AS datetime
            SET @now = GETUTCDATE()

            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, @now), 
                @locked = Locked,
                @lockDate = LockDateLocal,
                @lockCookie = LockCookie,
                @itemShort = CASE @locked
                    WHEN 0 THEN SessionItemShort
                    ELSE NULL
                    END,
                @textptr = CASE @locked
                    WHEN 0 THEN TEXTPTR(SessionItemLong)
                    ELSE NULL
                    END,
                @length = CASE @locked
                    WHEN 0 THEN DATALENGTH(SessionItemLong)
                    ELSE NULL
                    END
            WHERE SessionId = @id
            IF @length IS NOT NULL BEGIN
                READTEXT [ASPState].dbo.ASPStateTempSessions.SessionItemLong @textptr 0 @length
            END

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempGetStateItem
            @id         tSessionId,
            @itemShort  tSessionItemShort OUTPUT,
            @locked     bit OUTPUT,
            @lockDate   datetime OUTPUT,
            @lockCookie int OUTPUT
        AS
            DECLARE @textptr AS tTextPtr
            DECLARE @length AS int
            DECLARE @now AS datetime
            SET @now = GETDATE()

            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, @now), 
                @locked = Locked,
                @lockDate = LockDate,
                @lockCookie = LockCookie,
                @itemShort = CASE @locked
                    WHEN 0 THEN SessionItemShort
                    ELSE NULL
                    END,
                @textptr = CASE @locked
                    WHEN 0 THEN TEXTPTR(SessionItemLong)
                    ELSE NULL
                    END,
                @length = CASE @locked
                    WHEN 0 THEN DATALENGTH(SessionItemLong)
                    ELSE NULL
                    END
            WHERE SessionId = @id
            IF @length IS NOT NULL BEGIN
                READTEXT [ASPState].dbo.ASPStateTempSessions.SessionItemLong @textptr 0 @length
            END

            RETURN 0'
    
EXEC (@cmd)    
GO

/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempGetStateItem2
            @id         tSessionId,
            @itemShort  tSessionItemShort OUTPUT,
            @locked     bit OUTPUT,
            @lockAge    int OUTPUT,
            @lockCookie int OUTPUT
        AS
            DECLARE @textptr AS tTextPtr
            DECLARE @length AS int
            DECLARE @now AS datetime
            SET @now = GETUTCDATE()

            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, @now), 
                @locked = Locked,
                @lockAge = DATEDIFF(second, LockDate, @now),
                @lockCookie = LockCookie,
                @itemShort = CASE @locked
                    WHEN 0 THEN SessionItemShort
                    ELSE NULL
                    END,
                @textptr = CASE @locked
                    WHEN 0 THEN TEXTPTR(SessionItemLong)
                    ELSE NULL
                    END,
                @length = CASE @locked
                    WHEN 0 THEN DATALENGTH(SessionItemLong)
                    ELSE NULL
                    END
            WHERE SessionId = @id
            IF @length IS NOT NULL BEGIN
                READTEXT [ASPState].dbo.ASPStateTempSessions.SessionItemLong @textptr 0 @length
            END

            RETURN 0'

EXEC (@cmd)    
GO
            

/*****************************************************************************/

/* Find out the version */

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempGetStateItem3
            @id         tSessionId,
            @itemShort  tSessionItemShort OUTPUT,
            @locked     bit OUTPUT,
            @lockAge    int OUTPUT,
            @lockCookie int OUTPUT,
            @actionFlags int OUTPUT
        AS
            DECLARE @textptr AS tTextPtr
            DECLARE @length AS int
            DECLARE @now AS datetime
            SET @now = GETUTCDATE()

            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, @now), 
                @locked = Locked,
                @lockAge = DATEDIFF(second, LockDate, @now),
                @lockCookie = LockCookie,
                @itemShort = CASE @locked
                    WHEN 0 THEN SessionItemShort
                    ELSE NULL
                    END,
                @textptr = CASE @locked
                    WHEN 0 THEN TEXTPTR(SessionItemLong)
                    ELSE NULL
                    END,
                @length = CASE @locked
                    WHEN 0 THEN DATALENGTH(SessionItemLong)
                    ELSE NULL
                    END,

                /* If the Uninitialized flag (0x1) if it is set,
                   remove it and return InitializeItem (0x1) in actionFlags */
                Flags = CASE
                    WHEN (Flags & 1) <> 0 THEN (Flags & ~1)
                    ELSE Flags
                    END,
                @actionFlags = CASE
                    WHEN (Flags & 1) <> 0 THEN 1
                    ELSE 0
                    END
            WHERE SessionId = @id
            IF @length IS NOT NULL BEGIN
                READTEXT [ASPState].dbo.ASPStateTempSessions.SessionItemLong @textptr 0 @length
            END

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempGetStateItem3
            @id         tSessionId,
            @itemShort  tSessionItemShort OUTPUT,
            @locked     bit OUTPUT,
            @lockDate   datetime OUTPUT,
            @lockCookie int OUTPUT,
            @actionFlags int OUTPUT
        AS
            DECLARE @textptr AS tTextPtr
            DECLARE @length AS int
            DECLARE @now AS datetime
            SET @now = GETDATE()

            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, @now), 
                @locked = Locked,
                @lockDate = LockDate,
                @lockCookie = LockCookie,
                @itemShort = CASE @locked
                    WHEN 0 THEN SessionItemShort
                    ELSE NULL
                    END,
                @textptr = CASE @locked
                    WHEN 0 THEN TEXTPTR(SessionItemLong)
                    ELSE NULL
                    END,
                @length = CASE @locked
                    WHEN 0 THEN DATALENGTH(SessionItemLong)
                    ELSE NULL
                    END,

                /* If the Uninitialized flag (0x1) if it is set,
                   remove it and return InitializeItem (0x1) in actionFlags */
                Flags = CASE
                    WHEN (Flags & 1) <> 0 THEN (Flags & ~1)
                    ELSE Flags
                    END,
                @actionFlags = CASE
                    WHEN (Flags & 1) <> 0 THEN 1
                    ELSE 0
                    END
            WHERE SessionId = @id
            IF @length IS NOT NULL BEGIN
                READTEXT [ASPState].dbo.ASPStateTempSessions.SessionItemLong @textptr 0 @length
            END

            RETURN 0'
    
EXEC (@cmd)    
GO

/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempGetStateItemExclusive
            @id         tSessionId,
            @itemShort  tSessionItemShort OUTPUT,
            @locked     bit OUTPUT,
            @lockDate   datetime OUTPUT,
            @lockCookie int OUTPUT
        AS
            DECLARE @textptr AS tTextPtr
            DECLARE @length AS int
            DECLARE @now AS datetime
            DECLARE @nowLocal AS datetime

            SET @now = GETUTCDATE()
            SET @nowLocal = GETDATE()
            
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, @now), 
                LockDate = CASE Locked
                    WHEN 0 THEN @now
                    ELSE LockDate
                    END,
                @lockDate = LockDateLocal = CASE Locked
                    WHEN 0 THEN @nowLocal
                    ELSE LockDateLocal
                    END,
                @lockCookie = LockCookie = CASE Locked
                    WHEN 0 THEN LockCookie + 1
                    ELSE LockCookie
                    END,
                @itemShort = CASE Locked
                    WHEN 0 THEN SessionItemShort
                    ELSE NULL
                    END,
                @textptr = CASE Locked
                    WHEN 0 THEN TEXTPTR(SessionItemLong)
                    ELSE NULL
                    END,
                @length = CASE Locked
                    WHEN 0 THEN DATALENGTH(SessionItemLong)
                    ELSE NULL
                    END,
                @locked = Locked,
                Locked = 1
            WHERE SessionId = @id
            IF @length IS NOT NULL BEGIN
                READTEXT [ASPState].dbo.ASPStateTempSessions.SessionItemLong @textptr 0 @length
            END

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempGetStateItemExclusive
            @id         tSessionId,
            @itemShort  tSessionItemShort OUTPUT,
            @locked     bit OUTPUT,
            @lockDate   datetime OUTPUT,
            @lockCookie int OUTPUT
        AS
            DECLARE @textptr AS tTextPtr
            DECLARE @length AS int
            DECLARE @now AS datetime

            SET @now = GETDATE()
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, @now), 
                @lockDate = LockDate = CASE Locked
                    WHEN 0 THEN @now
                    ELSE LockDate
                    END,
                @lockCookie = LockCookie = CASE Locked
                    WHEN 0 THEN LockCookie + 1
                    ELSE LockCookie
                    END,
                @itemShort = CASE Locked
                    WHEN 0 THEN SessionItemShort
                    ELSE NULL
                    END,
                @textptr = CASE Locked
                    WHEN 0 THEN TEXTPTR(SessionItemLong)
                    ELSE NULL
                    END,
                @length = CASE Locked
                    WHEN 0 THEN DATALENGTH(SessionItemLong)
                    ELSE NULL
                    END,
                @locked = Locked,
                Locked = 1
            WHERE SessionId = @id
            IF @length IS NOT NULL BEGIN
                READTEXT [ASPState].dbo.ASPStateTempSessions.SessionItemLong @textptr 0 @length
            END

            RETURN 0'    

EXEC (@cmd)    
GO


/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempGetStateItemExclusive2
            @id         tSessionId,
            @itemShort  tSessionItemShort OUTPUT,
            @locked     bit OUTPUT,
            @lockAge    int OUTPUT,
            @lockCookie int OUTPUT
        AS
            DECLARE @textptr AS tTextPtr
            DECLARE @length AS int
            DECLARE @now AS datetime
            DECLARE @nowLocal AS datetime

            SET @now = GETUTCDATE()
            SET @nowLocal = GETDATE()
            
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, @now), 
                LockDate = CASE Locked
                    WHEN 0 THEN @now
                    ELSE LockDate
                    END,
                LockDateLocal = CASE Locked
                    WHEN 0 THEN @nowLocal
                    ELSE LockDateLocal
                    END,
                @lockAge = CASE Locked
                    WHEN 0 THEN 0
                    ELSE DATEDIFF(second, LockDate, @now)
                    END,
                @lockCookie = LockCookie = CASE Locked
                    WHEN 0 THEN LockCookie + 1
                    ELSE LockCookie
                    END,
                @itemShort = CASE Locked
                    WHEN 0 THEN SessionItemShort
                    ELSE NULL
                    END,
                @textptr = CASE Locked
                    WHEN 0 THEN TEXTPTR(SessionItemLong)
                    ELSE NULL
                    END,
                @length = CASE Locked
                    WHEN 0 THEN DATALENGTH(SessionItemLong)
                    ELSE NULL
                    END,
                @locked = Locked,
                Locked = 1
            WHERE SessionId = @id
            IF @length IS NOT NULL BEGIN
                READTEXT [ASPState].dbo.ASPStateTempSessions.SessionItemLong @textptr 0 @length
            END

            RETURN 0'

EXEC (@cmd)    
GO


/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempGetStateItemExclusive3
            @id         tSessionId,
            @itemShort  tSessionItemShort OUTPUT,
            @locked     bit OUTPUT,
            @lockAge    int OUTPUT,
            @lockCookie int OUTPUT,
            @actionFlags int OUTPUT
        AS
            DECLARE @textptr AS tTextPtr
            DECLARE @length AS int
            DECLARE @now AS datetime
            DECLARE @nowLocal AS datetime

            SET @now = GETUTCDATE()
            SET @nowLocal = GETDATE()
            
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, @now), 
                LockDate = CASE Locked
                    WHEN 0 THEN @now
                    ELSE LockDate
                    END,
                LockDateLocal = CASE Locked
                    WHEN 0 THEN @nowLocal
                    ELSE LockDateLocal
                    END,
                @lockAge = CASE Locked
                    WHEN 0 THEN 0
                    ELSE DATEDIFF(second, LockDate, @now)
                    END,
                @lockCookie = LockCookie = CASE Locked
                    WHEN 0 THEN LockCookie + 1
                    ELSE LockCookie
                    END,
                @itemShort = CASE Locked
                    WHEN 0 THEN SessionItemShort
                    ELSE NULL
                    END,
                @textptr = CASE Locked
                    WHEN 0 THEN TEXTPTR(SessionItemLong)
                    ELSE NULL
                    END,
                @length = CASE Locked
                    WHEN 0 THEN DATALENGTH(SessionItemLong)
                    ELSE NULL
                    END,
                @locked = Locked,
                Locked = 1,

                /* If the Uninitialized flag (0x1) if it is set,
                   remove it and return InitializeItem (0x1) in actionFlags */
                Flags = CASE
                    WHEN (Flags & 1) <> 0 THEN (Flags & ~1)
                    ELSE Flags
                    END,
                @actionFlags = CASE
                    WHEN (Flags & 1) <> 0 THEN 1
                    ELSE 0
                    END
            WHERE SessionId = @id
            IF @length IS NOT NULL BEGIN
                READTEXT [ASPState].dbo.ASPStateTempSessions.SessionItemLong @textptr 0 @length
            END

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempGetStateItemExclusive3
            @id         tSessionId,
            @itemShort  tSessionItemShort OUTPUT,
            @locked     bit OUTPUT,
            @lockDate   datetime OUTPUT,
            @lockCookie int OUTPUT,
            @actionFlags int OUTPUT
        AS
            DECLARE @textptr AS tTextPtr
            DECLARE @length AS int
            DECLARE @now AS datetime

            SET @now = GETDATE()
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, @now), 
                @lockDate = LockDate = CASE Locked
                    WHEN 0 THEN @now
                    ELSE LockDate
                    END,
                @lockCookie = LockCookie = CASE Locked
                    WHEN 0 THEN LockCookie + 1
                    ELSE LockCookie
                    END,
                @itemShort = CASE Locked
                    WHEN 0 THEN SessionItemShort
                    ELSE NULL
                    END,
                @textptr = CASE Locked
                    WHEN 0 THEN TEXTPTR(SessionItemLong)
                    ELSE NULL
                    END,
                @length = CASE Locked
                    WHEN 0 THEN DATALENGTH(SessionItemLong)
                    ELSE NULL
                    END,
                @locked = Locked,
                Locked = 1,

                /* If the Uninitialized flag (0x1) if it is set,
                   remove it and return InitializeItem (0x1) in actionFlags */
                Flags = CASE
                    WHEN (Flags & 1) <> 0 THEN (Flags & ~1)
                    ELSE Flags
                    END,
                @actionFlags = CASE
                    WHEN (Flags & 1) <> 0 THEN 1
                    ELSE 0
                    END
            WHERE SessionId = @id
            IF @length IS NOT NULL BEGIN
                READTEXT [ASPState].dbo.ASPStateTempSessions.SessionItemLong @textptr 0 @length
            END

            RETURN 0'    

EXEC (@cmd)    
GO


/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempReleaseStateItemExclusive
            @id         tSessionId,
            @lockCookie int
        AS
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETUTCDATE()), 
                Locked = 0
            WHERE SessionId = @id AND LockCookie = @lockCookie

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempReleaseStateItemExclusive
            @id         tSessionId,
            @lockCookie int
        AS
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETDATE()), 
                Locked = 0
            WHERE SessionId = @id AND LockCookie = @lockCookie

            RETURN 0'

EXEC (@cmd)    
GO


/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempInsertUninitializedItem
            @id         tSessionId,
            @itemShort  tSessionItemShort,
            @timeout    int
        AS    

            DECLARE @now AS datetime
            DECLARE @nowLocal AS datetime
            
            SET @now = GETUTCDATE()
            SET @nowLocal = GETDATE()

            INSERT [ASPState].dbo.ASPStateTempSessions 
                (SessionId, 
                 SessionItemShort, 
                 Timeout, 
                 Expires, 
                 Locked, 
                 LockDate,
                 LockDateLocal,
                 LockCookie,
                 Flags) 
            VALUES 
                (@id, 
                 @itemShort, 
                 @timeout, 
                 DATEADD(n, @timeout, @now), 
                 0, 
                 @now,
                 @nowLocal,
                 1,
                 1)

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempInsertUninitializedItem
            @id         tSessionId,
            @itemShort  tSessionItemShort,
            @timeout    int
        AS    

            DECLARE @now AS datetime
            SET @now = GETDATE()

            INSERT [ASPState].dbo.ASPStateTempSessions 
                (SessionId, 
                 SessionItemShort, 
                 Timeout, 
                 Expires, 
                 Locked, 
                 LockDate,
                 LockCookie,
                 Flags) 
            VALUES 
                (@id, 
                 @itemShort, 
                 @timeout, 
                 DATEADD(n, @timeout, @now), 
                 0, 
                 @now,
                 1,
                 1)

            RETURN 0'

EXEC (@cmd)    
GO


/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempInsertStateItemShort
            @id         tSessionId,
            @itemShort  tSessionItemShort,
            @timeout    int
        AS    

            DECLARE @now AS datetime
            DECLARE @nowLocal AS datetime
            
            SET @now = GETUTCDATE()
            SET @nowLocal = GETDATE()

            INSERT [ASPState].dbo.ASPStateTempSessions 
                (SessionId, 
                 SessionItemShort, 
                 Timeout, 
                 Expires, 
                 Locked, 
                 LockDate,
                 LockDateLocal,
                 LockCookie) 
            VALUES 
                (@id, 
                 @itemShort, 
                 @timeout, 
                 DATEADD(n, @timeout, @now), 
                 0, 
                 @now,
                 @nowLocal,
                 1)

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempInsertStateItemShort
            @id         tSessionId,
            @itemShort  tSessionItemShort,
            @timeout    int
        AS    

            DECLARE @now AS datetime
            SET @now = GETDATE()

            INSERT [ASPState].dbo.ASPStateTempSessions 
                (SessionId, 
                 SessionItemShort, 
                 Timeout, 
                 Expires, 
                 Locked, 
                 LockDate,
                 LockCookie) 
            VALUES 
                (@id, 
                 @itemShort, 
                 @timeout, 
                 DATEADD(n, @timeout, @now), 
                 0, 
                 @now,
                 1)

            RETURN 0'

EXEC (@cmd)    
GO


/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempInsertStateItemLong
            @id         tSessionId,
            @itemLong   tSessionItemLong,
            @timeout    int
        AS    
            DECLARE @now AS datetime
            DECLARE @nowLocal AS datetime
            
            SET @now = GETUTCDATE()
            SET @nowLocal = GETDATE()

            INSERT [ASPState].dbo.ASPStateTempSessions 
                (SessionId, 
                 SessionItemLong, 
                 Timeout, 
                 Expires, 
                 Locked, 
                 LockDate,
                 LockDateLocal,
                 LockCookie) 
            VALUES 
                (@id, 
                 @itemLong, 
                 @timeout, 
                 DATEADD(n, @timeout, @now), 
                 0, 
                 @now,
                 @nowLocal,
                 1)

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempInsertStateItemLong
            @id         tSessionId,
            @itemLong   tSessionItemLong,
            @timeout    int
        AS    
            DECLARE @now AS datetime
            SET @now = GETDATE()

            INSERT [ASPState].dbo.ASPStateTempSessions 
                (SessionId, 
                 SessionItemLong, 
                 Timeout, 
                 Expires, 
                 Locked, 
                 LockDate,
                 LockCookie) 
            VALUES 
                (@id, 
                 @itemLong, 
                 @timeout, 
                 DATEADD(n, @timeout, @now), 
                 0, 
                 @now,
                 1)

            RETURN 0'

EXEC (@cmd)    
GO


/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempUpdateStateItemShort
            @id         tSessionId,
            @itemShort  tSessionItemShort,
            @timeout    int,
            @lockCookie int
        AS    
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETUTCDATE()), 
                SessionItemShort = @itemShort, 
                Timeout = @timeout,
                Locked = 0
            WHERE SessionId = @id AND LockCookie = @lockCookie

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempUpdateStateItemShort
            @id         tSessionId,
            @itemShort  tSessionItemShort,
            @timeout    int,
            @lockCookie int
        AS    
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETDATE()), 
                SessionItemShort = @itemShort, 
                Timeout = @timeout,
                Locked = 0
            WHERE SessionId = @id AND LockCookie = @lockCookie

            RETURN 0'

EXEC (@cmd)    
GO


/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempUpdateStateItemShortNullLong
            @id         tSessionId,
            @itemShort  tSessionItemShort,
            @timeout    int,
            @lockCookie int
        AS    
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETUTCDATE()), 
                SessionItemShort = @itemShort, 
                SessionItemLong = NULL, 
                Timeout = @timeout,
                Locked = 0
            WHERE SessionId = @id AND LockCookie = @lockCookie

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempUpdateStateItemShortNullLong
            @id         tSessionId,
            @itemShort  tSessionItemShort,
            @timeout    int,
            @lockCookie int
        AS    
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETDATE()), 
                SessionItemShort = @itemShort, 
                SessionItemLong = NULL, 
                Timeout = @timeout,
                Locked = 0
            WHERE SessionId = @id AND LockCookie = @lockCookie

            RETURN 0'

EXEC (@cmd)    
GO


/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempUpdateStateItemLong
            @id         tSessionId,
            @itemLong   tSessionItemLong,
            @timeout    int,
            @lockCookie int
        AS    
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETUTCDATE()), 
                SessionItemLong = @itemLong,
                Timeout = @timeout,
                Locked = 0
            WHERE SessionId = @id AND LockCookie = @lockCookie

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempUpdateStateItemLong
            @id         tSessionId,
            @itemLong   tSessionItemLong,
            @timeout    int,
            @lockCookie int
        AS    
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETDATE()), 
                SessionItemLong = @itemLong,
                Timeout = @timeout,
                Locked = 0
            WHERE SessionId = @id AND LockCookie = @lockCookie

            RETURN 0'

EXEC (@cmd)            
GO


/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempUpdateStateItemLongNullShort
            @id         tSessionId,
            @itemLong   tSessionItemLong,
            @timeout    int,
            @lockCookie int
        AS    
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETUTCDATE()), 
                SessionItemLong = @itemLong, 
                SessionItemShort = NULL,
                Timeout = @timeout,
                Locked = 0
            WHERE SessionId = @id AND LockCookie = @lockCookie

            RETURN 0'
ELSE
    SET @cmd = N'
    CREATE PROCEDURE dbo.TempUpdateStateItemLongNullShort
        @id         tSessionId,
        @itemLong   tSessionItemLong,
        @timeout    int,
        @lockCookie int
    AS    
        UPDATE [ASPState].dbo.ASPStateTempSessions
        SET Expires = DATEADD(n, Timeout, GETDATE()), 
            SessionItemLong = @itemLong, 
            SessionItemShort = NULL,
            Timeout = @timeout,
            Locked = 0
        WHERE SessionId = @id AND LockCookie = @lockCookie

        RETURN 0'

EXEC (@cmd)            
GO

/*****************************************************************************/

DECLARE @cmd nchar(4000)
SET @cmd = N'
    CREATE PROCEDURE dbo.TempRemoveStateItem
        @id     tSessionId,
        @lockCookie int
    AS
        DELETE [ASPState].dbo.ASPStateTempSessions
        WHERE SessionId = @id AND LockCookie = @lockCookie
        RETURN 0'
EXEC(@cmd)    
GO
            
/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempResetTimeout
            @id     tSessionId
        AS
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETUTCDATE())
            WHERE SessionId = @id
            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.TempResetTimeout
            @id     tSessionId
        AS
            UPDATE [ASPState].dbo.ASPStateTempSessions
            SET Expires = DATEADD(n, Timeout, GETDATE())
            WHERE SessionId = @id
            RETURN 0'

EXEC (@cmd)            
GO

            
/*****************************************************************************/

DECLARE @ver int
EXEC dbo.GetMajorVersion @@ver=@ver OUTPUT
DECLARE @cmd nchar(4000)
IF (@ver >= 8)
    SET @cmd = N'
        CREATE PROCEDURE dbo.DeleteExpiredSessions
        AS
            DECLARE @now datetime
            SET @now = GETUTCDATE()

            DELETE [ASPState].dbo.ASPStateTempSessions
            WHERE Expires < @now

            RETURN 0'
ELSE
    SET @cmd = N'
        CREATE PROCEDURE dbo.DeleteExpiredSessions
        AS
            DECLARE @now datetime
            SET @now = GETDATE()

            DELETE [ASPState].dbo.ASPStateTempSessions
            WHERE Expires < @now

            RETURN 0'

EXEC (@cmd)            
GO
            
/*****************************************************************************/

EXECUTE dbo.CreateTempTables
GO

USE master
GO

DECLARE @sstype nvarchar(128)
SET @sstype = N'sstype_persisted'

IF UPPER(@sstype) = 'SSTYPE_TEMP' BEGIN
    DECLARE @cmd nchar(4000)

    SET @cmd = N'
        /* Create the startup procedure */
        CREATE PROCEDURE dbo.ASPState_Startup 
        AS
            EXECUTE ASPState.dbo.CreateTempTables

            RETURN 0'
    EXEC(@cmd)
    EXECUTE sp_procoption @ProcName='dbo.ASPState_Startup', @OptionName='startup', @OptionValue='true'
END    

/*****************************************************************************/

/* Create the job to delete expired sessions */

-- Add job category
-- We expect an error if the category already exists.
PRINT 'If the category already exists, an error from msdb.dbo.sp_add_category is expected.'
EXECUTE msdb.dbo.sp_add_category @name = N'[Uncategorized (Local)]'
GO

BEGIN TRANSACTION            
    DECLARE @JobID BINARY(16)  
    DECLARE @ReturnCode int    
    DECLARE @nameT nchar(200)
    SELECT @ReturnCode = 0     

    -- Add the job
    SET @nameT = N'ASPState' + '_Job_DeleteExpiredSessions'
    EXECUTE @ReturnCode = msdb.dbo.sp_add_job 
            @job_id = @JobID OUTPUT, 
            @job_name = @nameT, 
            @owner_login_name = NULL, 
            @description = N'Deletes expired sessions from the session state database.', 
            @category_name = N'[Uncategorized (Local)]', 
            @enabled = 1, 
            @notify_level_email = 0, 
            @notify_level_page = 0, 
            @notify_level_netsend = 0, 
            @notify_level_eventlog = 0, 
            @delete_level= 0

    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
    
    -- Add the job steps
    SET @nameT = N'ASPState' + '_JobStep_DeleteExpiredSessions'
    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobstep 
            @job_id = @JobID,
            @step_id = 1, 
            @step_name = @nameT, 
            @command = N'EXECUTE DeleteExpiredSessions', 
            @database_name = N'ASPState', 
            @server = N'', 
            @database_user_name = N'', 
            @subsystem = N'TSQL', 
            @cmdexec_success_code = 0, 
            @flags = 0, 
            @retry_attempts = 0, 
            @retry_interval = 1, 
            @output_file_name = N'', 
            @on_success_step_id = 0, 
            @on_success_action = 1, 
            @on_fail_step_id = 0, 
            @on_fail_action = 2

    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 

    EXECUTE @ReturnCode = msdb.dbo.sp_update_job @job_id = @JobID, @start_step_id = 1 
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
    
    -- Add the job schedules
    SET @nameT = N'ASPState' + '_JobSchedule_DeleteExpiredSessions'
    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobschedule 
            @job_id = @JobID, 
            @name = @nameT, 
            @enabled = 1, 
            @freq_type = 4,     
            @active_start_date = 20001016, 
            @active_start_time = 0, 
            @freq_interval = 1, 
            @freq_subday_type = 4, 
            @freq_subday_interval = 1, 
            @freq_relative_interval = 0, 
            @freq_recurrence_factor = 0, 
            @active_end_date = 99991231, 
            @active_end_time = 235959

    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
    
    -- Add the Target Servers
    EXECUTE @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @JobID, @server_name = N'(local)' 
    IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback 
    
    COMMIT TRANSACTION          
    GOTO   EndSave              
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION 
EndSave: 
GO

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/

PRINT ''
PRINT '-------------------------------------------------'
PRINT 'Completed execution of InstallPersistSqlState.SQL'
PRINT '-------------------------------------------------'

