## Postgres 9.6


#### Size of All Databases:: pg_database
```
SELECT d.datname AS Name, pg_catalog.pg_get_userbyid(d.datdba) AS Owner,
  CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT')
    THEN pg_catalog.pg_size_pretty(pg_catalog.pg_database_size(d.datname)) 
    ELSE 'No Access' 
  END AS SIZE 
FROM pg_catalog.pg_database d 
ORDER BY 
  CASE WHEN pg_catalog.has_database_privilege(d.datname, 'CONNECT') 
    THEN pg_catalog.pg_database_size(d.datname)
    ELSE NULL 
  END;
```

#### Biggest Table Sizes:: pg_class
```
SELECT *, pg_size_pretty(total_bytes) AS total
    , pg_size_pretty(index_bytes) AS INDEX
    , pg_size_pretty(toast_bytes) AS toast
    , pg_size_pretty(table_bytes) AS TABLE
  FROM (
  SELECT *, total_bytes-index_bytes-COALESCE(toast_bytes,0) AS table_bytes FROM (
      SELECT c.oid,nspname AS table_schema, relname AS TABLE_NAME
              , c.reltuples AS row_estimate
              , pg_total_relation_size(c.oid) AS total_bytes
              , pg_indexes_size(c.oid) AS index_bytes
              , pg_total_relation_size(reltoastrelid) AS toast_bytes
          FROM pg_class c
          LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
          WHERE relkind = 'r'
  ) a
) a order by total_bytes desc limit 5;

┌───────┬──────────────┬────────────┬──────────────┬─────────────┬─────────────┬─────────────┬─────────────┬─────────┬─────────┬─────────┬─────────┐
│  oid  │ table_schema │ table_name │ row_estimate │ total_bytes │ index_bytes │ toast_bytes │ table_bytes │  total  │  index  │  toast  │  table  │
├───────┼──────────────┼────────────┼──────────────┼─────────────┼─────────────┼─────────────┼─────────────┼─────────┼─────────┼─────────┼─────────┤
│ 13233 │ public       │ product    │  3.59303e+06 │ 639654215   │ 162455797   │  16455761   │ 460742656   │ 6 GB    │ 2 GB    │ 1569 MB │  4 GB   │
│ 15292 │ public       │ account    │  3.02115e+05 │ 127006965   │  72953610   │   4198072   │  49855283   │ 1202 MB │ 695 MB  │ 400 MB  │ 475 MB  │
│ 11830 │ public       │ user       │  1.80452e+04 │  89464094   │  45003735   │    875806   │  43584552   │  853 MB │ 429 MB  │ 84 MB   │ 415 MB  │
│ 11048 │ public       │ user_fav   │   2.3431e+04 │  80903782   │  42059448   │    586629   │  38257704   │  716 MB │ 401 MB  │ 56 MB   │ 364 MB  │
│ 15110 │ public       │ order      │  1.70708e+04 │  43385077   │  26959953   │     39157   │  16385966   │  138 MB │ 257 MB  │ 424 kB  │ 156 MB  │
└───────┴──────────────┴────────────┴──────────────┴─────────────┴─────────────┴─────────────┴─────────────┴─────────┴─────────┴─────────┴─────────┘
```


#### One Table & Its Indexes Size:: pg_tables
```
SELECT
    t.tablename,
    indexname,
    relation_id,
    c.reltuples AS num_rows,
    pg_size_pretty(pg_relation_size(quote_ident(t.tablename)::text)) AS table_size,
    pg_size_pretty(pg_relation_size(quote_ident(indexrelname)::text)) AS index_size,
    CASE WHEN indisunique THEN 'Y'
       ELSE 'N'
    END AS UNIQUE,
    idx_scan AS number_of_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_tables t
LEFT OUTER JOIN pg_class c ON t.tablename=c.relname
LEFT OUTER JOIN
    ( SELECT c.relname AS ctablename, ipg.relname AS indexname, ipg.relfilenode as relation_id, x.indnatts AS number_of_columns, idx_scan, idx_tup_read, idx_tup_fetch, indexrelname, indisunique FROM pg_index x
           JOIN pg_class c ON c.oid = x.indrelid
           JOIN pg_class ipg ON ipg.oid = x.indexrelid
           JOIN pg_stat_all_indexes psai ON x.indexrelid = psai.indexrelid )
    AS foo
    ON t.tablename = foo.ctablename
WHERE t.schemaname='public'
and c.relname = <TABLE_NAME_HERE_> ORDER BY 1,2;
```


