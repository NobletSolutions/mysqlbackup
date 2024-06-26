#!/bin/bash

if [[ -z "$BACKUP_DIR" || -z "$MYSQL" || -z "$MYSQLDUMP" || -z "$MY_CNF_FILE" ]]; then
    echo "Missing required environment variables";
    echo "BACKUP_DIR: '$BACKUP_DIR'"
    echo "MYSQL: '$MYSQL'"
    echo "MYSQLDUMP: '$MYSQLDUMP'"
    echo "MY_CNF_FILE: '$MY_CNF_FILE'"
    exit 1;
fi

# ensure the configured directory has necessary sub directories
mkdir -p $BACKUP_DIR/mysql/{latest,previous}

LATEST_DIR=$BACKUP_DIR/mysql/latest
PREVIOUS_DIR=$BACKUP_DIR/mysql/previous

# get a list of databases
databases=$($MYSQL --defaults-file=$MY_CNF_FILE -e "SHOW DATABASES;" | tr -d "| " | grep -v Database | grep -v information_schema | grep -v performance_schema | grep -v cond_instances)

# Move last backup to previous dir
mv $LATEST_DIR/* $PREVIOUS_DIR/ 2>/dev/null;

# Start process timer - This may not be necessary with the systemd service telling us how long a run takes
date > $LATEST_DIR/time-start.txt;

# dump each database in turn
for db in $databases; do
    echo "Backing up $db schema without data"
    $MYSQLDUMP --defaults-extra-file=$MY_CNF_FILE --force --opt --events --routines --flush-logs --single-transaction --master-data=1 --no-data $db > "$LATEST_DIR/$db-schema.sql"
    echo "Compressing $db-schema.sql"
    nice -n 5 pbzip2 -p4 $LATEST_DIR/$db-schema.sql

    echo "Backing up $db data"
    $MYSQLDUMP --defaults-extra-file=$MY_CNF_FILE --force --opt --flush-logs --single-transaction --master-data=1 --no-create-info --no-create-db $db > "$LATEST_DIR/$db-data.sql"
    echo "Compressing $db"
    nice -n 5 pbzip2 -p5 $LATEST_DIR/$db-data.sql
done

# execute additional custom scripts
for filename in /etc/mysqlbackup.d/*.sh; do
    echo "Running $filename";
    $($filename)
    if [[ $? -ne 0 ]]; then
        echo "$filename errored";
    else
        echo "$filename completed successfully";
    fi
done

date> $LATEST_DIR/time-end.txt
