#!/bin/bash

#[ -n "${SCRIPTS_TOOLS}" ] && return; SCRIPTS_TOOLS=0; # pragma once

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

function bs_is_array()
{
    local res=$(declare -p $1 2>&1)
    if [[ "$res" == *"declare -a"* ]]; then return 0;  fi
    return 1
}

function bs_is_declared()
{
    local res=$(declare -p $1 2>&1)
    if [[ "$res" != *"not found"* ]]; then return 0;  fi
    return 1
}

function bs_pick_item_in_array()
{
    local -n arg_array=$1
    local -n arg_item=$2

    bs_is_array $1
    if [ ! $? -eq 0 ]; then
        return 1
    fi

    for i in ${arg_array[@]}; do
        if [ "$i" == "$arg_item" ]; then
            unset arg_array
            arg_array=$i
            return 0
        fi
    done

    return 1
}

function bs_print_menu()
{
    local -n arg1=$1

    bs_is_array $1
    if [ ! $? -eq 0 ]; then
        return
    fi

    clear
    echo "Pick a item for $1"
    local i=1
    local choice
    for choice in ${arg1[@]}; do
        echo "    $i. $choice"
        i=$(($i+1))
    done
    echo -n "Which would you select? "
    read answer

    local selection=
    if [ -z "$answer" ]
    then
        exit 1
    elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$")
    then
        if [ $answer -le ${#arg1[@]} ]
        then
            selection=${arg1[$(($answer-1))]}
        fi
    else
        selection=$answer
    fi

    unset arg1
    arg1=$selection
}
