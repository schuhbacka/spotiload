#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

export LD_LIBRARY_PATH=${DIR}/../lib/

${DIR}/spotiload.bin $*
