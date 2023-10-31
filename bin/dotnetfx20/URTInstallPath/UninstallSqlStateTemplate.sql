/*********************************************************************
  UninstallSqlStateTemplate.SQL                                                
                                                                    
  Uninstalls the tables, and stored procedures used for           
  supporting ASP.NET session state.                                  

  Copyright Microsoft, Inc.
  All Rights Reserved.

 *********************************************************************/

PRINT ''
PRINT '---------------------------------------------------'
PRINT 'Starting execution of UninstallSqlStateTemplate.SQL'
PRINT '---------------------------------------------------'
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

/*
   InstallSqlStateTemplate.sql and UninstallSqlStateTemplate.sql are
   templates files for installing the ASP.NET session state SQL objects
   on a database other than the default 'ASPState'.

   To create your own script files based on the template:
   1. Create your own script files by coping the two template files.
   2. Decide a name for your database (e.g. MyASPStateDB)
   3. In your own script files, replace all occurences of "DatabaseNamePlaceHolder"
      by your database name.
   4. Install and uninstall ASP.NET session state SQL objects using your own
      script files.
*/

/* Drop all tables, startup procedures, stored procedures and types. */

USE master
GO

/* Drop the DeleteExpiredSessions_Job */

DECLARE @sstype nvarchar(128)
SET @sstype = N'sstype_custom'

DECLARE @jobname nvarchar(200)
DECLARE @JobID binary(16)  
SET @jobname = N'DatabaseNamePlaceHolder' + '_Job_DeleteExpiredSessions' 

SELECT @JobID = job_id     
FROM   msdb.dbo.sysjobs    
WHERE (name = @jobname)       
IF (@JobID IS NOT NULL)    
BEGIN  
    -- Check if the job is a multi-server job  
    IF (EXISTS (SELECT  * 
              FROM    msdb.dbo.sysjobservers 
              WHERE   (job_id = @JobID) AND (server_id <> 0))) 
    BEGIN 
        -- There is, so abort the script 
        RAISERROR (N'Unable to import job ''%s'' since there is already a multi-server job with this name.', 16, 1, @jobname) 
    END 
    ELSE 
        -- Delete the [local] job 
        EXECUTE msdb.dbo.sp_delete_job @job_name = @jobname
END

IF UPPER(@sstype) = 'SSTYPE_TEMP' AND OBJECT_ID(N'dbo.ASPState_Startup', 'P') IS NOT NULL BEGIN
    DROP PROCEDURE dbo.ASPState_Startup
END

DECLARE @cmd nchar(4000)

/* Do not need to drop the tables for persisted because ASPState will be dropped */
IF UPPER(@sstype) <> 'SSTYPE_PERSISTED' AND DB_ID(N'tempdb') IS NOT NULL BEGIN
    IF OBJECT_ID(N'[DatabaseNamePlaceHolder].dbo.ASPStateTempSessions','U') IS NOT NULL BEGIN
        DROP TABLE [DatabaseNamePlaceHolder].dbo.ASPStateTempSessions
    END

    IF OBJECT_ID(N'[DatabaseNamePlaceHolder].dbo.ASPStateTempApplications','U') IS NOT NULL BEGIN
        DROP TABLE [DatabaseNamePlaceHolder].dbo.ASPStateTempApplications
    END

END

IF UPPER(@sstype) <> 'SSTYPE_CUSTOM' BEGIN
    /* Drop the database containing our sprocs if we are not using custom database */
    IF DB_ID(N'DatabaseNamePlaceHolder') IS NOT NULL BEGIN
        SET @cmd = N'DROP DATABASE [DatabaseNamePlaceHolder]'
        EXEC(@cmd)
    END        
END    
ELSE IF DB_ID(N'DatabaseNamePlaceHolder') IS NOT NULL BEGIN

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'GetMajorVersion') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.GetMajorVersion'
        EXEC(@cmd)
    END    

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'CreateTempTables') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.CreateTempTables'
        EXEC(@cmd)
    END    

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempGetVersion') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempGetVersion'
        EXEC(@cmd)
    END    

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'GetHashCode') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.GetHashCode'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempGetAppID') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempGetAppID'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempGetStateItem') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempGetStateItem'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempGetStateItem2') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempGetStateItem2'
        EXEC(@cmd)
    END    

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempGetStateItem3') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempGetStateItem3'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempGetStateItemExclusive') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempGetStateItemExclusive'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempGetStateItemExclusive2') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempGetStateItemExclusive2'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempGetStateItemExclusive3') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempGetStateItemExclusive3'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempReleaseStateItemExclusive') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempReleaseStateItemExclusive'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempInsertUninitializedItem') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempInsertUninitializedItem'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempInsertStateItemShort') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempInsertStateItemShort'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempInsertStateItemLong') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempInsertStateItemLong'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempUpdateStateItemShort') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempUpdateStateItemShort'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempUpdateStateItemShortNullLong') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempUpdateStateItemShortNullLong'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempUpdateStateItemLong') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempUpdateStateItemLong'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempUpdateStateItemLongNullShort') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempUpdateStateItemLongNullShort'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempRemoveStateItem') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempRemoveStateItem'
        EXEC(@cmd)
    END

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'TempResetTimeout') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.TempResetTimeout'
        EXEC(@cmd)
    END    

    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'DeleteExpiredSessions') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.DeleteExpiredSessions'
        EXEC(@cmd)
    END

    /* Obselete stored procedure */
    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'DropTempTables') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.DropTempTables'
        EXEC(@cmd)
    END

    /* Obselete stored procedure */
    IF (EXISTS (SELECT name FROM [DatabaseNamePlaceHolder].dbo.sysobjects WHERE (name = N'ResetData') AND (type = 'P'))) BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] DROP PROCEDURE dbo.ResetData'
        EXEC(@cmd)
    END

    IF EXISTS(SELECT name FROM [DatabaseNamePlaceHolder].dbo.systypes WHERE name ='tSessionId') BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] EXECUTE sp_droptype tSessionId'
        EXEC(@cmd)
    END    

    IF EXISTS(SELECT name FROM [DatabaseNamePlaceHolder].dbo.systypes WHERE name ='tAppName') BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] EXECUTE sp_droptype tAppName'
        EXEC(@cmd)
    END    

    IF EXISTS(SELECT name FROM [DatabaseNamePlaceHolder].dbo.systypes WHERE name ='tSessionItemShort') BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] EXECUTE sp_droptype tSessionItemShort'
        EXEC(@cmd)
    END    

    IF EXISTS(SELECT name FROM [DatabaseNamePlaceHolder].dbo.systypes WHERE name ='tSessionItemLong') BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] EXECUTE sp_droptype tSessionItemLong'
        EXEC(@cmd)
    END    

    IF EXISTS(SELECT name FROM [DatabaseNamePlaceHolder].dbo.systypes WHERE name ='tTextPtr') BEGIN
        SET @cmd = N'USE [DatabaseNamePlaceHolder] EXECUTE sp_droptype tTextPtr'
        EXEC(@cmd)
    END    

END

/*************************************************************/
/*************************************************************/
/*************************************************************/
/*************************************************************/

PRINT ''
PRINT '----------------------------------------------------'
PRINT 'Completed execution of UninstallSqlStateTemplate.SQL'
PRINT '----------------------------------------------------'


