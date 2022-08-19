function is_port_open()
{
  local port port_url ip_url tmp_file token token_args grep_token grep_portcheck \
  publicIPv4 publicIPv4_exist ipv4_port_access ipv4_args ipv4_portcheck_args \
  publicIPv6 publicIPv6_exist ipv6_port_access ipv6_args ipv6_portcheck_args
  tmp_file=$(mktemp)
  trap "rm -rf ${tmp_file}; exit $?" EXIT ERR SIGINT SIGQUIT SIGABRT SIGTERM SIGHUP
  
    port="$1"
    publicIPv4_exist=True
    publicIPv6_exist=True
    readonly port_url="https://portchecker.co"
    readonly ip_url="https://icanhazip.com"
    readonly token_args=(-T2 -t1 -qO- --keep-session-cookies --save-cookies "${tmp_file}" "${port_url}")
    readonly grep_token_args=(-oP "_csrf\" value=\"\K.*\"")
    readonly grep_portcheck_args=(-q '<span class="green">open</span>')
    readonly ipv4_args=(-s -m4 -4 "${ip_url}")
    readonly ipv6_args=(-s -m4 -6 "${ip_url}")
  
    publicIPv4=$(curl "${ipv4_args[@]}" 2>/dev/null) || { publicIPv4_exist=False; }
    publicIPv6=$(curl "${ipv6_args[@]}" 2>/dev/null) || { publicIPv6_exist=False; }
  
    if [[ "${publicIPv4_exist}" == False ]] && [[ "${publicIPv6_exist}" == False ]]
    then
      echo "Error - IPv4 & IPv6: Couldn't get public IP."
      return 1
    fi

    token=$(wget "${token_args[@]}" | grep "${grep_token_args[@]}" )
    readonly ipv4_portcheck_args=(-T2 -t1 -qO- --load-cookies "${tmp_file}" "${port_url}" --post-data "target_ip=${publicIPv4}&port=${port}&_csrf=${token::-1}")
    readonly ipv6_portcheck_args=(-T2 -t1 -qO- --load-cookies "${tmp_file}" "${port_url}" --post-data "target_ip=${publicIPv6}&port=${port}&_csrf=${token::-1}")
  
    if [[ -n "${token}" ]]
    then
      if [[ "${publicIPv4_exist}" == True ]] && [[ "${publicIPv6_exist}" == False ]]
      then
        grep "${grep_portcheck_args[@]}" <(wget "${ipv4_portcheck_args[@]}") && \
        { ipv4_port_access=True; } || { ipv4_port_access=False; }
      elif [[ "${publicIPv4_exist}" == False ]] && [[ "${publicIPv6_exist}" == True ]]
      then
        grep "${grep_portcheck_args[@]}" <(wget "${ipv6_portcheck_args[@]}") && \
        { ipv6_port_access=True; } || { ipv6_port_access=False; }
      else
        grep "${grep_portcheck_args[@]}" <(wget "${ipv4_portcheck_args[@]}") && \
        { ipv4_port_access=True; } || { ipv4_port_access=False; }
  
        grep "${grep_portcheck_args[@]}" <(wget "${ipv6_portcheck_args[@]}") && \
        { ipv6_port_access=True; } || { ipv6_port_access=False; }
      fi
       
      if [[ "${ipv4_port_access}" == True ]] && [[ "${ipv6_port_access}" == True ]]
      then
        echo "Open. IPv4: ${ipv4_port_access} & IPv6: ${ipv6_port_access}"
        return 0
      elif [[ "${ipv4_port_access}" == False ]] && [[ "${ipv6_port_access}" == False ]]
      then
        echo "Closed. IPv4 & IPv6"
        return 0
      fi
      
      if [[ "${ipv4_port_access}" == True ]] && [[ "${publicIPv6_exist}" == False  ]]
      then
        echo "Open. IPv4: ${ipv4_port_access} & IPv6: N/A" 
        return 0
      elif [[ "${ipv6_port_access}" == True ]] && [[ "${publicIPv4_exist}" == False  ]]
      then
        echo "Open. IPv6: ${ipv6_port_access} & IPv4: N/A"
        return 0
      fi
      
      if [[ "${ipv4_port_access}" == True ]] && [[ "${ipv6_port_access}" == False ]]
      then
        echo "Open. IPv4: ${ipv4_port_access} & IPv6: ${ipv6_port_access}"
        return 0
      elif [[ "${ipv4_port_access}" == False ]] && [[ "${ipv6_port_access}" == True ]]
      then
        echo "Open. IPv4: ${ipv4_port_access} & IPv6: ${ipv6_port_access}"
        return 0
      else
        echo "Error - Teapot"
        return 1
      fi
      
    else
      echo "Error - Couldn't obtain a token for port check"
      return 1
    fi
}

echo "Port check 80|$( is_port_open 80 )"
echo "Port check 443|$( is_port_open 443 )"
