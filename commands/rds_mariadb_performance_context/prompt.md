# Domain context: AWS RDS MariaDB performance analysis

Use this block when the user is verifying claims about **Amazon RDS for MariaDB** (Performance Schema, Performance Insights, query diagnostics, parameter limits). Replace placeholders with values for the **target** database the user names.

## Domain description (template)

- **Engine**: MariaDB on Amazon RDS (confirm major.minor with the user, e.g. `10.6.x`).
- **Topology**: e.g. Multi-AZ or single-AZ — confirm with the user.
- **Instance**: confirm **instance class** and **region** (`AWS_PROFILE` / `AWS_REGION` from `.env.ai-sync` or session).
- **Focus**: Performance Schema configuration, Performance Insights API behavior, slow query log, digest / statement digest limits under RDS parameter restrictions.

## Authoritative sources

1. **AWS RDS User Guide — MariaDB**: [engine overview](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MariaDB.html), [limitations](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_MariaDB.Limitations.html), [unsupported features](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MariaDB.Concepts.FeatureNonSupport.html), [versions](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/MariaDB.Concepts.VersionMgmt.html)
2. **AWS RDS Performance Insights**: [PS overview for MariaDB/MySQL](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.EnableMySQL.html), [SQL text limits](https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/USER_PerfInsights.UsingDashboard.SQLTextSize.html)
3. **Performance Insights API**: [GetDimensionKeyDetails](https://docs.aws.amazon.com/performance-insights/latest/APIReference/API_GetDimensionKeyDetails.html), [GetResourceMetrics](https://docs.aws.amazon.com/performance-insights/latest/APIReference/API_GetResourceMetrics.html)
4. **MariaDB 10.6 Knowledge Base** (mariadb.com/kb) — confirm RDS compatibility before treating upstream-only behavior as true for RDS.

## Available tools

- **AWS CLI** (read-only) — use `AWS_PROFILE` and `AWS_REGION` from the environment after `source .env.ai-sync` when applicable.
- **SQL** against the target database (read-only; user approval per query).
- **CloudWatch Logs and Metrics** (read-only).
- **AWS Documentation MCP** (`search_documentation`, `read_documentation`) when configured.
- **Web search and URL fetch**.

## Version and service sensitivity

- RDS engine **minor version**, **support lifecycle**, and **Performance Insights** product changes evolve; always check AWS announcements and the User Guide for the user’s engine version.
- Flag when a source applies to **MySQL** instead of **MariaDB**, **Aurora** instead of **RDS**, or a different **minor** version than the target instance.

## Known pitfalls (verify on the target instance)

- **MariaDB ≠ MySQL**: diverged after 5.5. AWS docs often group them — confirm engine-specific behavior.
- **RDS parameter caps**: e.g. `performance_schema_digests_size` is **capped on RDS** far below upstream maxima. Confirm with `describe-db-parameters` / `SHOW VARIABLES` on the target.
- **PI SQL text truncation**: API response limits differ by operation; full text may require querying Performance Schema directly. Confirm limits in current AWS docs and on-instance variables (`performance_schema_max_digest_length`, etc.).
- **PS management modes**: `Source = System default` vs `Modified` affects who controls Performance Schema; PI may change **runtime** values that differ from the parameter group on disk. Consumer SQL changes can be lost on reboot.
- **Slow query log + CloudWatch**: typically requires **both** `slow_query_log = 1` and appropriate `log_output`; exports alone may not enable file logging.
- **Enhanced Monitoring vs CloudWatch**: CPU and timing semantics differ (hypervisor vs agent).
