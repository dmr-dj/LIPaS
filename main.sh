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

set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

prog_name="LIPaS"
script_version="0.1.1"

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

verbose=0

usage() {
  cat <<EOF
Usage: $(basename "${BASH_SOURCE[0]}") [-h] [-v] [-f] -p param_value arg1 [arg2...]

Script description here.

Available options:

-h, --help      Print this help and exit
-v, --verbose   Print script debug info
EOF
  exit
}

cleanup() {
  trap - SIGINT SIGTERM ERR EXIT
  # script cleanup here
  #~ msg "Died through cleanup ..."
}

setup_colors() {
  if [[ -t 2 ]] && [[ -z "${NO_COLOR-}" ]] && [[ "${TERM-}" != "dumb" ]]; then
    NOFORMAT='\033[0m' RED='\033[0;31m' GREEN='\033[0;32m' ORANGE='\033[0;33m' BLUE='\033[0;34m' PURPLE='\033[0;35m' CYAN='\033[0;36m' YELLOW='\033[1;33m' GRAY='\033[38;5;8m'
  else
    NOFORMAT='' RED='' GREEN='' ORANGE='' BLUE='' PURPLE='' CYAN='' YELLOW='' GRAY=''
  fi
}

msg() {
  echo >&2 -e "${1-}"
}

vrb() {
  if [ ${verbose} -eq 1 ] 
  then 
     filler=$( seq -s ' ' 1 100 | tr -dc ' ' )
     string=" ${1}"
     msg_lok=$string${filler:${#string}}
     msg "${GRAY} + ${msg_lok:0:35} + ${NOFORMAT}"
  #~ else
     #pass
  fi	
}

die() {
  local msg=$1
  local code=${2-1} # default exit status 1
  msg "${RED} $msg ${NOFORMAT}"
  exit "$code"
}

display_version() {

  msg "${prog_name} version ${script_version}"
  exit
  
}

parse_params() {
	
  args=("$@")
  
  #~ [[ ${#args[@]} -lt 2 ]] && die "Missing script arguments: at the minimum I need one input and one output directory"

  while :; do
    case "${1-}" in
    -h | --help) usage ;;
    -v | --verbose) verbose=1 ;;
    --no-color) NO_COLOR=1 ;;
    --version) display_version ;;
    -?*) die "Unknown option: $1" ;;
    *) break ;;
    esac
    shift
  done

  return 0
}

function split_string_to_array () {

   arrayid=(`echo "$1" | tr "$2" " "`)
   
		
} # end function

# from: https://www.baeldung.com/linux/command-line-progress-bar
bar_size=40
bar_char_done="#"
bar_char_todo="-"
bar_percentage_scale=2

function show_progress {
    current="$1"
    total="$2"

    # calculate the progress in percentage 
    percent=$(bc <<< "scale=$bar_percentage_scale; 100 * $current / $total" )
    # The number of done and todo characters
    done=$(bc <<< "scale=0; $bar_size * $percent / 100" )
    todo=$(bc <<< "scale=0; $bar_size - $done" )

    # build the done and todo sub-bars
    done_sub_bar=$(printf "%${done}s" | tr " " "${bar_char_done}")
    todo_sub_bar=$(printf "%${todo}s" | tr " " "${bar_char_todo}")

    # output the bar
    echo -ne "\rProgress : [${done_sub_bar}${todo_sub_bar}] ${percent}%"

    if [ $total -eq $current ]; then
        echo -e "\nDONE"
    fi
}

setup_colors
parse_params "$@"

configsDIR="configs"


msg "  ===================================== "
msg " +                                     +"
msg " +              LIPaS                  +"
msg " +            version ${script_version}            +"
msg " +                                     +"
msg "  ===================================== "

msg ""

ComputerName=${HOSTNAME}
confFile="conf."
confNbLinesFile="6"

vrb "=======   LOCATING CONFIGS   ======="

