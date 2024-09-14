#!/usr/bin/env bash

# Copyright [2024] [Didier M. Roche]
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m' GRAY='\033[38;5;8m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW='' GRAY=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

msn() {
  echo >&2 -e "${1-}"
}


vrb() {
  if [ ${verbose} -eq 1 ]
  then
     filler=$( seq -s ' ' 1 100 | tr -dc ' ' )
     string=" ${1}"
     msg_lok=$string${filler:${#string}}
     msg "${GRAY} + ${msg_lok:0:35} + ${NOFORMAT}"
  #~ else
     #pass
  fi
}

gui() {
   filler=$( seq -s ' ' 1 100 | tr -dc ' ' )
   string=" ${1}"
   msg_lok=$string${filler:${#string}}
   msg "${ORANGE} + ${msg_lok:0:35} + ${NOFORMAT}"
}

iui() {
   filler=$( seq -s ' ' 1 100 | tr -dc ' ' )
   string=" ${1}"
   msg_lok=$string${filler:${#string}}
   msn "${ORANGE} + ${msg_lok:0:35} + ${NOFORMAT}"
}

# The End of All Things (op. cit.)
