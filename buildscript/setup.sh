#!/usr/bin/bash

# FIXME
source ../shell_color.sh

PRJ=test

# for usage
declare -A TARGETS_INFO

function bs_fatal()
{
    echo -e "${COLORS[lightred]}'ctrl + c' to quit, command failed:${COLORS[nc]} $@"
    while [ 1 ]; do sleep 5; done
}

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

    bs_fatal $@
}

function bs_parse_targets() {
    DIR_TARGETS=targets
    TARGET_FILES=(`ls ${DIR_TARGETS}`)

    for t in ${TARGET_FILES[@]}; do
        source ${DIR_TARGETS}/$t

        # generate target function
        STR_FUNC="function ${PRJ}_${t}() {"
        for key in ${!COMMANDS[@]}; do
            STR_FUNC="${STR_FUNC} bs_wrapper ${COMMANDS[$key]};"
        done
        STR_FUNC="${STR_FUNC} }"
        bs_wrapper eval ${STR_FUNC}

        TARGETS_INFO[${PRJ}_${t}]=${DESC}

        unset COMMANDS
        unset DESC
    done
}

function bs_usage() {
    echo -e "${COLORS[lightcyan]}Available Targets:${COLORS[nc]}"
    for t in ${!TARGETS_INFO[@]}; do
        echo -e "  ${COLORS[lightblue]}$t${COLORS[nc]}\t: ${TARGETS_INFO[$t]}"
    done
}

bs_parse_targets
bs_usage