if [ -d ${script_dir}/${configsDIR}/${ComputerName} ]
then

    vrb "Detected a configuration DIR"

    CONF_DIR="${script_dir}/${configsDIR}/${ComputerName}"
    LIST_CONF_FILES=()
    for fich in $(ls ${CONF_DIR}/${confFile}*)
    do
       nb_lines_conf=$(wc -l ${fich} | cut --delimiter=" " -f1)
       if [ "${nb_lines_conf}" -ge "${confNbLinesFile}" ]
       then
          LIST_CONF_FILES+=("${fich}")
       fi    
    done
    
    nb_valid_conf=${#LIST_CONF_FILES[@]}
    vrb "Found ${nb_valid_conf} valid file(s) in conf DIR"

else

    vrb "Configuration DIR not detected"
    vrb "No possibility to go further"
    vrb "  in current version of ${prog_name}" 

    die "  Execution of ${prog_name} failed   "
    #~ for fich in `ls ${nom_fich_config}*`
    #~ do
	#~ nom_gen=${fich##${nom_fich_config}}
	#~ nom_gen_mach=`echo ${nommachine} | sed "s%[0-9]*%%g"`
	#~ resul_enlev=${nom_gen##${nom_gen_mach}}
	#~ otreoption=`echo ${nommachine} | sed "s%[0-9]*%%g" | sed "s%${nom_gen}%TOTO%g" | grep TOTO`
	#~ if [ "${nom_gen##${nom_gen_mach}}" = "" ]
	#~ then
	    #~ echo "Retreiving  environement variables for ${nom_gen} "
	    #~ fichconfig="${fich}"
	#~ elif [ ! "${otreoption}" = "" ]
	#~ then
	    #~ echo "Retreiving  environement variables for ${nom_gen} "
	    #~ fichconfig="${fich}"
        #~ elif [ ! "${nommachine##${nom_gen}}" = ${nommachine} ]
        #~ then
	    #~ echo "Retreiving  environement variables for ${nom_gen} "
	    #~ fichconfig="${fich}"
        #~ fi
    #~ done

fi

vrb "=======  DEFINING COMPILERS  ======="


env_to_build=()
conf_to_build=()

for file in "${LIST_CONF_FILES[@]}"
do
   env_type=$(basename ${file} | cut -d. -f 2) # second file of config file is type of env, e.g. conf.gnu
   
   if [[ ${env_to_build[@]} =~ ${env_type} ]]
   then
      vrb "Env. ${env_type} has a double conf file"
      vrb "   ... using first one found ..."
   else
      vrb "Conf file for env. ${env_type} found"
      env_to_build+=("${env_type}")
      conf_to_build+=("${file}")
   fi
done

# Retreive the compiler /version ...

msg "  ===  Analysing Environnements  ====== "

tempDIR="tmp-$(hexdump -n 8 -v -e '/1 "%02X"' /dev/urandom)"
mkdir ${tempDIR}

env_DIR="envs"
mkdir -p ${env_DIR}

for (( indx_conf=0; indx_conf<=${#conf_to_build[@]}-1; indx_conf++ ))
do
   conf=${conf_to_build[${indx_conf}]}
      
   FC_line=$(grep "FC" ${conf})
   declare -x ${FC_line}
   
   FC_version=$(${FC} --version | grep -i ${env_to_build[${indx_conf}]} | grep -o "[0-9]*\.[0-9]\.[0-9]" | tail -1)
   
   vrb "${env_to_build[${indx_conf}]} env FC = ${FC_version}"
      
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
     die "Incorrect netCDF Fortran env. (include)"
   fi

   NC_CLIB_line=$(grep "NC_C_LIB" ${conf})
   declare -x ${NC_CLIB_line}
   
   if [ -f ${NC_C_LIB}/libnetcdf.so ]
   then
     vrb "library netCDF C found"
   else
     die "Incorrect netCDF Fortran env. (library)"
   fi

   LIBNETCDFF="-Wl,-rpath=${NC_F_LIB} -L${NC_F_LIB} -lnetcdff"
   INCNETCDFF="-I${NC_F_INC}"
   LIBNETCDFC="-Wl,-rpath=${NC_C_LIB} -L${NC_C_LIB} -lnetcdf"
   INCNETCDFC="-I${NC_C_INC}"
   
   LIBNETCDF="${LIBNETCDFC} ${LIBNETCDFF}"
   INCNETCDF="${INCNETCDFC} ${INCNETCDFF}"
   
   msg " +  Testing   Fortran Compiler (FC)    +"
   # Here testing the fortran compiler(s) found with test data To Be Defined.
   cp src-tst/*.f* ${tempDIR}/.
   
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
   
   msg " +  Test  NC w/Fortran Compiler (FC)   +"
   # Here testing the netCDF libraries found with test data To Be Defined.
   
   NC_fortran_filelist=($(ls ../src-tst/netCDF-F/*_wr.f*))   

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

   NC_fortran_filelist=($(ls ../src-tst/netCDF-F/*_rd.f*))   

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
   
   cd ${script_dir}
   
   if [ -d ${env_DIR}/${env_type} ]
   then
     # Delete, we are renewing the configuration
     rm -fR ${env_DIR}/${env_type}
   fi
  
   mkdir -p ${env_DIR}/${env_type}
      
   cd ${env_DIR}/${env_type}
    
   vrb "Generating .pkg" 
   echo "FC = ${FC}" >> gen.pkg
   vrb "Generating .libs"
   echo "INCNETCDF = ${INCNETCDF}" >> gen.libs
   echo "LIBNETCDF = ${LIBNETCDF}" >> gen.libs
            
   msg " +  Generating ${env_type} environnement ...   + ${GREEN} [Done] ${NOFORMAT}" 
done

cd ${script_dir}
rm -fR ${tempDIR}


# The End of All Things (op. cit.)
