#!/bin/bash

CMD_ARR=( "$@" )
CMD_ARR_LEN=${#CMD_ARR[@]}

if [ $CMD_ARR_LEN -eq 0 ]; then
  CMD_ARR=('bash' 'bash')
elif [ $CMD_ARR_LEN -eq 1 ]; then
  CMD_ARR+=('bash')
fi

TMUX_CMD="tmux new-session -d ${CMD_ARR[0]}"

for cmd in "${CMD_ARR[@]:1}"; do
  TMUX_CMD+=" \; split-window $cmd"
done

TMUX_CMD+=" \; attach \; select-layout even-vertical"

eval "$TMUX_CMD"
