#!/bin/bash

OPT_DIR_SRC=
OPT_DIR_DST=
OPT_PREFIX=""

SCRIPT_NAME=$0

VERBOSE=true
C="\033[0;92m"
NC="\033[0m"

function usage()
{
#    echo "Usage : ./$1 [-s src_dir] [-d dst_dir] [-w] [-p prefix]"
#    echo "   -s : directory containing patch files"
#    echo "   -d : directory to apply patch files to"
    echo "Usage : ./$1 [-p prefix] src_dir dst_dir"
    echo "   -p : prefix of patch files to apply, if not given then patch all"
}

function bs_fatal()
{
    local C="\033[0;31m"
    local NC="\033[0m"

    echo -e "${C}'ctrl + c' to quit${NC}, $@"
    read answer
    if [ "${answer}" == y ]; then
        echo -e "${C}just continue...${NC}"
    else
        exit 1
    fi
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

function run_after_confirm()
{
    local C="\033[0;95m"
    local NC="\033[0m"

    echo -e -n "${C}y to run \"$@\", otherwise stop : ${NC}"
    read answer
    if [ "${answer}" == y ]; then
        bs_wrapper "$@"
    else
        exit 1
    fi
}

while getopts 's:d:wcp:h' opt; do
  case "$opt" in
#    s) OPT_DIR_SRC=${OPTARG} ;;
#    d) OPT_DIR_DST=${OPTARG} ;;
    p) OPT_PREFIX=${OPTARG} ;;
    ?|h) usage ${SCRIPT_NAME}; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

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
OPT_DIR_SRC=$(realpath $1)
OPT_DIR_DST=$(realpath $2)

PATCH_FILES=$(find ${OPT_DIR_SRC} -name "${OPT_PREFIX}*patch" | sort)

cd ${OPT_DIR_DST}

echo -e "${C}checking patch files whether can be patched or not...${NC}"
for p in ${PATCH_FILES}; do
  PATCH_ROOT=$(dirname ${p})                  # /a/b/src_dir/pa/th/some.patch -> /a/b/src_dir/pa/th
  PATCH_ROOT=${PATCH_ROOT##${OPT_DIR_SRC}/}   # pa/th/
  bs_wrapper git apply --check --directory=${PATCH_ROOT} ${p}
done

echo -e "${C}all patch files can be applied, apply...${NC}"
for p in ${PATCH_FILES}; do
  PATCH_ROOT=$(dirname ${p})                  # /a/b/src_dir/pa/th/some.patch -> /a/b/src_dir/pa/th
  PATCH_ROOT=${PATCH_ROOT##${OPT_DIR_SRC}/}   # pa/th/
  printf "${C}%s${NC} to ${C}%s${NC}\n" $(basename ${p}) ${PATCH_ROOT}
  bs_wrapper git apply --directory=${PATCH_ROOT} ${p}
done

cd -
