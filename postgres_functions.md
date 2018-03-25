## Return Type

#### Returns SETOF my_table_name 
Postgres requires well defined return type for functions/procedures. If an existing table/view matches the disired column lists, use 
- `RETURNS SETOF my_table_name` 
- `RETURNS SETOF my_view_name` 

```
CREATE OR REPLACE FUNCTION my_join_return_setof_type() RETURNS SETOF my_table1 as $$
    BEGIN
        RETURN QUERY EXECUTE '
            SELECT t2.* FROM my_table1 t1
            INNER JOIN my_table2 t2
                ON (t2.obj->>''order_id'')::integer = t1.id
            LIMIT 20
        ';
    END;
$$ LANGUAGE plpgsql;

SELECT my_join_return_setof_type();          -- returns a tuple each row
SELECT * FROM my_join_return_setof_type();   -- returns regular columns
```


#### Returns SETOF record
If we use `RETURNS SETOF record` in function definition, when every time we call the function:
- it must appear in the 'FROM' clause
- we must cast the returned column using AS, see example below

```
CREATE OR REPLACE FUNCTION my_join_return_setof_record_type() RETURNS SETOF record as $$
    BEGIN
        RETURN QUERY EXECUTE '
            SELECT t2.* FROM my_table1 t1
            INNER JOIN my_table2 t2
                ON (t2.obj->>''order_id'')::integer = t1.id
            LIMIT 20
        ';
    END;
$$ LANGUAGE plpgsql;

SELECT c1,c2,c3 FROM my_join_return_setof_record_type() AS (c1 text, c2 int, c3 jsonb);
```


#### Returns Table Type
Dynamically define a TABLE(c1 type, c2 type) as return type

```
CREATE OR REPLACE FUNCTION my_join_return_table_type() RETURNS TABLE(c1 int, c2 text, c3 int, c4 text) as $$
    BEGIN
        RETURN QUERY EXECUTE '
            SELECT t1.id AS id1, t1.obj->>''name'' AS name1, t1.id AS id2, t2.obj->>''name'' AS name2
            FROM my_table1 t1
            INNER JOIN my_table2 t2
                ON (t2.obj->>''order_id'')::integer = t1.id
            LIMIT 20
        ';
    END;
$$ LANGUAGE plpgsql;

SELECT my_join_return_table_type();          
SELECT * FROM my_join_return_table_type();   
```