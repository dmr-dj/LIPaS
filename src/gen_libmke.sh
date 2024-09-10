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


function gen_liblines () {

   local namelok_pkg=${1}
   local lib_pkgname_path="${2}"
   local actual_lib_name=${3} # libname and package name could be different potentially ...
   local file_name_append=${4} 
   
   # we get something where
   # ${lib_pkgname_path} gives the lib is (alrady verified existence)
   # ${namelok_pkg} gives the common name of the package
     
   # actual_lib_name can have severall items
   libline=""
   for elemnt in ${actual_lib_name}
   do
     libline="${libline} -Wl,-rpath=${lib_pkgname_path} -L${lib_pkgname_path} -l${elemnt:3}"
   done 
   # Construct the lines in the form:
      
   echo "LIB${namelok_pkg^^} = ${libline}" >> ${file_name_append}
   echo "INC${namelok_pkg^^} = -I${LIPaS_INC}" >> ${file_name_append}
    
   status_return=0    
}

# The End of All Things (op. cit.)
