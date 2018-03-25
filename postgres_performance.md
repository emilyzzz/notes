## Postgres 9.6



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


**Query**
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
```


**Result** 
_all time in miliseconds_
```
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