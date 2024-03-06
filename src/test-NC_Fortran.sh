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


function test-NC_Fortran() {

   msg " +  Test  NC w/Fortran Compiler (FC)   +"
   
   NC_fortran_filelist=($(ls ../${SRC_TST_DIR}/netCDF-F/*_wr.f*))   

   for fortran_F in "${NC_fortran_filelist[@]}"
   do
     cp ${fortran_F} .     
     basename_F=$(basename ${fortran_F} .f90)
     ${FC} -o ${basename_F}.x ${INCNETCDF} ${fortran_F} ${LIBNETCDF} 2>&1 > /dev/null
   
     if [ -f ${basename_F}.x ]
     then
        ./${basename_F}.x 2>&1 > /dev/null
         vrb "Success for ${basename_F}"
     fi
     
   done

   NC_fortran_filelist=($(ls ../${SRC_TST_DIR}/netCDF-F/*_rd.f*))   

   for fortran_F in "${NC_fortran_filelist[@]}"
   do
     cp ${fortran_F} .     
     basename_F=$(basename ${fortran_F} .f90)
     ${FC} -o ${basename_F}.x ${INCNETCDF} ${fortran_F} ${LIBNETCDF} 2>&1 > /dev/null
   
     if [ -f ${basename_F}.x ]
     then
        ./${basename_F}.x 2>&1 > /dev/null
         vrb "Success for ${basename_F}"
     fi
     
   done
} # end test-NC_Fortran
