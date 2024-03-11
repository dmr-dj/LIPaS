#!/bin/bash
file=" ../dinsol-v1/source/Makefile.LIPaS"
readarray -d '#' -t vars_to_replace < <(cat ${file} | grep --null -n \@.*\@ | cut --delimiter=: -f2 | tr '\n' '#')  
value_to_replace="${HOSTNAME}/.lipas/bin"
for (( j = 0 ; j < ${#vars_to_replace[@]} ; j++ ))
do
  if [[ ${vars_to_replace[j]} =~ (.*)=(.*) ]]
  then 
    name_m=$( echo ${BASH_REMATCH[1]} | awk '{$1=$1;print}' )
    value_m=$( echo ${BASH_REMATCH[2]} | awk '{$1=$1;print}' )
    var_out="${name_m} = ${value_to_replace}"
    echo ${var_out}
  fi
done
# The End of All Things (op. cit)
