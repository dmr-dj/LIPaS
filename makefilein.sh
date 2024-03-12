#!/bin/bash

function trim () {
  echo ${1} | awk '{$1=$1;print}'
}

function get_valuekey () {
  # Send back the value from a key/value set
  local my_value

  if [[ ${1} =~ (.*)=(.*) ]]
  then 
    my_value=$( trim ${BASH_REMATCH[2]} )
    echo ${my_value}
    return 0
  else 
    return 1
  fi
}

function get_keyvalue () {
  # Send back the key from a key/value set
  local my_value

  if [[ ${1} =~ (.*)=(.*) ]]
  then 
    my_value=$( trim ${BASH_REMATCH[1]} )
    echo ${my_value}
    return 0
  else 
    return 1
  fi
}


file=" ../dinsol-v1/source/Makefile.LIPaS"
readarray -d '#' -t vars_to_replace < <(cat ${file} | grep --null -n \@.*\@ | cut --delimiter=: -f2 | tr '\n' '#')  
value_to_replace="${HOSTNAME}/.lipas/bin"
for (( j = 0 ; j < ${#vars_to_replace[@]} ; j++ ))
do
  #~ if [[ ${vars_to_replace[j]} =~ (.*)=(.*) ]]
  #~ then 
    #~ name_m=$( trim ${BASH_REMATCH[1]} )
    #~ value_m=$( trim ${BASH_REMATCH[2]} )
    #~ var_out="${name_m} = ${value_to_replace}"
    #~ echo ${var_out}
  #~ fi
  #~ echo ${vars_to_replace[j]}
  value_m=$( get_keyvalue "${vars_to_replace[j]}" )
  var_out="${value_m} = ${value_to_replace}"
  echo ${var_out}
done
# The End of All Things (op. cit)
