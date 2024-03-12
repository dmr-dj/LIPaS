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

function get_tomlTableNms () {
   local tomlFile=${1}

   vrb "Table reading"   
   readarray -d ' ' -t tomlTableNames < <(grep '\[*\]' ${tomlFile} | tr '\n' ' ' )
   readarray -d ' ' -t tomlTableIndex < <(grep -n '\[*\]' ${tomlFile} | cut --delimiter=: -f 1 | tr '\n' ' ' )	
   # [ToDo] Need to do a sanity check here, size of the two arrays should be identical, could be stored in a associative array
   
}


function get_tomlVarsInTables () {

   local tomlFile=${1}
   
   local sizeTable
   declare -i sizeTable=${#tomlTableIndex[@]}

   local varsRead
   declare -a varsRead

   vrb "Vars in Table reading"  

   local key
   local value

   # tomlTableNames tomlTableIndex
   for (( i = 1 ; i < ${sizeTable}+1 ; i++ ))
   do
      START=${tomlTableIndex[i-1]}
      if [ "${i}" -lt ${sizeTable} ]
      then      
        END=${tomlTableIndex[i]}
      else
        END=$(wc -l ${tomlFile}| cut --delimiter=" " -f 1)
      fi
      # Extract the lines using the head and tail commands
      
      readarray -d '@' -t varsRead < <( head -n $(( ${END}-1 )) "${tomlFile}" | tail -n $(( ${END} - ${START} )) | grep "=" | tr '\n' '@' )

      #~ vrb "Table: ${tomlTableNames[i-1]}  ${#varsRead[@]}"  
      for (( j = 0 ; j < ${#varsRead[@]} ; j++ ))
      do
         key=$(echo ${varsRead[j]} | cut --delimiter== -f1)
         value=$(echo ${varsRead[j]} | cut --delimiter== -f2)
         
         tomlVarsInTable["${tomlTableNames[i-1]}.${key}"]="${value}"
      done
   done
	
}

function read-toml () {
   # Provided with a toml file name, read and feedback the necessary components
   
   local tomlFile=${1}
   local tomlFilebase=$(basename ${tomlFile})
   
   vrb "Reading file ${tomlFilebase}"
   
   declare -a tomlTableNames
   declare -a tomlTableIndex   
   get_tomlTableNms ${tomlFile}
   
   
   declare -A tomlVarsInTable
   get_tomlVarsInTables ${tomlFile}

# Copy back the result to the main global variable
   for k in "${!tomlVarsInTable[@]}"; do tomlFileContent[$k]=${tomlVarsInTable[$k]}; done   

   unset tomlTableNames
   unset tomlTableIndex
   unset tomlVarsInTable 		
}
# reworked from https://stackoverflow.com/questions/13219634/easiest-way-to-check-for-an-index-or-a-key-in-an-array
# with partial match as well and return the values of the associated table
function Texists () {
	# Expects 1 : a key 2 : "in" and 3 an Associative Array
	local lookupKey
	lookupKey=${1}
	
	local -n aArray=${3}
	
	for key in "${!aArray[@]}"
	do
	    if [[ "${key}" =~ .*"${lookupKey}"*. ]]
	    then
	      #~ echo "${lookupKey} exists in Table"
	      toStrip="[${lookupKey}]."
	      stripedKey=${key##"${toStrip}"}

	      tableContent[${stripedKey}]=${aArray[${key}]}
	    fi
	done
	if [ ${#tableContent[@]} -gt 0 ]
	then
	   return 0
	else
	   return 1
	fi
}
# The End of All Things (op. cit.)
