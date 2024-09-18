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

# source ${MAIN_dir}/${MODULES_D}/key_value_funcs.sh

function gen_mkfile_from_toml () {

   # Expectation is to pass the toml associative array
   #  we access it here as in https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
   #~ local -n tomlAA=${1}

   # Updated to avoid compatibility issues

   # Technique proposed by Florian Feldhaus
   # from https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
   eval "declare -A tomlAA="${1#*=}

   # display_associative_array "$(declare -p tomlAA)"

   # Checking that I have what I need:

   local lang_mkef=${tomlAA["build.lang"]//\"}
   local loct_srcs=${tomlAA["build.location"]//\"}
   local reqs_deps=${tomlAA["dependencies.pkgs"]//\"}
   local the_wname=${tomlAA["pkginfo.name"]//\"}

    case ${lang_mkef} in

      CC)
         die "Generation of Makefile for CC language not implemented yet"
         return $?
      ;;
      FF)
         vrb "Generating makefile for ${lang_mkef} lang."
         # For FF, I need makedepf90, check its existence in the appropriate location
         if [ ! -f ${LIPaS_BIN}/makedepf90 ]
         then
           die "makedepf90 does not seem to be installed in the standard location in LIPaS, correct and re-run"
         fi
      ;;
      *)
         die "Unhandled programming language"
      ;;
    esac

   declare -A PKGS_INCSLIBS=()
   declare -A PKGS_LIBSLIBS=()

   # We know the language, carry on
   if [ -z ${reqs_deps} ]
   then
      vrb "No package dependence"
   else
      oldIFS=${IFS}
      IFS=","
      for PKG_NAME in ${reqs_deps}
      do
        # I have a requested dependence, does it is reported as being there?
        if [ -f "${PKG_DATABASE}/${PKG_NAME}.ok" ]
        then # yes!
          vrb "Using installed ${PKG_NAME^^}"
          
   # LIBLINES already exist in the ${ENV_DIR}/${env_to_build[${CHOSEN_CONF}]}/gen.libs file
   # Just create an appropriate file content with the extracted lines
   #    ... to be used in the  ${LIPaS_EXT}/${the_wname}.libinc
   #
          olderIFS=${IFS}
          IFS="!"
	  
	  key_val="INC${PKG_NAME^^}"
	  PKGS_INCSLIBS+=("${key_val}") # Keeping the package uppercase since this is its profile for INC
	  libline_lok=$(grep "${key_val}" ${ENV_DIR}/${env_to_build[${CHOSEN_CONF}]}/gen.libs)
          PKGS_INCSLIBS["${key_val}"]="${libline_lok}"

	  key_val="LIB${PKG_NAME^^}"
	  PKGS_LIBSLIBS+=("${key_val}") # Keeping the package uppercase since this is its profile for LIB
	  libline_lok=$(grep "${key_val}" ${ENV_DIR}/${env_to_build[${CHOSEN_CONF}]}/gen.libs)
          PKGS_LIBSLIBS["${key_val}"]="${libline_lok}"
          IFS=${olderIFS}

        else # no!
          # Cannot satisfy dependence, die
          die "Requested ${PKG_NAME} dependence does not seem to be installed, rerun LIPaS with -p ${PKG_NAME}"
        fi
      done
      IFS=${oldIFS}
   fi

   # If I survived the previous, I have a list of upper case packages that can be used and two arrays with the necessary command INC/LIB lines
   #
   
   rm -f ${LIPaS_EXT}/${the_wname}.libinc

   for key_val in ${!PKGS_INCSLIBS[@]}
   do
       echo ${PKGS_INCSLIBS[${key_val}]} >> ${LIPaS_EXT}/${the_wname}.libinc
   done
   for key_val in ${!PKGS_LIBSLIBS[@]}
   do
       echo ${PKGS_LIBSLIBS[${key_val}]} >> ${LIPaS_EXT}/${the_wname}.libinc
   done

   hereiam=$(pwd)

   # Need to process the Makefile.LIPaS and the make.macros.LIPaS files accordingly
   # For now (2024-09-14), hardwired similarly as in build_pkg.sh
   # Should be moved to a generic handling routine that convert those keys @***@ in something useable
   

   # First parse the file(s) to check for the keys that need feeding
   declare -A keys_to_PROCESS

   for lipas_file in $(ls ${MAIN_dir}/${MAKEFILE_STD}/${lang_mkef}/*.LIPaS)
   do

      mkefile_lipas="${lipas_file}"
      mkefile_realp=$(realpath ${mkefile_lipas})
      mkefile_reald=$(dirname ${mkefile_realp})
      vrb "Scan variables in $(basename ${mkefile_lipas})"

      cd ${mkefile_reald}

      mkefile=$(basename ${mkefile_lipas})
      dctfile="${DICT_FOR_ENV}"

      readarray -t mkefile_array < <(cat ${mkefile} | grep -o \@.*\@)

      # display_associative_array "$(declare -p mkefile_array)"
      # display_associative_array "$(declare -p dctfile_array)"

      for (( j = 0 ; j < ${#mkefile_array[@]} ; j++ ))
      do
          # That line put the key to an empty value, if key did not exist, add it
          keys_to_PROCESS[${mkefile_array[$j]}]=""
      done

      cd ${hereiam}

   done # On list makefiles to process

   # From there, keys_to_PROCESS is a unique list of keys that need to be fed with content
   # display_associative_array "$(declare -p keys_to_PROCESS)"

   # Next I need to loop over those keys and find the corresponding content
   source ${MAIN_dir}/${MODULES_D}/get_env_value_for_key.sh
 
   for key_val in ${!keys_to_PROCESS[@]}
   do
	# Create a temporary work file
	randomfile_name="keyvalue-$(hexdump -n 8 -v -e '/1 "%02X"' /dev/urandom)"
	touch ${tempDIR}/${randomfile_name}
        # Call the hardwiring function that does it all
        get_env_value_for_key ${key_val} ${loct_srcs} "${INC_LINE:-None}" "${LIB_LINE:-None}"
   done

   unset tomlAA

   return $?








}

# The End of All Things (op. cit.)
