### Users management (using mysql console app)
Enter mysql (user must have access to create other users):
```bash
mysql -u <username> -p
```

Create user:
```sql
CREATE USER <username> IDENTIFIED WITH sha256_password BY '<password>';
```

After that you can switch to new user (but it still have no access granted). <br>
This user even can't make SELECT query to any table. <br>
Show current user:
```sql
SELECT USER();
```

Show all users (get info from system table `mysql`):
```sql
SELECT Host, User FROM mysql.user;
```

Drop user:
```sql
DROP USER <username>;
```
`DROP` operator doesn't close active user sessions, so this one can still work until session is interrupted.

Rename user:
```sql
RENAME USER <old_name> TO <new_name>;
```

Grant users' privileges:
```sql
GRANT {ALL  | GRANTING OPTION | REPLICATION SLAVE | {priv_type_1[(<column_name_1>,...,<column_name_n>)],...,priv_type_n[(<column_name_1>,...,<column_name_n>)]}}  
    ON <database_name>.<table_name> TO '<username>'@'<hostname>'
    [IDENTIFIED WITH sha256_password BY '<password>']
    [WITH GRANT OPTION]
    [
    <variable_1> <value_1>
    ...
    <variable_n> <value_n>
    ];
```
priv_type = `{USAGE | SELECT | INSERT | DELETE | UPDATE}` <br>
Use `ALL` to give all access except access assign rights (`GRANTING OPTION`) to yourself and other users. `ALL` Cannot be used with other operators. <br>
Use `GRANTING OPTION` to give access assign rights. <br>
Use `USAGE` to grant no access - revoke access (opposit to `ALL`). Can be used with other operators. <br>
USE `REPLICATION SLAVE` to get access to binary log-file. <br>
Use `IDENTIFIED WITH sha256_password BY '<password>'` construction to create user with password and grant access to him. <br>
Use `*` in database_name/table name field to give access to all databases/tables. <br>
Use `%` in hostname field to give access to mysql-server from any host. <br>
__*Examples:*__
```sql
GRANT SELECT, INSERT ON *.* TO foo;
GRANT ALL ON *.* TO foo;
GRANT GRANT OPTION ON *.* TO foo;
GRANT ALL ON *.* TO 'foo'@'localhost' WITH GRANT OPTION;
GRANT USAGE, SELECT ON *.* TO foo;
GRANT SELECT (`id`, `name`), UPDATE (`name`) ON vk_messenger.users TO foo;
GRANT ALL ON vk_messenger.* TO 'foo'@'localhost' IDENTIFIED WITH sha256_password BY 'pass'
    WITH MAX_CONNECTIONS_PER_HOUR 10
    MAX_QUERIES_PER_HOUR 1000
    MAX_UPDATES_PER_HOUR 200
    MAX_USER_CONNECTIONS 3;
```

Revoke user rights:
```sql
REVOKE {ALL  | GRANTING OPTION | {priv_type_1[(<column_name_1>,...,<column_name_n>)],...,priv_type_n[(<column_name_1>,...,<column_name_n>)]}} 
    ON <database_name>.<table_name> FROM '<username>'@'<hostname>';
```

Show current user access:
```sql
SHOW GRANTS;
```