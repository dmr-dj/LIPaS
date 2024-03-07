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

function build_pkg_cc () {
	
  local method=${1//\"}
  
  case ${method} in 
    autotools)
     vrb "Attmpt. ${method} on ${PKG_NAME}"
     # Go to package location
     hereiam=$(pwd)
     cd ${MAIN_dir}/${tempDIR}/${name_pkg}
     ./configure --prefix=${LIPaS_ROOT} 2>&1 > /dev/null
     make 2>&1 > /dev/null
     make install 2>&1 > /dev/null
     success_or_not=$?
     cd ${hereiam}
     return ${success_or_not}
    ;;
	*)
	die "Unknown build meth. ${method} for lang=CC"
	;;
  esac
}

function build_pkg_ff () {
	
	die "Building with language FF is not implemented yet"

}


function build_pkg () {
	
   # Expectation is to pass the toml associative array
   #  we access it here as in https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
   local -n tomlAA=${1}
   local name_pkg=${2}

   case ${tomlAA["lang"]} in
     
     \"CC\")
        build_pkg_cc ${tomlAA["method"]}
        return $?
     ;;
     \"FF\")
        build_pkg_ff ${tomlAA["method"]}     
     ;;
     *)
     die "Unhandled programming language"
     ;;
   esac
   echo ${!tomlAA[@]}

}
