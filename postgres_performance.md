## Postgres 9.6

### Current Running Queries
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


### PG_STAT_STATEMENT

**Setup**
```
# Run in psql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;`

# postgresql.conf
pg_stat_statements.max = 20000
pg_stat_statements.track = 'top'

# Restart Postgres after conf change.
```


```
SELECT 
  substring(query, 1, 50) || '...' AS query,
  round(total_time::numeric, 2) AS total_time,
  calls,
  round(mean_time::numeric, 2) AS mean_time,
  round((100 * total_time / sum(total_time::numeric) OVER ())::numeric, 2) AS percentage_cpu
FROM pg_stat_statements
ORDER BY round(mean_time::numeric, 2) DESC
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