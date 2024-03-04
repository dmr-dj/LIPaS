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

function check_NC-env(){
	
   NC_FINC_line=$(grep "NC_F_INC" ${conf})
   declare -x ${NC_FINC_line}
   
   if [ -f ${NC_F_INC}/netcdf.mod ]
   then
     vrb "include netCDF F found"
   else
     die "Incorrect netCDF Fortran env. (include)"
   fi

   NC_FLIB_line=$(grep "NC_F_LIB" ${conf})
   declare -x ${NC_FLIB_line}
   
   if [ -f ${NC_F_LIB}/libnetcdff.a ]
   then
     vrb "library netCDF F found"
   else
     die "Incorrect netCDF Fortran env. (library)"
   fi

   NC_CINC_line=$(grep "NC_C_INC" ${conf})
   declare -x ${NC_CINC_line}
   
   if [ -f ${NC_C_INC}/netcdf.h ]
   then
     vrb "include netCDF C found"
   else
     die "Incorrect netCDF C env. (include)"
   fi

   NC_CLIB_line=$(grep "NC_C_LIB" ${conf})
   declare -x ${NC_CLIB_line}
   
   if [ -f ${NC_C_LIB}/libnetcdf.so ]
   then
     vrb "library netCDF C found"
   else
     die "Incorrect netCDF C env. (library)"
   fi

   LIBNETCDFF="-Wl,-rpath=${NC_F_LIB} -L${NC_F_LIB} -lnetcdff"
   INCNETCDFF="-I${NC_F_INC}"
   LIBNETCDFC="-Wl,-rpath=${NC_C_LIB} -L${NC_C_LIB} -lnetcdf"
   INCNETCDFC="-I${NC_C_INC}"
   
   LIBNETCDF="${LIBNETCDFC} ${LIBNETCDFF}"
   INCNETCDF="${INCNETCDFC} ${INCNETCDFF}"
} # check_NC-env
