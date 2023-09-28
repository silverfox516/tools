#!/bin/bash

BS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ $(declare -p BS_PRJ 2>&1) != *"not found"* ]]; then
    echo "BS_PRJ=${BS_PRJ}, run in a new shell"
    return
fi

export BS_PRJ=test
BS_DIR_TARGETS=${BS_DIR}/targets
BS_DIR_MODELS=${BS_DIR}/models

source ${BS_DIR}/scripts/setup.sh
