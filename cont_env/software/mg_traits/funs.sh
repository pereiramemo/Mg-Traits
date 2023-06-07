if [[ "${VERBOSE_ALL}" == "t" ]]; then

  function handleoutput {
    cat /dev/stdin | \
    while read STDIN; do 
      echo "${STDIN}"
    done
  }
  
  function handleoutput_all {
    cat /dev/stdin | \
    while read STDIN; do 
      echo "${STDIN}"
    done  
  }
  
fi


if [[ "${VERBOSE}" == "t" && "${VERBOSE_ALL}" == "f" ]]; then

  function handleoutput {
    cat /dev/stdin | \
    while read STDIN; do 
      echo "${STDIN}"
    done  
  }

  function handleoutput_all {
    cat /dev/stdin >/dev/null
  }
    
fi

if [[ "${VERBOSE}" == "f" && ${VERBOSE_ALL} == "f" ]]; then

  function handleoutput {
    cat /dev/stdin >/dev/null
  }

  function handleoutput_all {
    cat /dev/stdin >/dev/null
  }

fi

