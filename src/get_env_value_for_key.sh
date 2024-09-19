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


function get_env_value_for_key () {
  local keysearch=${1}
  local targtsrcs=${2}
  local inclibdep=${3}
  local liblibdep=${4}
  local SOFT_NAME=${5}
  local tem_file_name=${6}
  
  local doneIt=0
  
  vrb "Processing key ${keysearch}"
  
  # Hardwired for now, could do much better
  case ${keysearch//\@/} in
       FORTRAN_COMPILER_PATH)
         value_dctfile="${FC}"
       ;;
       INSTALL_PREFIX)
         value_dctfile="${LIPaS_ROOT}"
       ;;
       C_COMPILER_PATH)
         value_dctfile="${CC}"
       ;;
       SPECIFIC_GEN_LIB)
         # This is the file that we are generating, so make that name
	 vrb "Output gen_lib is: "
	 value_dctfile="${LIPaS_EXT}/${SOFT_NAME}.libinc"
       ;;
       LIST_OF_LIBLIBS)
         # Creating the compile LIB chain
	 vrb "Creating LIB chain"
	 value_dctfile="${liblibdep}"
       ;;
       LIST_OF_INCLIBS)
         # Creating the compile INC chain
	 vrb "Creating INC chain"
	 value_dctfile="${inclibdep}"
       ;;
       MAKEDEPF90_PATH)
         # Setting the default Makedepf90 path for all FORTRAN
	 vrb "Default path for makedepf90: "
	 value_dctfile="${LIPaS_BIN}/makedepf90"
       ;;
       PKG_NAME)
         # The One and Only package name
	 vrb "PKG_NAME == ${SOFT_NAME^^}"
	 value_dctfile="${SOFT_NAME}"
       ;;
       SOURCE_DIR_PATH)
         # Path to the sources that will be compiled, relative to Makefile
	 vrb "Sources are in: ${targtsrcs}"
	 value_dctfile="${targtsrcs}"
       ;;
       *)
         die "Unkown key from env ${keysearch}"
       ;;
  esac

  echo "${value_dctfile}" > ${tem_file_name}
  return
}

# The End of All Things (op. cit.)
