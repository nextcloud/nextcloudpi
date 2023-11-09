#!/usr/bin/env bash

#min=$((101-${1:-50}))
all=({100..1})
cohortes=()
for i in "${all[@]:0:${1?}}"
do
  cohorte_id=$((RANDOM % i))
  while [[ " ${cohortes[*]} " =~ .*" ${cohorte_id} ".* ]]
  do
    cohorte_id=$((cohorte_id+1))
  done
  cohortes+=($cohorte_id)
done

echo "${cohortes[*]}" | tr ' ' $'\n'
