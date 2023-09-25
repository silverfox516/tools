#!/usr/bin/bash

# chmod root:root swap.sh

OPT_VERBOSE=1

function log()
{
	if [ ${OPT_VERBOSE} -eq 1 ]; then
		echo $@
	fi
}

function chk_res()
{
	log -n "running \"$@\""
	if "$@"; then
		log ", done."
	else
		echo ", failed."
		exit 1
	fi
}

function chk_size()
{
	if [[ $1 =~ ^[0-9]+G ]]; then
		log "assigning \"$@\" /swapfile"
	else
		echo "invalid size \"$1\""
		exit 1
	fi
}

chk_size $1

chk_res sudo swapoff /swapfile
chk_res sudo rm /swapfile
chk_res sudo fallocate -l $1 /swapfile
chk_res sudo chmod 0600 /swapfile
chk_res sudo mkswap /swapfile
chk_res sudo swapon /swapfile

free -h
