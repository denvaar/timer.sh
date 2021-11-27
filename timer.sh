#!/bin/bash
#
# A countdown timer intended for devoting
# time to a specific purpose (timeboxing).
#
# Arguments
# ---------
#
# $1 duration in minutes
# $2 purpose/intent (optional)
#
# Examples
# --------
#
# # Start a 10-minute timer to, "Get 'r done".
# sh timer.sh 10 "Get 'r done"
#
# # Start a generic 100-minute timer.
# sh timer.sh 100
#
#

DURATION=$(($1 * 1))
MESSAGE=${2:+"- $2"}

format_output() {
  # truncate output if it's longer than
  # the columns available in the window.

  local message=$1
  local n_cols=`tput cols`
  local prefix_template=" 00:00:00 "
  local line_chars=$(( ${#message} + ${#prefix_template} + 1 ))

  if [[ $line_chars -gt $n_cols ]]; then
    local trunc_chars="..."
    local truncate_length=$(( $n_cols - ${#prefix_template} - ${#trunc_chars} - 1 ))
    message="`echo "$message" | cut -c -$truncate_length`$trunc_chars"
  fi

  echo $message
}


countdown() {
  local duration=$1
  local message=$2

  local hour=$(( $duration / 60 ))
  local min=$(( $duration - 60 * $hour - 1 ))
  local sec=59

  while [ $hour -ge 0 ]; do
    while [ $min -ge 0 ]; do
      while [ $sec -ge 0 ]; do
        message=`format_output "$message"`

        # \033[1;43m --> yellow background
        # \033[1;30m --> black foreground
        # \033[0m    --> reset (default) color
        # \033[0K\r  --> move cursor back to beginning of line.
        printf "\033[1;43m\033[1;30m %02d:%02d:%02d \033[0m %b\033[0K\r" $hour $min $sec "$message"

        sec=$((sec - 1))
        sleep 1
      done
      sec=59
      min=$((min - 1))
    done
    min=59
    hour=$((hour - 1))
  done
}

countdown $DURATION "$MESSAGE"

# \007       --> Sound the terminal bell
# \033[1;42m --> Green background
# \033[1;97m --> White foreground
# \033[0m    --> reset (default) color
printf "\007\033[1;42m\033[1;97m Complete \033[0m %b\n" "$MESSAGE"
