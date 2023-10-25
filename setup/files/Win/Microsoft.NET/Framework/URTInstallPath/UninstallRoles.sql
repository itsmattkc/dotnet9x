/**********************************************************************/
/* UninstallRoles.SQL                                                 */
/*                                                                    */
/* Uninstalls the tables, triggers and stored procedures necessary for*/
/* supporting the aspnet feature of ASP.Net                           */
/*
** Copyright Microsoft, Inc. 2002
** All Rights Reserved.
*/
/**********************************************************************/

PRINT '----------------------------------------'
PRINT 'Starting execution of UninstallRoles.SQL'
PRINT '----------------------------------------'
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

IF EXISTS ( SELECT * FROM sysusers WHERE issqlrole = 1 AND name = N'aspnet_Roles_FullAccess'  ) 
BEGIN
 IF (@RemoveAllRoleMembersExits = 1)
    EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Roles_FullAccess'
  EXEC sp_droprole N'aspnet_Roles_FullAccess' 
END      

IF EXISTS ( SELECT * FROM sysusers WHERE issqlrole = 1 AND name = N'aspnet_Roles_BasicAccess'  ) 
BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
     EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Roles_BasicAccess'
  EXEC sp_droprole N'aspnet_Roles_BasicAccess'
END      

IF EXISTS ( SELECT * FROM sysusers WHERE issqlrole = 1 AND name = N'aspnet_Roles_ReportingAccess'  ) 
BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
      EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Roles_ReportingAccess'
  EXEC sp_droprole N'aspnet_Roles_ReportingAccess'
END      

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UsersInRoles_IsUserInRole]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_UsersInRoles_IsUserInRole]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UsersInRoles_GetRolesForUser]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_UsersInRoles_GetRolesForUser]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Roles_CreateRole]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Roles_CreateRole]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Roles_DeleteRole]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Roles_DeleteRole]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Roles_RoleExists]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Roles_RoleExists]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UsersInRoles_AddUsersToRoles]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_UsersInRoles_AddUsersToRoles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UsersInRoles_RemoveUsersFromRoles]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_UsersInRoles_RemoveUsersFromRoles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UsersInRoles_GetUsersInRoles]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_UsersInRoles_GetUsersInRoles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UsersInRoles_FindUsersInRole]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_UsersInRoles_FindUsersInRole]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Roles_GetAllRoles]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Roles_GetAllRoles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UsersInRoles]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[aspnet_UsersInRoles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Roles]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[aspnet_Roles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[vw_aspnet_Roles]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_aspnet_Roles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[vw_aspnet_UsersInRoles]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_aspnet_UsersInRoles]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UnRegisterSchemaVersion]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
    EXEC [dbo].aspnet_UnRegisterSchemaVersion N'Role Manager', N'1'
    SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_UnRegisterSchemaVersion FROM ' + QUOTENAME(user)
    EXEC (@command)
END
IF (@RemoveAllRoleMembersExits = 1)
BEGIN
    SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_Setup_RemoveAllRoleMembers FROM ' + QUOTENAME(user)
    EXEC (@command)
END

PRINT '-----------------------------------------'
PRINT 'Completed execution of UninstallRoles.SQL'
PRINT '-----------------------------------------'
