/**********************************************************************/
/* UninstallProfile.SQL                                       */
/*                                                                    */
/* Uninstalls the tables, triggers and stored procedures necessary for*/
/* supporting the aspnet feature of ASP.Net                           */
/*
** Copyright Microsoft, Inc. 2002
** All Rights Reserved.
*/
/**********************************************************************/

PRINT '--------------------------------------------------'
PRINT 'Starting execution of UninstallProfile.SQL'
PRINT '--------------------------------------------------'
GO

SET QUOTED_IDENTIFIER OFF -- We don't use quoted identifiers
SET ANSI_NULLS ON         -- We don't want (NULL = NULL) == TRUE
GO
SET ANSI_PADDING ON
GO

USE [aspnetdb]
DECLARE @command nvarchar(4000)
DECLARE @RemoveAllRoleMembersExits bit
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

IF EXISTS ( SELECT * FROM dbo.sysusers WHERE issqlrole = 1 AND name = N'aspnet_Profile_FullAccess'  ) BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
     EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Profile_FullAccess'
  EXEC sp_droprole N'aspnet_Profile_FullAccess' 
END      

IF EXISTS ( SELECT * FROM dbo.sysusers WHERE issqlrole = 1 AND name = N'aspnet_Profile_BasicAccess'  ) BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
     EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Profile_BasicAccess'
  EXEC sp_droprole N'aspnet_Profile_BasicAccess'
END      

IF EXISTS ( SELECT * FROM dbo.sysusers WHERE issqlrole = 1 AND name = N'aspnet_Profile_ReportingAccess'  ) BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
    EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Profile_ReportingAccess'
  EXEC sp_droprole N'aspnet_Profile_ReportingAccess'
END      

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Profile_GetProperties]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Profile_GetProperties]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Profile_SetProperties]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Profile_SetProperties]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Profile_GetProfiles]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Profile_GetProfiles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Profile_GetNumberOfInactiveProfiles]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Profile_GetNumberOfInactiveProfiles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Profile_DeleteInactiveProfiles]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Profile_DeleteInactiveProfiles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Profile_DeleteProfiles]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Profile_DeleteProfiles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Profile]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[aspnet_Profile]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[vw_aspnet_Profiles]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_aspnet_Profiles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UnRegisterSchemaVersion]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
    EXEC [dbo].aspnet_UnRegisterSchemaVersion N'Profile', N'1'
    SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_UnRegisterSchemaVersion FROM ' + QUOTENAME(user)
    EXEC (@command)
END
IF (@RemoveAllRoleMembersExits = 1)
BEGIN
    SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_Setup_RemoveAllRoleMembers FROM ' + QUOTENAME(user)
    EXEC (@command)
END

PRINT '---------------------------------------------------'
PRINT 'Completed execution of UninstallProfile.SQL'
PRINT '---------------------------------------------------'
