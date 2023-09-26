#!/usr/bin/bash

# FIXME
source ../shell_color.sh

PRJ=test

# for help
declare -A TARGETS_INFO

TARGET_FILES=(`ls targets`)


function bs_wrapper()
{
	if [ "${DEBUG}" == "true" ]; then
		echo $@
		return
	fi

	$@
	if [ $? -eq 0 ]; then
		return
	fi

	while [ 1 ]; do
		echo -e "${COLORS[lightred]}'ctrl + c' to quit, command failed:${COLORS[nc]} $@"
		sleep 1
	done
}

function bs_parse_targets() {
	for t in ${TARGET_FILES[@]}; do
		source targets/$t

		eval "function ${PRJ}_${t}() {
			for key in \${!COMMANDS[@]}; do
				bs_wrapper \${COMMANDS[\$key]};
			done
		}"

		TARGETS_INFO[${PRJ}_${t}]=${DESC}
	done
}

function bs_help() {
	echo -e "${COLORS[lightcyan]}Available Targets:${COLORS[nc]}"
	for t in ${!TARGETS_INFO[@]}; do
		echo -e "  ${COLORS[lightblue]}$t${COLORS[nc]}\t: ${TARGETS_INFO[$t]}"
	done
}

bs_parse_targets
bs_help
