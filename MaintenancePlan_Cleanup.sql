----------------------------------------------------------------------------------------------------
--// Firma:			BitHawk AG																	//--
--// Script Name:	MaintenancePlan_Cleanup.sql													//--
--// Author:		marcel.luginbuehl@bithawk.ch                                                //--
--// Version:		1 / 06.10.2025			                                                    //--
--// Last Modified:																	            //--
--// GitHub:		https://github.com/LUM-BitHawk/SQL-Script-free							    //--
--// Beschreibung:  SQL MaintenancePlan Cleanup der SQL History							    	//--
----------------------------------------------------------------------------------------------------

USE msdb;
GO

-- Create a new SQL job
EXEC dbo.sp_add_job @job_name = N'BitHawk_MaintenancePlanCleanup';
GO

-- Add a job step to perform database backup
EXEC sp_add_jobstep 
    @job_name = N'BitHawk_MaintenancePlanCleanup',
    @step_name = N'MaintenancePlanCleanupStep',
    @subsystem = N'TSQL',
    @command=N'DECLARE @Date datetime
    SET @Date  = DATEADD(dd,-41,GETDATE())
    EXECUTE msdb.dbo.sysmail_delete_mailitems_sp @sent_before = @Date ;  
    EXECUTE msdb.dbo.sysmail_delete_log_sp @logged_before = @Date ;  
    GO', 
    @retry_attempts = 3,
    @retry_interval = 5;
GO

-- Schedule the job to run nightly
EXEC dbo.sp_add_schedule 
    @schedule_name = N'BitHawk_MaintenancePlanCleanupSchedule',
    @freq_type = 8,
    @freq_interval = 64,
    @freq_recurrence_factor = 1, 
    @active_start_time = 213000;         
GO

-- Attach the schedule to the job
EXEC dbo.sp_attach_schedule 
    @job_name = N'BitHawk_MaintenancePlanCleanup',
    @schedule_name = N'BitHawk_MaintenancePlanCleanupSchedule';
GO

-- Associate the job with the SQL Server Agent
EXEC dbo.sp_add_jobserver @job_name = N'BitHawk_MaintenancePlanCleanup';
GO