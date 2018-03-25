## Postgres Query Tuning

From: https://www.geekytidbits.com/performance-tuning-postgres/

#### Indexes

1. Eliminate Sequential Scans (Seq Scan) by adding indexes (unless table size is small)
2. If using a multicolumn index, make sure you pay attention to order in which you define the included columns - More info
3. Try to use indexes that are highly selective on commonly-used data. This will make their use more efficient.
WHERE clause
4. Avoid LIKE
5. Avoid function calls in WHERE clause
6. Avoid large IN() statements

#### JOINs
1. When joining tables, try to use a simple equality statement in the ON clause (i.e. a.id = b.person_id). Doing so allows more efficient join techniques to be used (i.e. Hash Join rather than Nested Loop Join)
2. Convert subqueries to JOIN statements when possible as this usually allows the optimizer to understand the intent and possibly chose a better plan
3. Use JOINs properly: Are you using GROUP BY or DISTINCT just because you are getting duplicate results? This usually indicates improper JOIN usage and may result in a higher costs
4. If the execution plan is using a Hash Join it can be very slow if table size estimates are wrong. Therefore, make sure your table statistics are accurate by reviewing your vacuuming strategy
5. Avoid correlated subqueries where possible; they can significantly increase query cost
6. Use EXISTS when checking for existence of rows based on criterion because it “short-circuits” (stops processing when it finds at least one match)


#### General guidelines
1. Do more with less; CPU is faster than I/O
2. Utilize Common Table Expressions and temporary tables when you need to run chained queries
3. Avoid LOOP statements and prefer SET operations
4. Avoid COUNT(*) as PostgresSQL does table scans for this (versions <= 9.1 only)
5. Avoid ORDER BY, DISTINCT, GROUP BY, UNION when possible because these cause high startup costs
6. Look for a large variance between estimated rows and actual rows in the EXPLAIN statement. If the count is very different, the table statistics could be outdated and PostgreSQL is estimating cost using inaccurate statistics. For example: Limit (cost=282.37..302.01 rows=93 width=22) (actual time=34.35..49.59 rows=2203 loops=1). The estimated row count was 93 and the actual was 2,203. Therefore, it is likely making a bad plan decision. You should review your vacuuming strategy and ensure ANALYZE is being run frequently enough.

