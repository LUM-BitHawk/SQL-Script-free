/*
-- Combining two queries into one related to missing indexes in SQL Server									                                                                                  
-- Firma: BitHawk AG
-- Script Name: two_queries_into_one.sql
-- Description: Instead of switching back and forth between the two result sets, I'm trying to combine them into one query. 
-- This allows me to directly see which cached query plan from sys.dm_exec_query_plan() corresponds to which missing index in sys.dm_db_missing_index_details.
-- The current iteration of my query looks like this:
-- Created: 18.04.2025
-- Last Modified:
*/

SELECT CONVERT(decimal(18,2), user_seeks * avg_total_user_cost * (avg_user_impact * 0.01)) AS [index_advantage], 
migs.last_user_seek, mid.[statement] AS [Database.Schema.Table], qps.ProcName, qps.objtype, qps.usecounts,
mid.equality_columns, mid.inequality_columns, mid.included_columns,
migs.unique_compiles, migs.user_seeks, migs.avg_total_user_cost, migs.avg_user_impact,
OBJECT_NAME(mid.[object_id]) AS [Table Name], p.rows AS [Table Rows]
,qps.query_plan
FROM sys.dm_db_missing_index_group_stats migs WITH (NOLOCK)
INNER JOIN sys.dm_db_missing_index_groups mig WITH (NOLOCK) ON migs.group_handle = mig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details mid WITH (NOLOCK) ON mig.index_handle = mid.index_handle
INNER JOIN sys.partitions p WITH (NOLOCK) ON p.[object_id] = mid.[object_id]
Left Outer Join (
    Select top 50 OBJECT_NAME(qp.objectid) ProcName, cp.objtype, qp.query_plan, cp.usecounts, d.referenced_id
    From sys.dm_exec_cached_plans cp With (NOLOCK)
    Cross Apply sys.dm_exec_query_plan(cp.plan_handle) qp
    Left Outer Join sys.sql_expression_dependencies d With (NOLOCK) on d.referencing_id = qp.objectid
    Where qp.dbid = DB_ID()
        And cast(query_plan as nvarchar(max))  like N'%MissingIndex Database="#[' + db_name() + '#]" Schema="#[dbo#]" Table="#[' + d.referenced_entity_name +N'#]"%' escape '#'
    Order By cp.usecounts desc
      ) qps on cast(qps.query_plan as nvarchar(max))  like N'%MissingIndex%'
        + Case When mid.equality_columns is null then ''
                else 'Column Name="' + Replace(Replace(Replace(mid.equality_columns, ', ', 'Column Name="'), '[', '#['), ']', '#]%') end
        + Case When mid.inequality_columns is null then ''
                else 'Column Name="' + Replace(Replace(Replace(mid.inequality_columns, ', ', 'Column Name="'), '[', '#['), ']', '#]%') end
        + Case When mid.included_columns is null then ''
                else 'Column Name="' + Replace(Replace(Replace(mid.included_columns, ', ', 'Column Name="'), '[', '#['), ']', '#]%') end
      escape '#'
        And mid.object_id = qps.referenced_id
WHERE mid.database_id = DB_ID()
AND p.index_id < 2 
ORDER BY index_advantage DESC OPTION (RECOMPILE);