#### Current Running Queries:: pg_stat_activity
```
SELECT 
  pid, 
  age(query_start, clock_timestamp()), 
  usename, 
  substring(query, 1, 50) as query
FROM pg_stat_activity
WHERE 
  query NOT IN ('<IDLE>', 'DISCARD ALL', 'COMMIT', 'BEGIN') AND 
  query NOT ILIKE '%pg_stat_activity%' AND
  age(query_start, clock_timestamp()) IS NOT null 
ORDER BY query_start
LIMIT 10;

┌───────┬───────────────────────────────────┬─────────┬────────────────────────────────────────────────────┐
│  pid  │                age                │ usename │                       query                        │
├───────┼───────────────────────────────────┼─────────┼────────────────────────────────────────────────────┤
│  8746 │ -1 mons -12 days -00:13:10.731727 │ user    │                                                   ↵│
│       │                                   │         │ SELECT                                            ↵│
│       │                                   │         │                 cons.conname a                     │
│ 23862 │ -00:00:00.020595                  │ user    │ SELECT user.full -> 'id' AS id                    ↵│
│       │                                   │         │ FROM user                                         ↵│
│       │                                   │         │                                                    │
│ 22195 │ -00:00:00.009927                  │ user    │ SELECT t.oid, typarray                            ↵│
│       │                                   │         │ FROM pg_type t JOIN pg_name                        │
│ 20435 │ -00:00:00.001915                  │ user    │ show standard_conforming_strings                   │
│ 25780 │ -00:00:00.001306                  │ user    │ show standard_conforming_strings                   │
│ 21801 │ -00:00:00.001263                  │ user    │ show standard_conforming_strings                   │
│  1096 │ -00:00:00.000439                  │ user    │ SELECT CAST('test plain returns' AS VARCHAR(60)) A │
└───────┴───────────────────────────────────┴─────────┴────────────────────────────────────────────────────┘
```



#### Check Locks:: pg_locks
```
SELECT 
  locktype, 
  relation::regclass, 
  mode, 
  transactionid AS tid,
  pid, 
  granted
FROM 
  pg_catalog.pg_locks l 
LEFT JOIN 
  pg_catalog.pg_database db
ON 
  db.oid = l.database WHERE db.datname = '<THE DB NAME>'
  -- and mode != 'AccessShareLock' and relation::regclass::text not like '%SOME TEXT TO EXCLUDE%'
AND NOT pid = pg_backend_pid();
```


#### Cache Hit Rate:: pg_statio_user_tables
```
SELECT 
  sum(heap_blks_read) as heap_read, 
  sum(heap_blks_hit)  as heap_hit, 
  (sum(heap_blks_hit) - sum(heap_blks_read)) / sum(heap_blks_hit) as ratio
FROM pg_statio_user_tables;
```

#### Index Use Rate:: pg_stat_user_tables
```
SELECT 
  relname, 
  100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used, 
  n_live_tup rows_in_table
FROM pg_stat_user_tables 
ORDER BY n_live_tup DESC;
```


#### PG_STAT_STATEMENT:: pg_stat_statements

**Setup**
```
# Run in psql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;`

# postgresql.conf
pg_stat_statements.max = 20000
pg_stat_statements.track = 'top'

# Restart Postgres after conf change.

# reset stats to empty
select pg_stat_statements_reset();
```


**Example 1: Slowest by Mean Time**
```
SELECT 
  substring(query, 1, 50) || '...' AS query,
  round(total_time::numeric, 2) AS total_time,
  calls,
  round(mean_time::numeric, 2) AS mean_time,
  round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM pg_stat_statements
