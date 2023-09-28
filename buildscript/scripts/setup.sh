#!/bin/bash

source ${BS_DIR}/scripts/colors.sh
source ${BS_DIR}/scripts/tools.sh

# for usage
declare -A targets_info

# $1 - variable name to set model variable list
# $2 - model name
function bs_parse_model_vars()
{
    local -n var_list=$1
    local -n model=$2

    var_list=""

    while read line; do
        if [[ ${line} != *"="* ]]; then continue; fi

        local key=$(echo ${line} | cut -d"=" -f 1)
        local value=$(echo ${line} | cut -d"=" -f 2)

        var_list="${var_list} $key"
        eval ${key}=${value}
    done < ${BS_DIR_MODELS}/${model}
}

# $1 - variable including model variables
function bs_menu_of_array_vars()
{
    local -n var_list=$1

    for var in ${var_list}; do
        if ! bs_is_array ${var}; then continue; fi

        bs_print_menu ${var}
    done
}

function bs_parse_targets() {
    local target_files=(`ls ${BS_DIR_TARGETS}`)

    for target in ${target_files[@]}; do
        source ${BS_DIR_TARGETS}/${target}

        # check var is defined in REQUIRED_VARS
        for var in ${REQUIRED_VARS[@]}; do
            if ! bs_is_declared ${var}; then
                bs_fatal "$var is required but not declared"
            fi
        done

        # generate target function
        local str_func="function ${BS_PRJ}_${target}() {"
        for key in ${!COMMANDS[@]}; do
            str_func="${str_func} bs_wrapper ${COMMANDS[$key]};"
        done
        str_func="${str_func} }"
        bs_wrapper eval ${str_func}

        # set description for usage
        targets_info[${BS_PRJ}_${target}]=${DESC}

        # clear current target's variables
        unset DESC
        unset REQUIRED_VARS
        unset COMMANDS
    done
}

function bs_usage() {
    echo -e "${COLORS[lightcyan]}Available Targets:${COLORS[nc]}"
    for t in ${!targets_info[@]}; do
        echo -e "  ${COLORS[lightblue]}$t${COLORS[nc]}\t: ${targets_info[$t]}"
    done
}

MODELS=(`ls ${BS_DIR_MODELS}`)
bs_print_menu MODELS
bs_parse_model_vars MODEL_VARS MODELS
bs_menu_of_array_vars MODEL_VARS
bs_parse_targets
bs_usage
