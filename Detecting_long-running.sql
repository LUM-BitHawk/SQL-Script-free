/*
-- Detecting long-running cursors										                                                                                  
-- Firma: BitHawk AG
-- Script Name: Detecting_long-running.sql
-- Description: The following script finds cursors that have been open for 
-- more than a specified period of time, who created the cursors, and which session the cursors are in.
-- Author: Marcel.Luginbuhl@bithawk.ch
-- Created: 18.04.2025
-- Last Modified:
*/
USE master;
GO

SELECT creation_time,
    cursor_id,
    name,
    c.session_id,
    login_name
FROM sys.dm_exec_cursors(0) AS c
INNER JOIN sys.dm_exec_sessions AS s
    ON c.session_id = s.session_id
WHERE DATEDIFF(mi, c.creation_time, GETDATE()) > 5;
GO