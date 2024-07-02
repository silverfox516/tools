#!/bin/bash

DIR_SRC=
DIR_DST=
OPT_PREFIX=""

SCRIPT_NAME=$0

VERBOSE=true
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

    echo -e "${C}'ctrl + c' to quit${NC}, $@"
    while [ 1 ]; do sleep 5; done
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

function parse_patches()
{
  local dir_src=$1
  local dir_dst=$2
  #local file=$(mktemp)
  local file=.patch_info.txt
  local patch_files=$(find ${dir_src} -name "${OPT_PREFIX}*patch" | sort)

  > $file
  for p in ${patch_files}; do
    local root=$(dirname ${p})        # /a/b/src_dir/pa/th/some.patch -> /a/b/src_dir/pa/th
    local root=${root##${dir_src}/}   # pa/th/
    printf "%s  %s  %-40s  %s\n" $dir_src $dir_dst $root $(basename $p) >> $file
  done

  echo $file
}

while getopts 'p:h' opt; do
  case "$opt" in
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
DIR_SRC=$(realpath $1)
DIR_DST=$(realpath $2)

FILE_CACHE=$(parse_patches ${DIR_SRC} ${DIR_DST})


echo -e "\n${CB}list patch files selected...${NC}"
cat ${FILE_CACHE}


echo -e "\n${CB}check patch files whether can be patched or not...${NC}"
FAILED=false
#OPTS="--ignore-space-change --ignore-whitespace --whitespace=nowarn"
while read -r dir_src dir_dst root patch; do
  git -C ${dir_dst}/${root} apply ${OPTS} --check ${dir_src}/${root}/${patch}
  if [ $? -ne 0 ]; then
    echo -e "not patchable : ${CR}${dir_dst}/${root}/  ${patch}${NC}"
    echo -e "may need : ${CB}git -C ${dir_dst}/${root}/ reset --hard HEAD@{some index}${NC}"
    echo -e "      or : ${CB}git -C ${dir_dst}/${root}/ checkout . && git -C ${dir_dst}/${root}/ clean -fd${NC}"
    FAILED=true
  else
    echo -e "patchable : ${CG}${dir_dst}/${root}/  ${patch}${NC}"
  fi
done < ${FILE_CACHE}


if [ "${FAILED}" == "true" ]; then exit 1; fi

echo -e "\n${CB}all patch files can be applied, apply...${NC}"
while read -r dir_src dir_dst root patch; do
  bs_wrapper git -C ${dir_dst}/${root} apply -v ${dir_src}/${root}/${patch}
  #bs_wrapper git -C ${dir_dst}/${root} am ${dir_src}/${root}/${patch}
done < ${FILE_CACHE}

