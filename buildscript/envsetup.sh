#!/bin/bash

BS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

BS_PRJ=test
BS_DIR_TARGETS=${BS_DIR}/targets
BS_DIR_MODELS=${BS_DIR}/models

source ${BS_DIR}/scripts/setup.sh
