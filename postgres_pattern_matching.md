### Pattern Matching with LIKE...

## Intro
Postgres supports these pattern matching phrases
- `LIKE` or `~~`
  - simple, not versatile, fast, especially fast when B-tree index in place 
- `ILIKE` or `~~*`
  - similar to `LIKE` but case insensitive, slightly slower than `LIKE`
- `~` for regex matching
  - supports more variations, may be slow in cases
- `SIMILAR TO`: in between `LIKE` and regex matching
  - probably no need to use, ever, if we master the other two


## Add Index For LIKE

#### B-tree
When matching from beginning of word, `LIKE 'blah%'`, we can add regular B-tree index on a column, or combination of columns to boost performance 
 
 
From [Postgres Doc](https://www.postgresql.org/docs/9.6/static/indexes-types.html):
> The optimizer can also use a B-tree index for queries involving the pattern matching operators LIKE and ~ if the pattern is a constant and is anchored to the beginning of the string — for example, col LIKE 'foo%' or col ~ '^foo', but not col LIKE '%bar'. 

Builtin [operator class](https://www.postgresql.org/docs/current/static/indexes-opclass.html) `text_pattern_ops` can be used on B-tree to speed up text type searching using LIKE or regex. Note the `xxx_pattern_ops` are only for words matching, if we want to use operators like `<, <=, >, or >=`, we still need B-tree index with default operator class.
```
CREATE INDEX test_index ON test_table (col varchar_pattern_ops);
```


###  pg_trgm
> The pg_trgm module provides functions and operators for determining the similarity of ASCII alphanumeric text based on trigram matching, as well as index operator classes that support fast searching for similar strings.

pg_trgm module support GIST and GIN indexes. It will help speed up both`LIKE` and regex matching, some tests show it's 10X faster than B-tree for table with 500k rows. 

**Setup**
```
CREATE EXTENSION pg_trgm;
CREATE INDEX trgm_idx_gin__account_name ON account USING gin (name gin_trgm_ops);
CREATE INDEX trgm_idx_gist__account_name ON account USING gist (name gist_trgm_ops);
```


#### pg_trgm for jsonb?
I've searched the postgres doc and googled, yet I can't find whether 'pg_trgm' works for sub key in jsonb column. From my limited testing, it doesn't help with pattern matching for jsonb. If you know the answer, please contact me or comment here. Thank you!

