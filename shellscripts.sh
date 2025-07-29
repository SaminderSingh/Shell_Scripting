#!/bin/bash


<< Readme 
This is a script for a backup for 5 day roation
Usage:
 ./shellscripts.sh <path to your source> <path to backup folder>
Readme

function display_usage {

 	echo " Usage: ./shellscripts.sh <path to your source> <path to backup folder>"

}

if [ $# -eq 0 ]; then
	display_usage
fi
source_dir=$1
timestamp=$(date '+%Y-%m-%d-%H-%M-%S')
backup_dir=$2
function create_backup {
	zip -r "${backup_dir}/backup_${timestamp}.zip"	"${source_dir}" > /dev/null
	if [ $? -eq 0 ]; then
	echo "Backup Generated Successfully"
	fi
}
create_backup
function perform_rotation {
 	backup=($(ls -t "${backup_dir}/backup_"*.zip 2>/dev/null) )

	if [ "${#backup[@]}" -gt 5 ]; then
		echo "Performing Rotation for 5"
		backups_to_remove=("${backup[@]:5}")
		echo "${backups_to_remove[@]}"
		
		for backup in "${backups_to_remove[@]}";
		do 
			rm -f ${backup}
		done
	fi

}
perform_rotation