ORDER BY 4 DESC
LIMIT 5;

# result, all time in miliseconds
┌───────────────────────────────────────────────────────┬───────────────┬───────┬───────────┬────────────────┐
│                         query                         │  total_time   │ calls │ mean_time │ percentage_cpu │
├───────────────────────────────────────────────────────┼───────────────┼───────┼───────────┼────────────────┤
│ SELECT table1.id, table1.name...                     ↵│ 1642386348.55 │  7098 │ 231387.20 │          32.04 │
│                                                       │               │       │           │                │
│ SELECT generate_xx_and_save()...                     ↵│   56110804.61 │  4435 │  12651.82 │           1.09 │
│                                                       │               │       │           │                │
│ select field1 as name1, json_co->>? as name2...      ↵│       5200.86 │     1 │   5200.86 │           0.00 │
│                                                       │               │       │           │                │
│ SELECT product.name AS prod                          ↵│    1755173.57 │  1425 │   1231.70 │           0.03 │
│ FROM product JOIN locale...                          ↵│               │       │           │                │
│                                                       │               │       │           │                │
│ SELECT product.type AS obj                           ↵│    1832909.87 │  1489 │   1230.97 │           0.04 │
│ FROM product JOIN user...                            ↵│               │       │           │                │
│                                                       │               │       │           │                │
└───────────────────────────────────────────────────────┴───────────────┴───────┴───────────┴────────────────┘
```

**Example 2: Shared Block Hit Rate by Query**
```
# top 20 queries having low cache hit rate

SELECT substring(query, 1, 50) || '...' || E'\n' AS query,
  calls,
  total_time,
  rows,
  100.0 * shared_blks_hit / nullif(shared_blks_hit + shared_blks_read, 0) AS shared_hit_percent
FROM pg_stat_statements
ORDER BY 5 ASC NULLS LAST LIMIT 20;
```

**Example 3: Slowest Queries**
```
SELECT substring(query, 1, 100) || '...' || E'\n' AS query,
  calls,
  total_time,
  rows,
  max_time
FROM pg_stat_statements
ORDER BY 5 DESC LIMIT 20;
```

**Example 4: Slowest Queries, Aggregated**
```
SELECT substring(query, 1, 50) || '...' || E'\n' AS query,
  max(max_time)
FROM pg_stat_statements
GROUP BY 1
ORDER BY 2 DESC LIMIT 20;
```

**Example 5: Slowest Inserts**
```
SELECT substring(query, 1, 50) || '...' || E'\n' AS query,
  max(max_time)
FROM pg_stat_statements
WHERE query LIKE 'INSERT INTO%'
GROUP BY 1
ORDER BY 2 DESC LIMIT 20;
```

**Example 6: Slowest Average Inserts**
```
SELECT substring(query, 1, 50) || '...' || E'\n' AS query,
  round(AVG(mean_time)::numeric, 2)
FROM pg_stat_statements
WHERE query LIKE 'INSERT INTO%'
GROUP BY 1
ORDER BY 2 DESC LIMIT 20;
```


#### Missing Index:: pg_stat_all_tables
```
SELECT
  relname,
  seq_scan - idx_scan AS too_much_seq,
  CASE
    WHEN
      seq_scan - coalesce(idx_scan, 0) > 0
    THEN
      'Missing Index?'
    ELSE
      'OK'
  END,
  pg_relation_size(relname::regclass) AS rel_size, seq_scan, idx_scan
FROM
  pg_stat_all_tables
WHERE
  schemaname = 'public'
  AND pg_relation_size(relname::regclass) > 80000
ORDER BY
  too_much_seq DESC;
```

#### Unused Index:: pg_stat_user_indexes
```
SELECT
  indexrelid::regclass as index,
  relid::regclass as table,
  'DROP INDEX ' || indexrelid::regclass || ';' as drop_statement
FROM
  pg_stat_user_indexes
  JOIN
    pg_index USING (indexrelid)
WHERE
  idx_scan = 0
  AND indisunique is false;
```