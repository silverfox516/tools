#!/bin/bash

[ -n "${SCRIPTS_COLORS}" ] && return; SCRIPTS_COLORS=0; # pragma once

declare -A COLORS

COLORS[nc]="\033[0m"
COLORS[black]="\033[0;30m"
COLORS[red]="\033[0;31m"
COLORS[green]="\033[0;32m"
COLORS[orange]="\033[0;33m"
COLORS[blue]="\033[0;34m"
COLORS[purple]="\033[0;35m"
COLORS[cyan]="\033[0;36m"
COLORS[lightgray]="\033[0;37m"
COLORS[darkgray]="\033[1;30m"
COLORS[lightred]="\033[1;31m"
COLORS[lightgreen]="\033[1;32m"
COLORS[yellow]="\033[1;33m"
COLORS[lightblue]="\033[1;34m"
COLORS[lightpurple]="\033[1;35m"
COLORS[lightcyan]="\033[1;36m"
COLORS[white]="\033[1;37m"

function print_color()
{
	clear
	i=0
	for k in ${!COLORS[@]}; do
		echo -e -n "${COLORS[$k]}$k${COLORS[nc]}"
		echo -e -n " \033[${i};20H: "
		echo "${COLORS[$k]}"
		i=$((i+1))
	done
}

if [ "$0" == "$BASH_SOURCE" ]; then
	print_color
fi
