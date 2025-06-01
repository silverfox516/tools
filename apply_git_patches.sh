#!/bin/bash

DIR_SRC=
DIR_DST=
OPT_PREFIX=""

SCRIPT_NAME=$0

VERBOSE=true

FILE_PATCH_INFO=$(mktemp)

CR="\033[0;91m"
CG="\033[0;92m"
CB="\033[0;94m"
NC="\033[0m"

function usage()
{
    echo "Usage : ./$1 [-p prefix] src_dir dst_dir"
    echo "   -p : prefix of patch files to apply, if not given then patch all"
}

function bs_fatal()
{
    local C="\033[0;31m"
    local NC="\033[0m"

    echo -e "${C}failed to run $@${NC}"
    return 1
    #echo -e "${C}'ctrl + c' to quit${NC}, $@"
    #while [ 1 ]; do sleep 5; done
}

function bs_wrapper()
{
    local C="\033[0;94m"
    local NC="\033[0m"

    if [ "${VERBOSE}" == "true" ]; then
        echo -e "run : ${C}$@${NC}"
    fi

    eval "$@"
    if [ $? -eq 0 ]; then return; fi

    bs_fatal "failed $@"
}

function parse_patches()
{
    local dir_src=$1
    local dir_dst=$2
    local patch_files=$(find ${dir_src} -name "${OPT_PREFIX}*patch" | sort)

    > $FILE_PATCH_INFO
    for p in ${patch_files}; do
        local root=$(dirname ${p})        # /a/b/src_dir/pa/th/some.patch -> /a/b/src_dir/pa/th
        local root=${root##${dir_src}/}   # pa/th/
        printf "%s  %s  %-40s  %s\n" $dir_src $dir_dst $root $(basename $p) >> $FILE_PATCH_INFO
    done

    echo $FILE_PATCH_INFO
}

function get_git_root()
{
    rp=$(realpath $1)

    while [ ${rp} != "/" ]; do
        if [ -d ${rp}/.git ]; then
            break
        fi
        rp=$(dirname $rp)
    done

    echo $rp
}

# parse opt
while getopts 'p:h' opt; do
    case "$opt" in
        p) OPT_PREFIX=${OPTARG} ;;
        ?|h) usage ${SCRIPT_NAME}; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

# check args
if [ $# -ne 2 ]; then
    usage ${SCRIPT_NAME}
    bs_fatal
fi

if [ ! -d $1 ]; then
    bs_fatal "$1 is not exist or a directory"
fi
if [ ! -d $2 ]; then
    bs_fatal "$2 is not exist or a directory"
fi
DIR_SRC=$(realpath $1)
DIR_DST=$(realpath $2)

# parse patch files
FILE_CACHE=$(parse_patches ${DIR_SRC} ${DIR_DST})

echo -e "\n${CG}patch from ${DIR_SRC} to ${DIR_DST}...${NC}"
if [ "${VERBOSE}" == "true" ]; then
    echo -e "\n${CG}list patch files selected...${NC}"
    cat ${FILE_CACHE}
fi

# patch
declare -A GIT_INIT_COMMITS
FAILED=false
OPTS="--ignore-space-change --ignore-whitespace --whitespace=nowarn"

while read -r dir_src dir_dst root patch; do
    target_git=${dir_dst}/${root}
    target_git=$(get_git_root $target_git)

    if [[ -z ${GIT_INIT_COMMITS[$target_git]} ]]; then
        cd ${target_git}
        GIT_INIT_COMMITS[$target_git]=$(git rev-parse HEAD)
        echo -e "\n${CG}cache before git:$target_git commit:${GIT_INIT_COMMITS[$target_git]} ${NC}"
        cd - > /dev/null
    fi

    bs_wrapper git -C ${dir_dst}/${root} am ${OPTS} ${dir_src}/${root}/${patch}
    if [ $? -ne 0 ]; then
        bs_wrapper git -C ${dir_dst}/${root} am --abort
        FAILED=true
        break
    fi
done < ${FILE_CACHE}

# reset if fails
if [ "${FAILED}" == "true" ]; then
    echo -e "\n${CR}failed to patch, ${CG}reset all...${NC}"

    for g in ${!GIT_INIT_COMMITS[@]}; do
        bs_wrapper "git -C ${g} reset --hard ${GIT_INIT_COMMITS[$g]}"
    done
fi

rm $FILE_PATCH_INFO
