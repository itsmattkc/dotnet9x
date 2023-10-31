/**********************************************************************/
/* UninstallCommon.SQL                                                */
/*                                                                    */
/* Remove the common tables, triggers and stored procedures necessary */
/* for supporting the aspnet feature of ASP.Net                       */
/*
** Copyright Microsoft, Inc. 2003
** All Rights Reserved.
*/
/**********************************************************************/

PRINT '------------------------------------------------------'
PRINT 'Starting execution of UninstallWebEventSqlProvider.SQL'
PRINT '------------------------------------------------------'
GO

SET QUOTED_IDENTIFIER OFF -- We don't use quoted identifiers
SET ANSI_NULLS ON         -- We don't want (NULL = NULL) == TRUE
GO
SET ANSI_PADDING ON
GO

USE [aspnetdb]

DECLARE @command NVARCHAR(4000)
DECLARE @RemoveAllRoleMembersExits BIT
SET @RemoveAllRoleMembersExits = 0
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UnRegisterSchemaVersion]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
	SET @command = 'GRANT EXECUTE ON [dbo].aspnet_UnRegisterSchemaVersion TO ' + QUOTENAME(user)
	EXEC (@command)
END
IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Setup_RemoveAllRoleMembers]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
    SET @RemoveAllRoleMembersExits = 1
    SET @command = 'GRANT EXECUTE ON [dbo].aspnet_Setup_RemoveAllRoleMembers TO ' + QUOTENAME(user)
    EXEC (@command)
END

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_WebEvent_Events]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[aspnet_WebEvent_Events]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_WebEvent_LogEvent]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_WebEvent_LogEvent]

IF EXISTS ( SELECT name FROM sysusers WHERE issqlrole = 1 AND name = N'aspnet_WebEvent_FullAccess') 
BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
    EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_WebEvent_FullAccess'
  EXEC sp_droprole N'aspnet_WebEvent_FullAccess'
END        

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UnRegisterSchemaVersion]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
   EXEC [dbo].aspnet_UnRegisterSchemaVersion N'Health Monitoring', N'1'
   SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_UnRegisterSchemaVersion FROM ' + QUOTENAME(user)
   EXEC (@command)
END

IF (@RemoveAllRoleMembersExits = 1)
BEGIN
    SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_Setup_RemoveAllRoleMembers FROM ' + QUOTENAME(user)
    EXEC (@command)
END
GO

PRINT '-------------------------------------------------------'
PRINT 'Completed execution of UninstallWebEventSqlProvider.SQL'
PRINT '-------------------------------------------------------'
