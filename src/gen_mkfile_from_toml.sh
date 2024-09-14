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

source ${MAIN_dir}/${MODULES_D}/key_value_funcs.sh

function gen_mkfile_from_toml () {

   # Expectation is to pass the toml associative array
   #  we access it here as in https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
   #~ local -n tomlAA=${1}

   # Updated to avoid compatibility issues

   # Technique proposed by Florian Feldhaus
   # from https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
   eval "declare -A tomlAA="${1#*=}

   display_associative_array "$(declare -p tomlAA)"

   # Checking that I have what I need:

   local lang_mkef=${tomlAA["build.lang"]//\"}
   local loct_srcs=${tomlAA["build.location"]//\"}
   local reqs_deps=${tomlAA["dependencies.pkgs"]//\"}

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
          PKGS_INCSLIBS+=("${PKG_NAME^^}") # Keeping the package uppercase since this is its profile for INC and LIB
        else # no!
          # Cannot satisfy dependence, die
          die "Requested ${PKG_NAME} dependence does not seem to be installed, rerun LIPaS with -p ${PKG_NAME}"
        fi
      done
      IFS=${oldIFS}
   fi

   # If I survived the previous, I have a list of upper case packages that can be used

   # Need to process the Makefile.LIPaS and the make.macros.LIPaS files accordingly
   # For now (2024-09-14), hardwired similarly as in build_pkg.sh
   # Should be moved to a generic handling routine that convert those keys @***@ in something useable


   for lipas_file in $(ls ${MAIN_dir}/${MAKEFILE_STD}/${lang_mkef}/*.LIPaS)
   do
     echo "Processing ${lipas_file}"
   done


   unset tomlAA

   return $?








}

# The End of All Things (op. cit.)
