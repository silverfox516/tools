#!/usr/bin/bash

function is_array()
{
    local variable_name=$1
    [[ "$(declare -p $variable_name 2>/dev/null)" =~ "declare -a" ]]
}

function is_declared()
{
    local variable_name=$1
    [[ ! "$(declare -p $variable_name 2>/dev/null)" =~ "not found" ]]
}

function pick_item_in_array()
{
    local -n arg_array=$1
    local -n arg_item=$2

    is_array $1
    if [ $? -ne 0 ]; then
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

function print_menu()
{
    local -n arg1=$1

    is_array $1
    if [ ! $? -eq 0 ]; then
        return
    fi

    clear
    echo "Pick a item for $1"
    local i=1
    local choice
    for choice in ${arg1[@]}
    do
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

function add_path()
{
	local -n var=$1

	if [[ "${var}" != *"$2:"* ]]; then
		var=$2:${var}
	fi
}
