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


function installtst_pkg () {
	
   # Expectation is to pass the toml associative array
   #  we access it here as in https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
   local -n tomlAA=${1}
   local name_pkg=${2}
    
   for key in ${!tomlAA[@]}
   do
     if [ ${key//\"} == "exec" ]
     then # this should have installed a binary
        if [ -f ${LIPaS_BIN}/${tomlAA[${key}]//\"} ]
        then
           #~ vrb "bin of ${name_pkg//\"} exists"
           return 0
        fi
     fi
     return 1
   done
   
}

# The End of All Things (op. cit.)
