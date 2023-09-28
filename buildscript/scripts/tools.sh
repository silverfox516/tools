#!/bin/bash

#[ -n "${SCRIPTS_TOOLS}" ] && return; SCRIPTS_TOOLS=0; # pragma once

function bs_fatal()
{
    echo -e "${COLORS[lightred]}'ctrl + c' to quit${COLORS[nc]}, $@"
    while [ 1 ]; do sleep 5; done
}

function bs_wrapper()
{
    if [ "${DEBUG}" == "true" ]; then
        echo $@
        return
    fi

    $@
    if [ $? -eq 0 ]; then return; fi

    bs_fatal "failed $@"
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
    local -n array=$1
    local -n item=$2

    if ! bs_is_array $1; then return 1; fi

    for i in ${array[@]}; do
        if [ "$i" != "$item" ]; then continue; fi

        unset array
        array=$i
        return 0
    done

    return 1
}

function bs_print_menu()
{
    local -n options=$1

    if ! bs_is_array $1; then return; fi

    #clear
    echo "Pick a item for $1"
    local i=1
    local choice
    for choice in ${options[@]}; do
        echo "    $i. $choice"
        i=$(($i+1))
    done
    echo -n "Which would you select? "
    read answer

    local selection=
    if [ -z "$answer" ]; then
        exit 1
    elif (echo -n $answer | grep -q -e "^[0-9][0-9]*$"); then
        if [ $answer -le ${#options[@]} ]; then
            selection=${options[$(($answer-1))]}
        fi
    else
        selection=$answer
    fi

    unset options
    options=$selection
}
