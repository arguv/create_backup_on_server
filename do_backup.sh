#!/bin/bash

handler_error()
{
	mail -s "Server Backup Error Failed - $(date)" email@email.com < /root/backup/backup_error
	echo 'Backup error: '$(date) >> /root/backups_log.txt
}

trap 'handler_error' ERR
set -e

FILENAME=server_backup-$(date +%Y-%m-%d-%s).tar.gz
FILETOBACKUP="vhosts"
AWS="s3://folder_on_amazon"
BACKUPS="/home/backups/"
PARENTTOBACKUP="/var/www/"
DBF="all_databses"$(date +%Y-%m-%d-%s).sql

cd ${PARENTTOBACKUP}
tar -czf ${BACKUPS}${FILENAME} ${PARENTTOBACKUP}${FILETOBACKUP}

mysqldump -u backup_user --password="password_of_databases" --all-databases > /home/backups/${DBF}

cd ${BACKUPS}

s3cmd put ${FILENAME} ${AWS}
s3cmd put /home/backups/${DBF} ${AWS}

rm ${BACKUPS}${FILENAME}
rm /home/backups/${DBF}

mail -s "Server Backup Done - $(date)" email@email.com < /root/backup/backup_complete

echo 'Backup Completed. '$(date) >> /root/backups_log.txt