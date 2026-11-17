# SmallMonsters-MySQL

COP4020 Programming Languages, Assignment 4: SQL (MySQL 8).

This assignment builds on the Small Monsters schema from class.

| File | Contents |
|------|----------|
| `schema.sql`  | The tables from class, plus the new `collector`, `region` and `region_species_link` tables. It also adds an `owner_id` foreign key to `small_monster_actual`, which points to `collector`. |
| `data.sql`    | Sample data: 9 species, 6 types, 6 regions, 4 collectors and 10 actual monsters. |
| `queries.sql` | (1) the monsters a collector owns, (2) the species found in a region and how likely each one is, (3) the regions where a collector can find species they already own. |

## Running

```sql
-- in the mysql client, inside an empty database
SOURCE schema.sql;
SOURCE data.sql;
SOURCE queries.sql;
```

Each query reads its input from a user variable (`@collector_name` or `@region_name`) set just above it. The expected results are written in comments below each query.

## Submission

```sh
zip Assignment4-SQL.zip schema.sql data.sql queries.sql
```
