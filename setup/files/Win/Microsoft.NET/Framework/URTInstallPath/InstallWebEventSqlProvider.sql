/**********************************************************************/
/* InstallWebEventSqlProvider.SQL                                     */
/*                                                                    */
/* Installs the tables, triggers and stored procedures necessary for  */
/* supporting the aspnet feature of ASP.Net                           */
/*                                                                    */
/* InstallCommon.sql must be run before running this file.            */
/*
** Copyright Microsoft, Inc. 2003
** All Rights Reserved.
*/
/**********************************************************************/

PRINT '----------------------------------------------------'
PRINT 'Starting execution of InstallWebEventSqlProvider.SQL'
PRINT '----------------------------------------------------'
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
                WHERE (name = N'aspnet_WebEvent_Events')
                  AND (type = 'U')))
BEGIN
  PRINT 'Creating the aspnet_WebEvent_Events table...'
  CREATE TABLE dbo.aspnet_WebEvent_Events (
        EventId         char(32)            PRIMARY KEY,
        EventTimeUtc    datetime            NOT NULL,
        EventTime       datetime            NOT NULL,
        EventType       nvarchar(256)       NOT NULL,
        EventSequence   decimal(19,0)       NOT NULL, /* SQL7 doesn't support bigint */
        EventOccurrence decimal(19,0)       NOT NULL, /* SQL7 doesn't support bigint */
        EventCode       int                 NOT NULL,
        EventDetailCode int                 NOT NULL,
        Message         nvarchar(1024)      NULL,
        ApplicationPath nvarchar(256)       NULL,
        ApplicationVirtualPath nvarchar(256) NULL,
        MachineName     nvarchar(256)       NOT NULL,
        RequestUrl      nvarchar(1024)      NULL,
        ExceptionType   nvarchar(256)       NULL,
        Details         ntext               NULL
  )
END

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/

IF (EXISTS (SELECT name
              FROM sysobjects
             WHERE (name = N'aspnet_WebEvent_LogEvent')
               AND (type = 'P')))
DROP PROCEDURE dbo.aspnet_WebEvent_LogEvent
GO
CREATE PROCEDURE dbo.aspnet_WebEvent_LogEvent
        @EventId         char(32),
        @EventTimeUtc    datetime,
        @EventTime       datetime,
        @EventType       nvarchar(256),
        @EventSequence   decimal(19,0),
        @EventOccurrence decimal(19,0),
        @EventCode       int,
        @EventDetailCode int,
        @Message         nvarchar(1024),
        @ApplicationPath nvarchar(256),
        @ApplicationVirtualPath nvarchar(256),
        @MachineName    nvarchar(256),
        @RequestUrl      nvarchar(1024),
        @ExceptionType   nvarchar(256),
        @Details         ntext
AS
BEGIN
    INSERT
        dbo.aspnet_WebEvent_Events
        (
            EventId,
            EventTimeUtc,
            EventTime,
            EventType,
            EventSequence,
            EventOccurrence,
            EventCode,
            EventDetailCode,
            Message,
            ApplicationPath,
            ApplicationVirtualPath,
            MachineName,
            RequestUrl,
            ExceptionType,
            Details
        )
    VALUES
    (
        @EventId,
        @EventTimeUtc,
        @EventTime,
        @EventType,
        @EventSequence,
        @EventOccurrence,
        @EventCode,
        @EventDetailCode,
        @Message,
        @ApplicationPath,
        @ApplicationVirtualPath,
        @MachineName,
        @RequestUrl,
        @ExceptionType,
        @Details
    )
END
GO

/*************************************************************/
/*************************************************************/

IF ( NOT EXISTS ( SELECT name
                  FROM sysusers
                  WHERE issqlrole = 1
                  AND name = N'aspnet_WebEvent_FullAccess'))
EXEC sp_addrole N'aspnet_WebEvent_FullAccess'

GRANT EXECUTE ON dbo.aspnet_WebEvent_LogEvent TO aspnet_WebEvent_FullAccess

GRANT EXECUTE ON dbo.aspnet_CheckSchemaVersion TO aspnet_WebEvent_FullAccess
GRANT EXECUTE ON dbo.aspnet_RegisterSchemaVersion TO aspnet_WebEvent_FullAccess
GRANT EXECUTE ON dbo.aspnet_UnRegisterSchemaVersion TO aspnet_WebEvent_FullAccess
GO

/*************************************************************/
/*************************************************************/

--
--Create Health Monitoring schema version
--

DECLARE @command nvarchar(4000)
SET @command = 'GRANT EXECUTE ON [dbo].aspnet_RegisterSchemaVersion TO ' + QUOTENAME(user)
EXECUTE (@command)
GO

EXEC [dbo].aspnet_RegisterSchemaVersion N'Health Monitoring', N'1', 1, 1
GO

/*************************************************************/
/*************************************************************/

DECLARE @command nvarchar(4000)
SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_RegisterSchemaVersion FROM ' + QUOTENAME(user)
EXECUTE (@command)
GO

PRINT '-----------------------------------------------------'
PRINT 'Completed execution of InstallWebEventSqlProvider.SQL'
PRINT '-----------------------------------------------------'
