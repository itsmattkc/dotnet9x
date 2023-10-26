/**********************************************************************/
/* UninstallPersonalization.SQL                                       */
/*                                                                    */
/* Uninstalls the tables, triggers and stored procedures necessary for*/
/* supporting the personalization feature of ASP.Net                  */
/*
** Copyright Microsoft, Inc. 2002
** All Rights Reserved.
*/
/**********************************************************************/

PRINT '--------------------------------------------------'
PRINT 'Starting execution of UninstallPersonalization.SQL'
PRINT '--------------------------------------------------'
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

IF EXISTS ( SELECT * FROM sysusers WHERE issqlrole = 1 AND name = N'aspnet_Personalization_FullAccess'  ) 
BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
      EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Personalization_FullAccess'
  EXEC sp_droprole N'aspnet_Personalization_FullAccess'
END

IF EXISTS ( SELECT * FROM sysusers WHERE issqlrole = 1 AND name = N'aspnet_Personalization_BasicAccess'  ) 
BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
      EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Personalization_BasicAccess'
  EXEC sp_droprole N'aspnet_Personalization_BasicAccess'
END      

IF EXISTS ( SELECT * FROM sysusers WHERE issqlrole = 1 AND name = N'aspnet_Personalization_ReportingAccess'  ) 
BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
      EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Personalization_ReportingAccess'
  EXEC sp_droprole N'aspnet_Personalization_ReportingAccess'
END      

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Personalization_GetApplicationId]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Personalization_GetApplicationId]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationAllUsers_GetPageSettings]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationAllUsers_GetPageSettings]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationAllUsers_ResetPageSettings]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationAllUsers_ResetPageSettings]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationAllUsers_SetPageSettings]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationAllUsers_SetPageSettings]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationAllUsers]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[aspnet_PersonalizationAllUsers]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationPerUser_GetPageSettings]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationPerUser_GetPageSettings]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationPerUser_ResetPageSettings]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationPerUser_ResetPageSettings]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationPerUser_SetPageSettings]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationPerUser_SetPageSettings]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationPerUser]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[aspnet_PersonalizationPerUser]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Paths_CreatePath]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Paths_CreatePath]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Paths]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[aspnet_Paths]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationAdministration_FindState]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationAdministration_FindState]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationAdministration_GetCountOfState]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationAdministration_GetCountOfState]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationAdministration_ResetUserState]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationAdministration_ResetUserState]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationAdministration_ResetSharedState]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationAdministration_ResetSharedState]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_PersonalizationAdministration_DeleteAllState]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_PersonalizationAdministration_DeleteAllState]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[vw_aspnet_WebPartState_Paths]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_aspnet_WebPartState_Paths]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[vw_aspnet_WebPartState_Shared]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_aspnet_WebPartState_Shared]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[vw_aspnet_WebPartState_User]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_aspnet_WebPartState_User]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UnRegisterSchemaVersion]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
    EXEC [dbo].aspnet_UnRegisterSchemaVersion N'Personalization', N'1'
    SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_UnRegisterSchemaVersion FROM ' + QUOTENAME(user)
    EXEC (@command)
END
IF (@RemoveAllRoleMembersExits = 1)
BEGIN
    SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_Setup_RemoveAllRoleMembers FROM ' + QUOTENAME(user)
    EXEC (@command)
END
GO

PRINT '---------------------------------------------------'
PRINT 'Completed execution of UninstallPersonalization.SQL'
PRINT '---------------------------------------------------'
