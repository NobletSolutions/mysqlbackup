# Mysql/Mariadb Backups Using Systemd Timers

This package installs a backup script that runs using a systemd timer.

`systemctl status mysqlbackup.service` will show the latest status of the service that is only run by the timer. You can manually instigate a run by running `systemctl start mysqlbackup.service`. Viewing output from the run can be done via `journalctl -u mysqlbackup.service`.

## Configuration

### /etc/sysconfig/mysqlbackup

This file contains the required environment variables

```
BACKUP_DIR="/srv/backup"
MYSQLDUMP="/usr/bin/mysqldump"
MYSQL="/usr/bin/mysql"
MY_CNF_FILE=/etc/mysqlbackup/my.cnf
```

These can be edited to point to wherever the administrator desires. The `MY_CNF_FILE` should contain the user and password for login to avoid having to provide them on the command line. Ideally only readable by the user running the service (root).

Backups will end up in `/srv/backup/mysql/latest` and `/srv/backup/mysql/previous` respectively. Meaning that when the service is run it will take everything in the latest directory and move it to the previous directory then commence a backup.

### Custom tasks

To execute specific custom backup tasks ie. to backup a specific table or perform a table subset backup with a where clause place an executable script in `/etc/mysqlbackup.d/`. For example:

```
#/bin/bash

$MYSQLDUMP --defaults-extra-file=$MY_CNF_FILE --force --opt db_name table_name > "$LATEST_DIR/table.sql"
$MYSQLDUMP --defaults-extra-file=$MY_CNF_FILE --force --opt db_name another_table  --where="fk_id IS NULL" >> "$LATEST_DIR/table.sql"

nice -n 5 pbzip2 -p4 $LATEST_DIR/table.sql
```

The rpm requires pbzip2 that allows for parallel bzip2 compression though any other compression could be used.

The script will have the following environment variables it can use

| Var Name     | Desc                                         |
|--------------|----------------------------------------------|
| BACKUP_DIR   | Top level backup directory                   |
| MYSQLDUMP    | Full path of the mysqldump binary            |
| MYSQL        | Full path to the mysql/mariadb binary        |
| MY_CNF_FILE  | Full path to the my.cnf file for credentials |
| LATEST_DIR   | Full path to the current backup directory    |
| PREVIOUS_DIR | Full path to the previous backup directory   |

