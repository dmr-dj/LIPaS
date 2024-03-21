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



# This script uses Associative Arrays introduced in bash v4
# [TODO] check that indeed we are running with bash >= 4


function build_pkg_cc () {
	
  local method=${1//\"/}
    
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
	
  local -n tomlinput=${1}	# <- this method uses bash >= v5 method not really portable at this moment

  local method=${2//\"/}
    
   #~ # To check the hash table content
   #~ for i in "${!tomlinput[@]}"
   #~ do
     #~ echo "${i} ${tomlinput[$i]}"
   #~ done
    
    
  case ${method} in 
    make)
     vrb "Attmpt. ${method} on ${PKG_NAME}"
     
     place_to_be="${tempDIR}/${PKG_NAME}/${tomlAA["location"]//\"/}"
     hereiam=$(pwd)
     
     if [ -d ${place_to_be} ]
     then
        cd ${place_to_be}
        
        sub_method=${tomlAA["mkfile"]//\"/}
        case ${sub_method} in
        ad-hoc)
          vrb "Going for ad-hoc mkfile"
          # Here analyse the Makefile.LIPaS
          if [ -f Makefile.LIPaS ]
          then
            vrb "Scan variables in Makefile.LIPaS"
            
            mkefile="Makefile.LIPaS"
            dctfile="${DICT_FOR_ENV}"
                        
            readarray -t mkefile_array < <(cat ${mkefile} | grep --null -n \@.*\@ | cut --delimiter=: -f2)  
            readarray -t dctfile_array < <(cat ${dctfile} | grep --null -n \@.*\@ | cut --delimiter=: -f2)
            
            mkefileinwork="Makefile.ins"
            
            cp -f ${mkefile} ${mkefileinwork}
            
            for (( j = 0 ; j < ${#mkefile_array[@]} ; j++ ))
            do
              key_mkefile=$( get_keyvalue "${mkefile_array[j]}" )
              value_mkefile=$( get_valuekey "${mkefile_array[j]}" )
              
              for (( k = 0 ; k < ${#dctfile_array[@]} ; k++ ))
              do              
                key_dctfile=$( get_keyvalue "${dctfile_array[k]}" )

                if [ ${key_dctfile} == ${value_mkefile} ]
                then
                   value_dctfile=$( get_valuekey "${dctfile_array[k]}" )
                   
                   if [[ "${value_dctfile}" == "FROM_ENV" ]]
                   then
                      # Hardwired for now, could do much better
                      case ${key_dctfile//\@/} in
                       FORTRAN_COMPILER_PATH)
                        value_dctfile="${FC}"
                       ;;
                       INSTALL_PREFIX)
                        value_dctfile="${LIPaS_ROOT}"
                       ;;
                       *)
                        die "Unkown key from env ${key_dctfile}"
                       ;;
                      esac 
                   fi
                 #~ else
                   #~ vrb "${key_dctfile} and ${value_mkefile} not comparable"
                   
                   # Replace values found in the temporary makefile
                   sed -i "s+${key_dctfile}+${value_dctfile}+g" ${mkefileinwork}
                 fi
              done
            done

          else
            die "Could not find the Makefile.LIPaS file, update toml file"
          fi 
        ;;
        *)
          die "Unknown makefile methodologies"
        ;;
        esac
        
        vrb "Building ${PKG_NAME}"
                
        make -s --makefile=${mkefileinwork} clean 2>&1 > /dev/null
        make -s --makefile=${mkefileinwork} ${tomlAA["target"]//\"/} 2>&1 > /dev/null
        make -s --makefile=${mkefileinwork} install 2>&1 > /dev/null
        
        cd ${hereiam}
     else
       die "Missing location directory: ${place_to_be}"
     fi
          
     success_or_not=0
     return ${success_or_not}
    ;;
	*)
	die "Unknown build meth. ${method} for lang=CC"
	;;
  esac

}


function build_pkg () { # (TOML_AA_array, PKG_NAME)
	
   # Expectation is to pass the toml associative array
   #  we access it here as in https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
   #~ local -n tomlAA=${1}

   # Updated to avoid compatibility issues
   
   	# Technique proposed by Florian Feldhaus 
	# from https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
    eval "declare -A tomlAA="${1#*=}

    # declare -p tomlAA

   local name_pkg=${2}

   case ${tomlAA["lang"]//\"} in
     
     CC)
        build_pkg_cc ${tomlAA["method"]}
        return $?
     ;;
     FF)
        build_pkg_ff tomlAA ${tomlAA["method"]}     
     ;;
     *)
     die "Unhandled programming language"
     ;;
   esac
   
   unset tomlAA
   
   return $?

}


# The End of All Things (op. cit.)
