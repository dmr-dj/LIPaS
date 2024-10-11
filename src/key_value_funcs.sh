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

function get_valuekey () {
  # Send back the value from a key/value set
  local my_value

  if [[ ${1} =~ (.*)=(.*) ]]
  then
    my_value=$( trim "${BASH_REMATCH[2]}" )
    echo ${my_value}
    return 0
  else
    return 1
  fi
}

function get_keyvalue () {
  # Send back the key from a key/value set
  local my_value

  if [[ ${1} =~ (.*)=(.*) ]]
  then
    my_value=$( trim "${BASH_REMATCH[1]}" )
    echo ${my_value}
    return 0
  else
    return 1
  fi
}

function display_associative_array (){

    # Technique proposed by Florian Feldhaus
    # from https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
    eval "declare -A tomlinput="${1#*=}

    # To check the hash table content
    for i in "${!tomlinput[@]}"
    do
      echo "${i} ${tomlinput[$i]}"
    done
}


# The End of All Things (op. cit.)
