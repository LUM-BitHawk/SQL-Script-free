/*
-- Finding information about your query's connection									                                                                                  
-- Firma: BitHawk AG
-- Script Name: querys_connection.sql
-- Description: The following script collects information about a query's own connection:
-- Created: 18.04.2025
-- Last Modified:
*/

SELECT c.session_id,
    c.net_transport,
    c.encrypt_option,
    c.auth_scheme,
    s.host_name,
    s.program_name,
    s.client_interface_name,
    s.login_name,
    s.nt_domain,
    s.nt_user_name,
    s.original_login_name,
    c.connect_time,
    s.login_time
FROM sys.dm_exec_connections AS c
INNER JOIN sys.dm_exec_sessions AS s
    ON c.session_id = s.session_id
WHERE c.session_id = @@SPID;
