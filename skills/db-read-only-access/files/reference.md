# MariaDB 10.6 — reference

Use when queries involve charsets, collations, JSON columns, large subqueries, or aggregates where defaults may surprise you.

## Character set: utf8mb3 by default

MariaDB 10.6 defaults to `utf8mb3` (aliased as `utf8`), not `utf8mb4`. Joining or comparing columns with mixed charsets (`utf8mb3` vs `utf8mb4`) can prevent index use because the server converts the narrower side. Verify with `SHOW CREATE TABLE`.

## Implicit type conversion

Comparing a column to a wrongly typed literal (e.g. `varchar_col = 123`) forces casts and can bypass indexes. Match types explicitly; prefer `CAST` on the **literal**, not the column.

## Collation mismatches

Different collations across joined or filtered columns force per-row conversion and can block indexes. Check `SHOW CREATE TABLE` before cross-table joins.

## JSON columns and indexes

You cannot rely on indexing a raw JSON column for arbitrary paths the way you would a normal column. If you must filter on a JSON path, the table typically needs a **persistent** generated column with an index; query that column instead of `JSON_VALUE()` alone in `WHERE` (details depend on engine/version—confirm with schema).

## Subquery materialization

Large non-correlated `IN` subqueries that cannot be semi-joined may be materialized to a temp table; oversize results spill to disk. Consider rewriting as `JOIN` when the inner set is large.

## GROUP_CONCAT truncation

Output is truncated at `group_concat_max_len` (default 1 MB). Mention this if results look cut off.

## COUNT(\*) vs COUNT(col)

`COUNT(*)` counts all rows; `COUNT(col)` skips `NULL`. Pick deliberately on nullable columns.

## Temp tables and filesort

`Using temporary` / `Using filesort` in `EXPLAIN` often accompany `GROUP BY`, `DISTINCT`, `UNION`, or `ORDER BY` on non-indexed expressions. Treat as a cost signal on large tables.
