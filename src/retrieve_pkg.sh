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


function retrieve_pkg () {
   
   # Expectation is to pass the toml associative array
   #  we access it here as in https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
   #~ local -n tomlAA=${1}

   # Updated to avoid compatibility issues
   
   	# Technique proposed by Florian Feldhaus 
	# from https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
    eval "declare -A tomlAA="${1#*=}

   #~ declare -p tomlAA
   
   local name_pkg=${2}
               
   # Known retrieval methodologies!
   #
   # git / needs a gitpath for git clone to be successful
   # svn / needs a svn checkout path
   # 
  
  
   #~ # To check the hash table content
   #~ for i in "${!tomlAA[@]}"
   #~ do
     #~ echo "${i} ${tomlAA[$i]}"
   #~ done
   
   case ${tomlAA["method"]} in
     \"git\")
        vrb "Attempting git retrieve"
        git clone ${tomlAA["path"]//\"} ${MAIN_dir}/${tempDIR}/${name_pkg} --quiet 2>&1 > /dev/null
      ;;
      *)
        die "${tomlAA["method"]} retrieve not implemented yet"
      ;;
   esac
  
   unset tomlAA
} 






# The End of All Things (op. cit.)
