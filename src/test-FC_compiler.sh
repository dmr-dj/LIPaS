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

function test_FC_compiler(){

   msg " +  Testing   Fortran Compiler (FC)    +"
   # Here testing the fortran compiler(s) found with test data To Be Defined.
   cp ${SRC_TST_DIR}/*.f* ${tempDIR}/.
   
   cd ${tempDIR}
   
   vrb "Testing plain FORTRAN ..."   
   
   ${FC} -o  fpi_serial.x fpi_serial.f 2>&1 > /dev/null
   
   if [ -f fpi_serial.x ]
   then
     ./fpi_serial.x 2>&1 > /dev/null
   fi

   vrb "Testing mpi FORTRAN ..."   
 
   #~ To be Done correctly with MPI Fortran detection ...  
   #~ ${FC} -o  fpi_serial.x fpi_serial.f 2>&1 > /dev/null
   
   #~ if [ -f fpi_serial.x ]
   #~ then
     #~ ./fpi_serial.x
   #~ fi


   vrb "Testing omp FORTRAN ..."   
 
   ${FC} -o  test_omp.x test_omp.f90 -fopenmp 2>&1 > /dev/null
   
   if [ -f test_omp.x ]
   then
     ./test_omp.x 2>&1 > /dev/null
   fi	
} # end test_FC_compiler
# The End of All Things (op. cit.)
