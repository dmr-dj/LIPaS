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

source key_value_funcs.sh

function list-make-targets (){
	
  # Need at least one parameter : the target searched
  # Optionally get the Makefile name
  
  if [ -z ${2+x} ] # no Makefile name provided ...
  then
    returnedword=$(make -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | sort -u | grep -w ${1})
  else
    returnedword=$(make --makefile=${2} -qp | awk -F':' '/^[a-zA-Z0-9][^$#\/\t=]*:([^=]|$)/ {split($1,A,/ /);for(i in A)print A[i]}' | sort -u | grep -w ${1})
  fi
  
  if [ "${returnedword}" = "${1}" ]
  then
    echo "OK"
  else
    echo "NOT"
  fi

}

function build_pkg_cc () {
	
  local method=${1//\"/}
    
  case ${method} in 
    autotools)
     vrb "Attmpt. ${method} on ${PKG_NAME}"
     # Go to package location
     hereiam=$(pwd)
     cd ${MAIN_dir}/${tempDIR}/${name_pkg}
     if [ -f Makefile ]
     then
       rm -f Makefile
     fi
     ./configure --prefix=${LIPaS_ROOT} 2>&1 > /dev/null
     make 2>&1 > /dev/null
     ./configure --prefix=${LIPaS_ROOT} 2>&1 > /dev/null
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
	
  # local -n tomlinput=${1}	# <- this method uses bash >= v5 method not really portable at this moment

  # Technique proposed by Florian Feldhaus 
  # from https://stackoverflow.com/questions/4069188/how-to-pass-an-associative-array-as-argument-to-a-function-in-bash
  eval "declare -A tomlinput="${1#*=}


  local method=${2//\"/}
    
   #~ # To check the hash table content
   #~ for i in "${!tomlinput[@]}"
   #~ do
     #~ echo "${i} ${tomlinput[$i]}"
   #~ done
    
    
  case ${method} in 
    make)
     vrb "Attmpt. ${method} on ${PKG_NAME}"
     
     place_pkg="${tempDIR}/${PKG_NAME}"
     place_to_be="${tempDIR}/${PKG_NAME}/${tomlAA["location"]//\"/}"
     hereiam=$(pwd)
     
     if [ -d ${place_to_be} ]
     then
        #~ cd ${place_to_be}
        
        sub_method=${tomlAA["mkfile"]//\"/}
        
        case ${sub_method} in
        ad-hoc)
          vrb "Going for ad-hoc mkfile"
          
	  if [[ ${tomlAA["modifier"]+_} ]]
          then
            sub_modifier=${tomlAA["modifier"]//\"/}
	  else
            sub_modifier=""
	  fi
                         
          case ${sub_modifier} in
          internal*)
            vrb "Internal switch"
            internal_file=$(echo "${sub_modifier}" | cut --delimiter=\| -f 2)
            if [ -f ${PKG_DATABASE}/${PKG_NAME}/${internal_file}.LIPaS ]
            then
              # Copy the internal specific file in the place_to_be
              cp -f ${PKG_DATABASE}/${PKG_NAME}/${internal_file}.LIPaS ${place_to_be}/.
              mkefile_lipas=$(find ${place_pkg}/. -name "${internal_file}.LIPaS")
              mkefile_realp=$(realpath ${mkefile_lipas})
              mkefile_reald=$(dirname ${mkefile_realp})              
            else
              die "make process failed no file ${my_file}.LIPaS"
            fi
          ;;
          *)
            mkefile_lipas=$(find ${place_pkg}/. -name "Makefile.LIPaS")
            mkefile_realp=$(realpath ${mkefile_lipas})
            mkefile_reald=$(dirname ${mkefile_realp})
          ;;
          esac
          
          # Here analyse the Makefile.LIPaS
          if [ -f "${mkefile_lipas}" ]
          then
            vrb "Scan variables in $(basename ${mkefile_lipas})"
          
            cd ${mkefile_reald}
            
            mkefile=$(basename ${mkefile_lipas})
            dctfile="${DICT_FOR_ENV}"
                        
            readarray -t mkefile_array < <(cat ${mkefile} | grep --null -n \@.*\@ | cut --delimiter=: -f2)  
            readarray -t dctfile_array < <(cat ${dctfile} | grep --null -n \@.*\@ | cut --delimiter=: -f2)
            
            mkefileinwork="Makefile.ins"
            
            cp -f ${mkefile} ${mkefileinwork}
            
            for (( j = 0 ; j < ${#mkefile_array[@]} ; j++ ))
            do
              key_mkefile=$( get_keyvalue "${mkefile_array[j]}" )   # List of keys that are in the Makefile
              value_mkefile=$( get_valuekey "${mkefile_array[j]}" ) # List of values that are in the Makefile
              
              #~ echo "key_mkefile = ${key_mkefile}"
              #~ echo "value_mkefile = ${value_mkefile}"
              
              found_valueMkefile=0
              # Lookup whether this value ( e.g. @FORTRAN_COMPILER_PATH@ )
              # ... is present in the dictionnary file of the compiler 
              
              for (( k = 0 ; k < ${#dctfile_array[@]} ; k++ ))
              do              
                key_dctfile=$( get_keyvalue "${dctfile_array[k]}" )
                
                if [ ${key_dctfile} == ${value_mkefile} ] # Found a match in the dictionnary file, get the dictionnary value
                then
                   value_dctfile=$( get_valuekey "${dctfile_array[k]}" )
                   
                   if [[ "${value_dctfile}" == "FROM_ENV" ]] # Specific case of an environnement variable hard wired
                   then
                      # Hardwired for now, could do much better
                      case ${key_dctfile//\@/} in
                       FORTRAN_COMPILER_PATH)
                        value_dctfile="${FC}"
                       ;;
                       INSTALL_PREFIX)
                        value_dctfile="${LIPaS_ROOT}"
                       ;;
                       C_COMPILER_PATH)
                        value_dctfile="${CC}"
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
                   found_valueMkefile=1     
                 fi
              done
              if [ "${found_valueMkefile}" -eq 0 ]
              then
                #~ echo "value_mkefile = ${value_mkefile//\@/}"
                #~ echo "Not found anywhere ..."
                
                printenv | grep "${value_mkefile//\@/}" 2>&1 > /dev/null
                
                if [ $? -eq "0" ]
                then
                  #~ echo "Found system variable matching:"
                  #~ echo ${value_mkefile}
                  #~ echo "$(eval echo \$${value_mkefile//\@/})"
                  sed -i "s+${value_mkefile}+$(eval echo \$${value_mkefile//\@/})+g" ${mkefileinwork}
                  
                fi
              fi
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
        declare -a mke_taargets_list=("clean" "${tomlAA["target"]//\"/}" "install")
        
        if [ -z ${internal_file+x} ] # no internal file, this is a Makefile STD
        then
        
          for mke_taarget in "${mke_taargets_list[@]}"
          do
            vrb "Making target ${mke_taarget}"
            found=$(list-make-targets "${mke_taarget}" "${mkefileinwork}")
            if [ "${found}" == "OK" ]
            then          
              make -s --makefile=${mkefileinwork} "${mke_taarget}" 2>&1 > /dev/null
            else
              vrb "Skipping target ${mke_taarget}"
            fi 
          done
                
        else # I was given an internal file that can be a Makefile or an include file
        
          if [[ "${internal_file}" == *"Makefile"* ]]
          then # it is indeed a Makefile, go usual way
            for mke_taarget in "${mke_taargets_list[@]}"
            do
              vrb "Making target ${mke_taarget}"
              found=$(list-make-targets "${mke_taarget}" "${mkefileinwork}")
              if [ "${found}" == "OK" ]
              then          
                make -s --makefile=${mkefileinwork} "${mke_taarget}" 2>&1 > /dev/null
              else
                vrb "Skipping target ${mke_taarget}"
              fi 
            done
          else # not a Makefile, probably an include, assuming a STD Makefile exists in the same place
            cp -f ${mkefileinwork} ${internal_file}
            vrb "Set ${internal_file}"
            for mke_taarget in "${mke_taargets_list[@]}"
            do
              vrb "Making target ${mke_taarget}"
              found=$(list-make-targets "${mke_taarget}")
              if [ "${found}" == "OK" ]
              then          
                make -s "${mke_taarget}" 2>&1 > /dev/null
              else
                vrb "Skipping target ${mke_taarget}"
              fi 
            done
          fi
        
        fi # on internal_file
        
        cd ${hereiam}
     else
       die "Missing location directory: ${place_to_be}"
     fi
          
     success_or_not=0
     return ${success_or_not}
    ;;
	*)
	die "Unknown build meth. ${method} for lang=FF"
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
        build_pkg_ff "$(declare -p tomlAA)" ${tomlAA["method"]}     
     ;;
     *)
     die "Unhandled programming language"
     ;;
   esac
   
   unset tomlAA
   
   return $?

}


# The End of All Things (op. cit.)
