-- Determine idle sessions with open transactions									                                                                                  
-- Firma: BitHawk AG
-- Script Name: Detecting_idle_sessions.sql
-- Description: The following script searches for sessions that have open transactions and are idle.
-- Sessions for which no request is currently being executed are said to be idle.
-- Created: 18.04.2025
-- Last Modified:
*/

SELECT s.*
FROM sys.dm_exec_sessions AS s
WHERE EXISTS (
        SELECT *
        FROM sys.dm_tran_session_transactions AS t
        WHERE t.session_id = s.session_id
    )
    AND NOT EXISTS (
        SELECT *
        FROM sys.dm_exec_requests AS r
        WHERE r.session_id = s.session_id
);
