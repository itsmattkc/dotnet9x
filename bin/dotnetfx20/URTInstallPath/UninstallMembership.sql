/**********************************************************************/
/* UninstallMembership.SQL                                            */
/*                                                                    */
/* Uninstalls the tables, triggers and stored procedures necessary for*/
/* supporting the aspnet feature of ASP.Net                           */
/*
** Copyright Microsoft, Inc. 2002
** All Rights Reserved.
*/
/**********************************************************************/

PRINT '---------------------------------------------'
PRINT 'Starting execution of UninstallMembership.SQL'
PRINT '---------------------------------------------'
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

IF EXISTS ( SELECT * FROM sysusers WHERE issqlrole = 1 AND name = N'aspnet_Membership_FullAccess'  )
BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
     EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Membership_FullAccess'
  EXEC sp_droprole N'aspnet_Membership_FullAccess'
END

IF EXISTS ( SELECT * FROM sysusers WHERE issqlrole = 1 AND name = N'aspnet_Membership_BasicAccess'  )
BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
     EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Membership_BasicAccess'
  EXEC sp_droprole N'aspnet_Membership_BasicAccess'
END

IF EXISTS ( SELECT * FROM sysusers WHERE issqlrole = 1 AND name = N'aspnet_Membership_ReportingAccess'  )
BEGIN
  IF (@RemoveAllRoleMembersExits = 1)
     EXEC [dbo].[aspnet_Setup_RemoveAllRoleMembers] N'aspnet_Membership_ReportingAccess'
  EXEC sp_droprole N'aspnet_Membership_ReportingAccess'
END

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_CreateUser]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_CreateUser]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_GetUserByName]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_GetUserByName]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_GetUserByEmail]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_GetUserByEmail]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_GetPassword]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_GetPassword]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_GetPasswordWithFormat]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_GetPasswordWithFormat]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_UpdateUserInfo]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_UpdateUserInfo]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_SetPassword]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_SetPassword]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_ResetPassword]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_ResetPassword]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_UpdateUser]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_UpdateUser]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_ChangePasswordQuestionAndAnswer]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_ChangePasswordQuestionAndAnswer]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_GetAllUsers]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_GetAllUsers]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_GetNumberOfUsersOnline]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_GetNumberOfUsersOnline]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_FindUsersByName]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_FindUsersByName]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_FindUsersByEmail]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_FindUsersByEmail]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_GetUserByUserId]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_GetUserByUserId]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership_UnlockUser]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
DROP PROCEDURE [dbo].[aspnet_Membership_UnlockUser]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_Membership]') AND OBJECTPROPERTY(id, N'IsUserTable') = 1)
DROP TABLE [dbo].[aspnet_Membership]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[vw_aspnet_MembershipUsers]') AND OBJECTPROPERTY(id, N'IsView') = 1)
DROP VIEW [dbo].[vw_aspnet_MembershipUsers]

IF EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'[dbo].[aspnet_UnRegisterSchemaVersion]') AND OBJECTPROPERTY(id, N'IsProcedure') = 1)
BEGIN
    EXEC [dbo].aspnet_UnRegisterSchemaVersion N'Membership', N'1'
    SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_UnRegisterSchemaVersion FROM ' + QUOTENAME(user)
    EXEC (@command)
END
IF (@RemoveAllRoleMembersExits = 1)
BEGIN
    SET @command = 'REVOKE EXECUTE ON [dbo].aspnet_Setup_RemoveAllRoleMembers FROM ' + QUOTENAME(user)
    EXEC (@command)
END

PRINT '----------------------------------------------'
PRINT 'Completed execution of UninstallMembership.SQL'
PRINT '----------------------------------------------'
