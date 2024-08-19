#!/usr/bin/env bash
#min=$((101-${1:-50}))
total_count="${1?}"
target_file="${2?}"
all=({100..1})
cohortes=()

while IFS="" read -r line || [ -n "$line" ]
do
  [[ -n "$line" ]] || continue
  cohortes+=("$line")
done < "${target_file}"

cohortes_count=${#cohortes[@]}
count=$(( total_count - cohortes_count ))

for i in "${all[@]:0:${count}}"
do
  cohorte_id=$((RANDOM % i))
  while [[ " ${cohortes[*]} " =~ .*" ${cohorte_id} ".* ]]
  do
    cohorte_id=$((cohorte_id+1))
    if [[ $cohorte_id -eq 101 ]]
    then
      cohorte_id=1
    fi
  done
  cohortes+=($cohorte_id)
done

(IFS=$'\n'; echo -n "${cohortes[*]}" | sort -h | head -c -1 >| "$target_file")
