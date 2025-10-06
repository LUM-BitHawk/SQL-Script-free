----------------------------------------------------------------------------------------------------
--// Firma:			BitHawk AG																	//--
--// Script Name:	MaintenancePlan_IntegrityCheck.sql											//--
--// Author:		marcel.luginbuehl@bithawk.ch                                                //--
--// Version:		1 / 05.10.2025			                                                    //--
--// Last Modified:																	            //--
--// GitHub:		https://github.com/LUM-BitHawk/SQL-Script-free							    //--
--// Beschreibung:  SQL MaintenancePlan Index Optimize der SQL Datenabnken						//--
----------------------------------------------------------------------------------------------------


USE msdb;
GO

-- Create a new SQL job
EXEC dbo.sp_add_job @job_name = N'BitHawk_MaintenancePlanIndexOptimize';
GO

-- Add a job step to perform database backup
EXEC sp_add_jobstep 
    @job_name = N'BitHawk_MaintenancePlanIndexOptimize',
    @step_name = N'BitHawk_MaintenancePlanIndexOptimizeStep',
    @subsystem = N'TSQL',
    @command = N'EXECUTE [dbo].[IndexOptimize]
    @Databases = ''USER_DATABASES'',
    @LogToTable = ''Y''',
    @retry_attempts = 3,
    @retry_interval = 5;
GO

-- Schedule the job to run nightly
EXEC dbo.sp_add_schedule 
    @schedule_name = N'BitHawk_MaintenancePlanIndexOptimizeSchedule',
    @freq_type = 8,
    @freq_interval = 64,
    @freq_recurrence_factor = 1, 
    @active_start_time = 40000;         
GO

-- Attach the schedule to the job
EXEC dbo.sp_attach_schedule 
    @job_name = N'BitHawk_MaintenancePlanIndexOptimize',
    @schedule_name = N'BitHawk_MaintenancePlanIndexOptimizeSchedule';
GO

-- Associate the job with the SQL Server Agent
EXEC dbo.sp_add_jobserver @job_name = N'BitHawk_MaintenancePlanIndexOptimize';
GO
