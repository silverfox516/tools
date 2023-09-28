#!/bin/bash

source ${BS_DIR}/scripts/colors.sh
source ${BS_DIR}/scripts/tools.sh

# for usage
declare -A TARGETS_INFO

# $1 - variable name to set model variable list
# $2 - model name
function bs_parse_model_vars()
{
    local -n variable=$1
    local model=$2
    variable=""

    while read line; do
        if [[ $line != *"="* ]]; then continue; fi

        local key=$(echo $line | cut -d"=" -f 1)
        local value=$(echo $line | cut -d"=" -f 2)

        variable="$variable $key"
        eval $key=$value
    done < ${BS_DIR_MODELS}/${model}
}

# $1 - variable name to set model variable list
function bs_handle_array_vars()
{
    local -n vars=$1

    for v in $vars; do
        bs_is_array $v
        if [ $? -eq 0 ]; then
            bs_print_menu $v
        fi
    done
}

function bs_parse_targets() {
    TARGET_FILES=(`ls ${BS_DIR_TARGETS}`)

    for t in ${TARGET_FILES[@]}; do
        source ${BS_DIR_TARGETS}/$t

        # generate target function
        STR_FUNC="function ${BS_PRJ}_${t}() {"
        for key in ${!COMMANDS[@]}; do
            STR_FUNC="${STR_FUNC} bs_wrapper ${COMMANDS[$key]};"
        done
        STR_FUNC="${STR_FUNC} }"
        bs_wrapper eval ${STR_FUNC}

        # set description for usage
        TARGETS_INFO[${BS_PRJ}_${t}]=${DESC}

        # clear current target's variables
        unset DESC
        unset REQUIRED_VARS
        unset COMMANDS
    done
}

function bs_usage() {
    echo -e "${COLORS[lightcyan]}Available Targets:${COLORS[nc]}"
    for t in ${!TARGETS_INFO[@]}; do
        echo -e "  ${COLORS[lightblue]}$t${COLORS[nc]}\t: ${TARGETS_INFO[$t]}"
    done
}

bs_parse_model_vars MODEL_VARS model_a
bs_handle_array_vars MODEL_VARS
bs_parse_targets
bs_usage
