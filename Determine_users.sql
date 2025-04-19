/*
-- Determine users connected to the server										                                                                                  
-- Firma: BitHawk AG
-- Script Name: Determine_users.sql
-- Description: The following determines the users connected to the server and returns the number of sessions for each user.
-- Author: Marcel.Luginbuhl@bithawk.ch
-- Created: 18.04.2025
-- Last Modified:
*/
SELECT login_name,
    COUNT(session_id) AS session_count
FROM sys.dm_exec_sessions
GROUP BY login_name;
